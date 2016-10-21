local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "agenthelper"
local configdao = require "configdao"
local tabletool = require "tabletool"
local timetool = require "timetool"
local gamelog = require "gamelog"
local processstate = require "processstate"
local playerdatadao = require "playerdatadao"
local base = require "base"
local table = table
require "enum"
local processing = processstate:new({timeout = 5})
local  EnterGame = {}

--[[
//请求进入游戏
message EnterGameReq {
	optional Version version = 1;
	optional string device_info = 2; //设备信息
	optional int32 uid = 3;
	optional int32 rid = 4;
	optional int32 expiretime = 5;
	optional string logintoken = 6; 
}

//响应进入游戏
message EnterGameRes {
	optional int32 errcode = 1; //错误原因 0表示成功
	optional string errcodedes = 2; //错误描述
	optional int32 isreauth = 3; //是否需要重新认证，断线重连时根据token是否过期告诉client是否需要重新登录认证, 2表示false、1表示true
	optional int32 servertime = 4; //同步服务器时间
	optional PlayerBaseinfo baseinfo = 5; //下面数据用于判断玩家是否需要牌桌断线重连
	optional string ip = 6;   //gatesvrd的ip
	optional int32 port = 7;  //gatesvrd的port
	optional string roomsvr_id = 8; //房间服务器id
	optional int32  roomsvr_table_address = 9; //桌子的服务器地址 
}
]]

function  EnterGame.process(session, source, fd, request)
	local responsemsg = {
		errcode = EErrCode.ERR_SUCCESS,
	}
	local server = msghelper:get_server()

	--检查当前登陆状态
	if server.state == EGateAgentState.GATE_AGENTSTATE_LOGINING 
		or server.state == EGateAgentState.GATE_AGENTSTATE_LOGOUTING then
		filelog.sys_warning("EnterGame.process invalid server state", server.state)
		return
	end

	--当前是否正在处理上一次请求
	if processing:is_processing() then
		filelog.sys_warning("EnterGame.process processing:is_processing")
		return
	end

	processing:set_process_state(true)

	--设置当前正在登陆的状态
	server.state = EGateAgentState.GATE_AGENTSTATE_LOGINING

	local gatesvrs = configdao.get_svrs("gatesvrs")
    if gatesvrs == nil then
    	responsemsg.errcode = EErrCode.ERR_SYSTEM_ERROR
		responsemsg.errcodedes = "系统错误，登陆失败！"
		msghelper:send_resmsgto_client(fd, "EnterGameRes", responsemsg)		
		--将玩家踢掉并释放agent
		server:agentexit()
		filelog.sys_error("EnterGame.process configdao.get_svrs failed")
		processing:set_process_state(false)
		return    	
   	end
	
	local gatesvr = gatesvrs[skynet.getenv("svr_id")]
   	if gatesvr == nil then
    	responsemsg.errcode = EErrCode.ERR_SERVER_EXPIRED
		responsemsg.errcodedes = "当前服务器已失效，请重试！"
		msghelper:send_resmsgto_client(fd, "EnterGameRes", responsemsg)		
		--将玩家踢掉并释放agent
		server:agentexit()
		processing:set_process_state(false)
		return    	   		
   	end
   	local status
   	status, server.info = playerdatadao.query_player_info(request.rid)
   	----新注册玩家发一封邮件
   	---if status == true then
   		local mailconf = configdao.get_business_conf(100, 1000, "mailcfg")
   		local newplayermail = tabletool.deepcopy(mailconf.newplayermail)
   		---填充
   		newplayermail.mail_key = base.generate_uuid()
   		newplayermail.rid = request.rid
   		newplayermail.create_time = timetool.get_time()
   		filelog.sys_error("---------insert--newplayermail------",newplayermail)
   		playerdatadao.save_player_mail("insert",request.rid,newplayermail,nil)
   	---end
	status, server.playgame = playerdatadao.query_player_playgame(request.rid)
	status, server.online = playerdatadao.query_player_online(request.rid)
	status, server.money = playerdatadao.query_player_money(request.rid)
	
	if server.info == nil 
		or server.playgame == nil 
		or server.online == nil 
		or server.money == nil then
		responsemsg.errcode = EErrCode.ERR_ACCESSDATA_FAILED
		responsemsg.errcodedes = "登陆读取数据失败！"
		msghelper:send_resmsgto_client(fd, "EnterGameRes", responsemsg)		
		--将玩家踢掉并释放agent
		server:agentexit()
		processing:set_process_state(false)
		return    	   		
	end

	if server.state ~= EGateAgentState.GATE_AGENTSTATE_LOGINING then
		return
	end
	responsemsg.isreauth = EBOOL.FALSE
	if server.online.gatesvr_id ~= "" and server.online.gatesvr_id ~= skynet.getenv("svr_id") then
		responsemsg.ip = server.online.gatesvr_ip
		responsemsg.port = server.online.gatesvr_port
		msghelper:send_resmsgto_client(fd, "EnterGameRes", responsemsg)
		server:agentexit()
		processing:set_process_state(false)
		return
	end

	--一定放在所有异步处理的后面
	processing:set_process_state(false)

	--设置玩家登陆成功
	server.state = EGateAgentState.GATE_AGENTSTATE_LOGINED
	server.platform = request.version.platform --client 平台id(属于哪家公司发行)
	server.channel = request.version.channel  --client 渠道id(发行公司的发行渠道)
	server.version = request.version.version --client 版本号
	server.authtype = request.version.authtype --client 账号类型
	server.regfrom = request.version.regfrom  --描述从哪里注册过来的
	server.rid = request.rid
	server.uid = request.uid

	if server.online.roomsvr_id == "" or server.online.roomsvr_table_id <= 0 then
		server.roomsvr_id = ""
		server.roomsvr_table_id = 0
		server.roomsvr_table_address = -1
	else
		server.roomsvr_id = server.online.roomsvr_id
		server.roomsvr_table_id = server.online.roomsvr_table_id
		server.roomsvr_table_address = server.online.roomsvr_table_address
	end

	responsemsg.servertime = timetool.get_time()
	responsemsg.roomsvr_id = server.online.roomsvr_id
	responsemsg.roomsvr_table_address = server.online.roomsvr_table_address 
	responsemsg.baseinfo = {}
	if server.money.coin > server.playgame.maxcoinnum then
		server.playgame.maxcoinnum = server.money.coin
	end

	msghelper:copy_base_info(responsemsg.baseinfo, server.info, server.playgame, server.money)

	--保存玩家在线状态
	local gatesvrs = configdao.get_svrs("gatesvrs")
	local gatesvr = gatesvrs[skynet.getenv("svr_id")]
	server.online.activetime = timetool.get_time() 
	server.online.gatesvr_ip = gatesvr.svr_ip
	server.online.gatesvr_port = gatesvr.svr_port
	server.online.gatesvr_id = skynet.getenv("svr_id")
	server.online.gatesvr_service_address = skynet.self()

	playerdatadao.save_player_online("update", request.rid, server.online)

	msghelper:send_resmsgto_client(fd, "EnterGameRes", responsemsg)
end

return EnterGame

