require "enum"
local tabletool = require "tabletool"
local msghelper = require "tablehelper"
local filelog = require "filelog"
local timer = require "timer"
local msgproxy = require "msgproxy"
local timetool = require "timetool"

local RoomSeatLogic = {}

function RoomSeatLogic.init(seatobj, index)
	seatobj.index = index
	seatobj.state = ESeatState.SEAT_STATE_NO_PLAYER
	seatobj.is_tuoguan = EBOOL.FALSE
	return true
end

function RoomSeatLogic.clear(seatobj)
	seatobj.rid = 0
	seatobj.state = 0  --改坐位玩家状态
	seatobj.gatesvr_id=""
	seatobj.agent_address = -1
	seatobj.playerinfo = {}
end

function RoomSeatLogic.is_empty(seatobj)
	return (seatobj.state == ESeatState.SEAT_STATE_NO_PLAYER)
end

function RoomSeatLogic.dealcards(seatobj)
	local noticemsg = {
		rid = seatobj.rid,
		roomsvr_seat_index = seatobj.index,
		cards = nil
	}
	if noticemsg.cards == nil then
		noticemsg.cards = tabletool.deepcopy(seatobj.cards)
	end
	---filelog.sys_error("--------------fapai----------------------",seatobj.cards)
	msghelper:sendmsg_to_tableplayer(seatobj,"DealCardsNtc",noticemsg)
end

function RoomSeatLogic.setSeatstate(gameobj)
	---filelog.sys_error("---------change------------------",gameobj.action_type)
	if gameobj.action_type == EActionType.ACTION_TYPE_CHUPAI then
		gameobj.seats[gameobj.action_seat_index].state = ESeatState.SEAT_STATE_CHUPAI
	elseif gameobj.action_type == EActionType.ACTION_TYPE_FOLLOW_CHUPAI then
		gameobj.seats[gameobj.action_seat_index].state = ESeatState.SEAT_STATE_FOLLOW_CHUPAI
	elseif gameobj.action_type == EActionType.ACTION_TYPE_CHECK then
		gameobj.seats[gameobj.action_seat_index].state = ESeatState.SEAT_STATE_CHECK
	elseif gameobj.action_type == EActionType.ACTION_TYPE_JIAODIZHU then
		gameobj.seats[gameobj.action_seat_index].state = ESeatState.SEAT_STATE_JDZ
	elseif gameobj.action_type == EActionType.ACTION_TYPE_QIANGDIZHU then
		gameobj.seats[gameobj.action_seat_index].state = ESeatState.SEAT_STATE_QIANGDZ
	elseif gameobj.action_type == EActionType.ACTION_TYPE_BUJIAO_DIZHU then
		gameobj.seats[gameobj.action_seat_index].state = ESeatState.SEAT_STATE_NOT_JDZ
	elseif gameobj.action_type == EActionType.ACTION_TYPE_BUQIANGDIZHU then
		gameobj.seats[gameobj.action_seat_index].state = ESeatState.SEAT_STATE_NOT_QIANGDZ
	end
	---filelog.sys_error("---------change------------------",gameobj.action_type,gameobj.action_seat_index,gameobj.seats[gameobj.action_seat_index].state,"?????????????????")
end

function RoomSeatLogic.resetstate(seatobj)
	if seatobj.state == ESeatState.SEAT_STATE_PLAYING or seatobj.state == ESeatState.SEAT_STATE_CHECK
			or seatobj.state == ESeatState.SEAT_STATE_CHUPAI or seatobj.state == ESeatState.SEAT_STATE_FOLLOW_CHUPAI then
		seatobj.state = ESeatState.SEAT_STATE_WAIT_READY
		---v.cards = nil
		seatobj.timeout_count = 0
		seatobj.win = 0		---表示玩家胜利还是失败
		seatobj.jdztag = 0  	----记录叫地主标识(不叫地址值为0, 1表示叫地主, 2表示抢地主)
		seatobj.isdz = EBOOL.FALSE ---记录是否是地主
		seatobj.is_tuoguan = EBOOL.FALSE
		---seatobj.coin = 0
		seatobj.ready_timer_id = -1 ---准备倒计时定时器
		seatobj.ready_to_time = 0   ---准备到期时间
		seatobj.cards = {}   ---玩家手牌
		seatobj.ismingpai = 0 ---是否明牌
	elseif seatobj.state == ESeatState.SEAT_STATE_TAOPAO then
		seatobj.state = ESeatState.SEAT_STATE_WAIT_READY
		seatobj.timeout_count = 0
		seatobj.is_tuoguan = EBOOL.FALSE
		seatobj.win = 0		---表示玩家胜利还是失败
		seatobj.jdztag = 0  	----记录叫地主标识(不叫地址值为0, 1表示叫地主, 2表示抢地主)
		seatobj.isdz = EBOOL.FALSE ---记录是否是地主
		seatobj.coin = 0
		seatobj.ready_timer_id = -1 ---准备倒计时定时器
		seatobj.ready_to_time = 0   ---准备到期时间
		seatobj.cards = {}   ---玩家手牌
		seatobj.ismingpai = 0 ---是否明牌
	end
end

