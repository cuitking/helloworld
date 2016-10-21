local filelog = require "filelog"
local msghelper = require "agenthelper"
local base = require "base"
local playerdatadao = require "playerdatadao"
require "enum"

local AgentNotice = {}

function AgentNotice.process(session, source, event, ...)
	local f = AgentNotice[event] 
	if f == nil then
		f = AgentNotice["other"]
		f(event, ...)
		return
	end
	f(...)
end

function AgentNotice.leavetable(noticemsg)
	if not msghelper:is_login_success() then
		return
	end

	local server = msghelper:get_server()
	if server.rid ~= noticemsg.rid then
		return
	end

	if server.roomsvr_id ~= noticemsg.roomsvr_id then
		return
	end

	if server.roomsvr_table_id ~= noticemsg.roomsvr_table_id then
		return
	end

	if server.roomsvr_table_address ~= noticemsg.roomsvr_table_address then
		return
	end

	server.roomsvr_id = ""
	server.roomsvr_table_id = 0
	server.roomsvr_table_address = -1
	server.roomsvr_seat_index = 0
	server.online.roomsvr_id = ""
	server.online.roomsvr_table_id = 0
    server.online.roomsvr_table_address = -1
	playerdatadao.save_player_online("update", server.rid, server.online)

	if noticemsg.is_sendto_client then
		msghelper:send_resmsgto_client(nil, "LeaveTableRes", {errcode = EErrCode.ERR_SUCCESS})		
	end
end

function AgentNotice.standuptable(noticemsg)
	local server = msghelper:get_server()
	if server.rid ~= noticemsg.rid then
		return
	end

	if server.roomsvr_id ~= noticemsg.roomsvr_id then
		return
	end

	if server.roomsvr_table_id ~= noticemsg.roomsvr_table_id then
		return
	end

	if server.roomsvr_seat_index ~= noticemsg.roomsvr_seat_index then
		return
	end
	server.roomsvr_seat_index = 0
end

function AgentNotice.other(msgname, noticemsg)
	msghelper:send_noticemsgto_client(nil, msgname, noticemsg)
end

function AgentNotice.updategameinfo(rid,iswin,isdz,num,reason)
	local server = msghelper:get_server()
	filelog.sys_error("----------updategameinfo---------",rid,iswin,isdz,num,
		"+++++++++++++++++++",server.playgame)
	if server.rid ~= rid then
		return 
	end
	if not num or num < 0 then 
		return 
	end
	server.playgame.totalgamenum = server.playgame.totalgamenum + num
	if iswin == 1 then
		server.playgame.winnum = server.playgame.winnum + num
		server.playgame.wininseriesnum = server.playgame.wininseriesnum + num
		if server.playgame.wininseriesnum > server.playgame.highwininseries then
			server.playgame.highwininseries = server.playgame.wininseriesnum
		end
	elseif iswin == 0 then
		server.playgame.wininseriesnum = 0
	end

	playerdatadao.save_player_playgame("update",rid,server.playgame)
end



function AgentNotice.updatecurrency(rid,currencyid,number,reason)
	local server = msghelper:get_server()
	filelog.sys_error("-----------改变货币in agent---------",rid,currencyid,number,reason)
	filelog.sys_error(" --------------server----money---",server.money)
	filelog.sys_error(" --------------server----info-----", server.info)
	if server.rid ~= rid then
		return
	end
	if not (currencyid >= ECurrencyType.CURRENCY_TYPE_COIN and currencyid <= ECurrencyType.CURRENCY_TYPE_DIAMOND) then
		return
	end
	if currencyid == ECurrencyType.CURRENCY_TYPE_COIN then
		if server.money.coin + number >= 0 then
			server.money.coin = server.money.coin + number
		else
			server.money.coin = 0
		end
	elseif currencyid == ECurrencyType.CURRENCY_TYPE_DIAMOND then
		if server.money.diamond + number >= 0 then
			server.money.diamond = server.money.coin + number
		else
			server.money.diamond = 0
		end
	end
	if server.money.coin > server.playgame.maxcoinnum then
		server.playgame.maxcoinnum = server.money.coin
	end
	playerdatadao.save_player_money("update",rid,server.money)
end

return AgentNotice