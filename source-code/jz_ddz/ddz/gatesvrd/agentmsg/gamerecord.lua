local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "agenthelper"
local msgproxy = require "msgproxy"
local table = table
local processstate = require "processstate"
local playerdatadao = require "playerdatadao"
require "enum"
local  GameRecord = {}

--[[
//请求玩家战绩信息
message PlayerGameRecordinfoReq {
	optional Version version = 1;
	optional int32 rid = 2;
}
//响应玩家战绩信息
message PlayerGameRecordinfoRes {
	optional int32 errcode = 1; //错误原因 0表示成功
	optional string errcodedes = 2; //错误描述
	repeated PlayerGameRecordinfo recordinfo = 3; // 
}
]]

function  GameRecord.process(session, source, fd, request)
    local responsemsg = {
        errcode = EErrCode.ERR_SUCCESS,
    }
    local server = msghelper:get_server()

    --检查当前登陆状态
    if not msghelper:is_login_success() then
        filelog.sys_warning("EnterTable.process invalid server state", server.state)
        responsemsg.errcode = EGateAgentState.ERR_INVALID_REQUEST
        responsemsg.errcodedes = "无效的请求！"
        msghelper:send_resmsgto_client(fd, "PlayerGameRecordinfoRes", responsemsg)
        return
    end

    local status
    local records
    status, records = playerdatadao.query_player_tablerecords(request.rid)
    filelog.sys_error("----------------getgamerecord----------------",status,"++++++++++++++++",records)
    responsemsg.errcodedes = "请求成功!!!!"
    responsemsg.records = {}
    for k, value in ipairs(records) do
    	local baseinfo = {}
    	baseinfo.table_id = value.table_id
    	baseinfo.table_create_time = value.table_create_time
    	baseinfo.tablecreater_rid = value.tablecreater_rid
    	baseinfo.entercosts = 100
    	baseinfo.recordinfos = {}
    	for m,n in ipairs(value.record) do
    		local recordinfo = {}
    		recordinfo.rid = n.rid
    		recordinfo.currencyid = n.currencyid
    		recordinfo.balancenum = n.balancenum
    		recordinfo.rolename = n.rolename
    		table.insert(baseinfo.recordinfos,recordinfo)
    	end
    	table.insert(responsemsg.records,baseinfo)
    end
    
	
	filelog.sys_error("----------------sendgetgamerecord----------------",responsemsg)
    msghelper:send_resmsgto_client(fd, "PlayerGameRecordinfoRes", responsemsg)

end

return GameRecord