function RoomSeatLogic.clear_seat(seat)
	seat.rid = 0
	seat.state = ESeatState.SEAT_STATE_NO_PLAYER
	seat.gatesvr_id=""
	seat.agent_address = -1
	seat.playerinfo.rolename = ""
	seat.playerinfo.logo=""
	seat.playerinfo.sex = 0
    seat.playerinfo.winnum = 0
    seat.playerinfo.coins = 0
    seat.playerinfo.diamonds = 0
    seat.playerinfo.highwininseries = 0
    seat.playerinfo.maxcoinnum = 0
	seat.is_tuoguan = EBOOL.FALSE
	seat.is_robot = false
	seat.timeout_count = 0
	seat.win = 0
	seat.jdztag = 0
	seat.isdz = EBOOL.FALSE
	seat.coin = 0
	seat.ready_to_time = 0
	seat.cards = nil
	if seat.ready_timer_id > 0 then
		timer.cleartimer(seat.ready_timer_id)
		seat.ready_timer_id = -1
	end
end

function RoomSeatLogic.dealtuoguan(gameobj,seat)
	if seat.is_tuoguan == EBOOL.FALSE then
		seat.is_tuoguan = EBOOL.TRUE
		local noticemsg = {
			rid = seat.rid,
			roomsvr_seat_index = seat.index,
			action_type = EActionType.ACTION_TYPE_REQUEST_TUOGUAN,
			cards = {},
		}
		msghelper:sendmsg_to_alltableplayer("DoactionResultNtc", noticemsg)
		----如果已经注册玩家操作超时定时器,则取消
		---filelog.sys_error("----tuoguan-------gameobj.action_seat_index",gameobj.action_seat_index,gameobj.action_type,gameobj.action_to_time,seat.index)
		if gameobj.action_seat_index == seat.index then
			if gameobj.timer_id > 0 then
				timer.cleartimer(gameobj.timer_id)
				gameobj.timer_id = -1
			end
			local doactionntcmsg = {
				rid = gameobj.seats[gameobj.action_seat_index].rid,
				roomsvr_seat_index = gameobj.action_seat_index,
				action_type = gameobj.action_type,
				action_to_time = gameobj.action_to_time,
			}
			local lefttime = gameobj.action_to_time - timetool.get_time()
			---filelog.sys_error("---------------处理定时器-----------",lefttime)
			if lefttime <= ETuoguanDelayTime.TUOGUAN_DELAY_TIME and lefttime > 0 then
				gameobj.timer_id = timer.settimer(lefttime*100, "doaction", doactionntcmsg)
			else
				gameobj.timer_id = timer.settimer(ETuoguanDelayTime.TUOGUAN_DELAY_TIME*100, "doaction", doactionntcmsg)
			end
		end
	end
end

function RoomSeatLogic.canceltuoguan(gameobj,seat)
	if seat.is_tuoguan == EBOOL.TRUE then
		seat.timeout_count = 0
		seat.is_tuoguan = EBOOL.FALSE
		local noticemsg = {
			rid = seat.rid,
			roomsvr_seat_index = seat.index,
			action_type = EActionType.ACTION_TYPE_CANCEL_TUOGUAN,
			cards = {},
		}
		msghelper:sendmsg_to_alltableplayer("DoactionResultNtc", noticemsg)
		----如果已经注册玩家操作超时定时器,则取消
		---filelog.sys_error("----quxiaotuoguan-------gameobj.action_seat_index",gameobj.action_seat_index,gameobj.action_type,gameobj.action_to_time,seat.index)
		if gameobj.action_seat_index == seat.index then
			if gameobj.timer_id > 0 then
				timer.cleartimer(gameobj.timer_id)
				gameobj.timer_id = -1
			end
			local doactionntcmsg = {
				rid = gameobj.seats[gameobj.action_seat_index].rid,
				roomsvr_seat_index = gameobj.action_seat_index,
				action_type = gameobj.action_type,
				action_to_time = gameobj.action_to_time,
			}
			local lefttime = gameobj.action_to_time - timetool.get_time()
			---filelog.sys_error("---------------quxiaotuoguan处理定时器-----------",lefttime)
			if lefttime > 0 then
				gameobj.timer_id = timer.settimer(lefttime*100, "doaction", doactionntcmsg)
			end
		end
	end
end

function RoomSeatLogic.balancegame(seat,getvalue)
	msgproxy.sendrpc_noticemsgto_gatesvrd(seat.gatesvr_id,seat.agent_address, "updatecurrency",
		seat.rid,ECurrencyType.CURRENCY_TYPE_COIN,getvalue,EReasonChangeCurrency.CHANGE_CURRENCY_NORMAL_GAME)
	msgproxy.sendrpc_noticemsgto_gatesvrd(seat.gatesvr_id,seat.agent_address, "updategameinfo",seat.rid,seat.win,seat.isdz,1,reason)
end

function RoomSeatLogic.onegamestart_initseat(seat)
	seat.state = ESeatState.SEAT_STATE_PLAYING
	seat.timeout_count = 0
	seat.ready_to_time = 0
	if seat.ready_timer_id > 0 then
		timer.cleartimer(seat.ready_timer_id)
		seat.ready_timer_id = -1
	end
end



return RoomSeatLogic