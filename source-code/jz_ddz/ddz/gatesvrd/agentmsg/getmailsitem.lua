local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "agenthelper"
local processstate = require "processstate"
local playerdatadao = require "playerdatadao"
local tabletool = require "tabletool"
local tostring = tostring
local json = require "cjson"
require "enum"

json.encode_sparse_array(true,1,1)

local Getmailsitem = {}
--[[
//玩家请求领取邮件附件
message GetmailItemsReq {
	optional Version version = 1;
	optional string mail_key = 2;
}
//响应玩家请求领取邮件附件
message GetmailItemsRes {
	optional int32 errcode = 1; //错误原因 0表示成功
	optional string errcodedes = 2; // 错误描述 
	optional string mail_key = 3; //
	optional string resultdes = 4; // 得到物品的json串
}
--]]


function  Getmailsitem.process(session, source, fd, request)
    local responsemsg = {
        errcode = EErrCode.ERR_SUCCESS,
    }
    local server = msghelper:get_server()
    --检查当前登陆状态
	if not msghelper:is_login_success() then
		filelog.sys_error("Getmails.process invalid server state", server.state)
		responsemsg.errcode = EErrCode.ERR_INVALID_REQUEST
		responsemsg.errcodedes = "无效的请求!"
		msghelper:send_resmsgto_client(fd, "GetmailItemsRes", responsemsg)		
		return
	end

	local status
	local mails
	local condition = " select * from role_mailinfos where mail_key = '" .. request.mail_key .. "'"

	status, mails = playerdatadao.query_player_mail(server.rid,condition)

	if status == true or #mails == 0 then
		responsemsg.errcode = EErrCode.ERR_INVALID_REQUEST
		responsemsg.errcodedes = "无效的邮件!"
		msghelper:send_resmsgto_client(fd, "GetmailItemsRes", responsemsg)		
		return
	end
	
	if mails[1].isattach == 1 then
		local mailscontent = json.decode(mails[1].content)
		local items
		if mailscontent.isattach == true then
			 mailscontent.isattach = false
			 mails[1].isattach = 0
			 items = tabletool.deepcopy(mailscontent.awards)
			 mailscontent.awards = {}
		end
		mails[1].content = tabletool.deepcopy(mailscontent)
		condition = "where mail_key = '" .. request.mail_key .. "'"
		playerdatadao.save_player_mail("delete",server.rid, nil,condition)
		responsemsg.mail_key = mails[1].mail_key
		responsemsg.resultdes = ""
		if items then
			responsemsg.resultdes = responsemsg.resultdes..json.encode(items)
		end
		if #items> 0 then
			for k,v in ipairs(items) do
				if v.id == ECurrencyType.CURRENCY_TYPE_COIN then
					server.money.coin = server.money.coin + v.num
				elseif v.id == ECurrencyType.CURRENCY_TYPE_DIAMOND then
					server.money.diamond = server.money.diamond + v.num
				end
			end
			playerdatadao.save_player_money("update",server.rid,server.money)
		end

		local CurrencyinfoNtcmsg = {
			coins = 0,
			diamonds = 0
		}
		CurrencyinfoNtcmsg.coins = server.money.coin
		CurrencyinfoNtcmsg.diamonds = server.money.diamond
		filelog.sys_error("---------------GetmailItemsRes-------------",responsemsg)
		msghelper:send_resmsgto_client(fd, "GetmailItemsRes", responsemsg)
		msghelper:send_resmsgto_client(fd, "CurrencyinfoNtc", CurrencyinfoNtcmsg)
		return 
	end

    msghelper:send_resmsgto_client(fd, "GetmailItemsRes", responsemsg)
end

return Getmailsitem




