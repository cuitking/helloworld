local base = require "base"
local msghelper = require "tablehelper"
local timetool = require "timetool"
local timer = require "timer"
local filelog = require "filelog"
local logicmng = require "logicmng"
local ddzgamelogic = require "ddzgamelogic"
require "enum"
local RoomGameLogic = {}

function RoomGameLogic.init(gameobj, tableobj)
	gameobj.tableobj = tableobj
	gameobj.stateevent[ETableState.TABLE_STATE_GAME_START] = RoomGameLogic.gamestart
	gameobj.stateevent[ETableState.TABLE_STATE_ONE_GAME_START] = RoomGameLogic.onegamestart
	gameobj.stateevent[ETableState.TABLE_STATE_WAIT_START_COUNT_DOWN] = RoomGameLogic.waitstartcountdown
	gameobj.stateevent[ETableState.TABLE_STATE_WAIT_PLAYER_MINGPAI] = RoomGameLogic.waitmingpai
	gameobj.stateevent[ETableState.TABLE_STATE_PLAYER_JDZ] = RoomGameLogic.playerjdz
	gameobj.stateevent[ETableState.TABLE_STATE_WAIT_PLAYER_CHUPAI] = RoomGameLogic.chupai
	gameobj.stateevent[ETableState.TABLE_STATE_ONE_GAME_END] = RoomGameLogic.onegameend
	gameobj.stateevent[ETableState.TABLE_STATE_ONE_GAME_REAL_END] = RoomGameLogic.onegamerealend
	gameobj.stateevent[ETableState.TABLE_STATE_GAME_END] = RoomGameLogic.gameend
	gameobj.stateevent[ETableState.TABLE_STATE_CONTINUE] = RoomGameLogic.continue
	gameobj.stateevent[ETableState.TABLE_STATE_CONTINUE_AND_STANDUP] = RoomGameLogic.continue_and_standup
	gameobj.stateevent[ETableState.TABLE_STATE_CONTINUE_AND_LEAVE] = RoomGameLogic.continue_and_leave
	return true
end

function RoomGameLogic.run(gameobj)
	local f = nil
	while true do
		if gameobj.tableobj.state == ETableState.TABLE_STATE_WAIT_ALL_READY then
			break
		end

		f = gameobj.stateevent[gameobj.tableobj.state]
		if f == nil then
			break
		end
		f(gameobj)
	end
end

function RoomGameLogic.gamestart(gameobj)
	local tableobj = gameobj.tableobj
	tableobj.state = ETableState.TABLE_STATE_WAIT_PLAYER_SITDOWN
	----设置一些连续牌桌游戏的变量
end

function RoomGameLogic.onegamestart(gameobj)
	local tableobj = gameobj.tableobj
	RoomGameLogic.onegamestart_inittable(gameobj)
	tableobj.state = ETableState.TABLE_STATE_WAIT_START_COUNT_DOWN
end

----桌子进入开始倒计时阶段
function RoomGameLogic.waitstartcountdown(gameobj)
	local tableobj = gameobj.tableobj
	local startcountdownmsg = {

	}
	if tableobj.timer_id >0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end
	-----启动开始倒计时定时器，在定时器超时函数中处理发牌逻辑
	tableobj.timer_id = timer.settimer(5*100, "waitstartcountdown", startcountdownmsg)

	tableobj.state = ETableState.TABLE_STATE_WAIT_COUNT_DOWN
end

----发完牌后开启定时器等待玩家明牌
function RoomGameLogic.waitmingpai(gameobj)
	filelog.sys_error("RoomGameLogic.waitmingpai")
	local tableobj = gameobj.tableobj


	local mingpaimsg = {
		action_type = EActionType.ACTION_TYPE_MINGPAI
	}
	if tableobj.timer_id >0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end
	-----启动开始倒计时定时器
	tableobj.timer_id = timer.settimer(8*100, "doaction", mingpaimsg)

	tableobj.state = ETableState.TABLE_STATE_WAIT_CLIENT_ACTION
end

----明牌阶段后进入叫地主阶段
function RoomGameLogic.playerjdz(gameobj)
	filelog.sys_error("RoomGameLogic.playerjdz")
	local tableobj = gameobj.tableobj
	local seatIndex = base.get_random(1,#tableobj.seats)
	local action_seat_index = seatIndex
	tableobj.action_type = EActionType.ACTION_TYPE_JIAODIZHU
	tableobj.action_seat_index = seatIndex
	tableobj.jzdbegin_index = seatIndex
	tableobj.action_to_time = timetool.get_time() + tableobj.conf.action_timeout

	--下发当前玩家操作协议
	local doactionntcmsg = {
		rid = tableobj.seats[action_seat_index].rid,
		roomsvr_seat_index = action_seat_index,
		action_to_time = tableobj.action_to_time,
		action_type = EActionType.ACTION_TYPE_JIAODIZHU
	}
	filelog.sys_error("  ------tongzhiwanjia-----jiaodizhu ------",doactionntcmsg, "-------os.time----------",os.time())
	----通知所有玩家 seatIndex上的玩家在叫地主了
	msghelper:sendmsg_to_alltableplayer("DoactionNtc", doactionntcmsg)

	if tableobj.timer_id >0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end

	local jdzouttimemsg = {
		action_type = EActionType.ACTION_TYPE_JIAODIZHU
	}
	tableobj.timer_id = timer.settimer(tableobj.conf.action_timeout*100, "doaction", jdzouttimemsg)
	----tableobj.timer_id = timer.settimer(30*100, "outtimejdz", jdzouttimemsg)
	----切换桌子状态
	tableobj.state = ETableState.TABLE_STATE_WAIT_PLAYER_JDZ
end

-----玩家出牌游戏开始
function RoomGameLogic.chupai(gameobj)
	local tableobj = gameobj.tableobj
	filelog.sys_error("RoomGameLogic.onegamestart",tableobj.dz_seat_index)
	if tableobj.timer_id > 0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end
	----设置seat是否是地主的标识
	for k,v in ipairs(tableobj.seats) do
		if v.index == tableobj.dz_seat_index then
			v.isdz = EBOOL.TRUE
		end
	end
	------通知玩家出牌之前,通知玩家底牌
	local DealCardsEndmsg = {
		rid = tableobj.seats[tableobj.dz_seat_index].rid,
		cards = {},
	}
	for k,v in ipairs(tableobj.initCards) do
		table.insert(DealCardsEndmsg.cards,v)
		table.insert(tableobj.seats[tableobj.dz_seat_index].cards, v) ---将剩余的三张底牌加入地主的手牌中
	end
	tableobj.ddzgame.SortCards(tableobj.seats[tableobj.dz_seat_index].cards)
	filelog.sys_error("------------post--deep---cards-----------",DealCardsEndmsg,"===================",tableobj.seats)
	msghelper:sendmsg_to_alltableplayer("DealCardsEndNtc", DealCardsEndmsg)
	local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
	roomtablelogic.setallseatstate(tableobj,ESeatState.SEAT_STATE_WAIT_NOTICE)
	roomtablelogic.sendGameStart(tableobj)
	local action_seat_index = tableobj.action_seat_index
	if tableobj.action_type ~= EActionType.ACTION_TYPE_CHUPAI then
		tableobj.action_type = EActionType.ACTION_TYPE_CHUPAI
	end
	tableobj.action_to_time = timetool.get_time() + tableobj.conf.action_timeout
	--下发当前玩家操作协议
	local doactionntcmsg = {
		rid = tableobj.seats[action_seat_index].rid,
		roomsvr_seat_index = action_seat_index,
		action_to_time = tableobj.action_to_time,
		action_type = tableobj.action_type
	}
	filelog.sys_error("  ------gaosuwanjia onegamestart ------",doactionntcmsg)
	----通知所有玩家 seatIndex上的玩家在出牌了
	msghelper:sendmsg_to_alltableplayer("DoactionNtc", doactionntcmsg)

	tableobj.timer_id = timer.settimer(tableobj.conf.action_timeout*100, "doaction", doactionntcmsg)

	tableobj.state = ETableState.TABLE_STATE_WAIT_CLIENT_ACTION
end


function RoomGameLogic.continue(gameobj)
	local tableobj = gameobj.tableobj
	if tableobj.timer_id >= 0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end
	local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
	local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
	local seat = tableobj.seats[tableobj.action_seat_index]

	local noticemsg = {
		rid = seat.rid,
		roomsvr_seat_index = tableobj.action_seat_index,
		action_type = tableobj.action_type,
		cards = {},
	}
	---如果table上的状态是等待玩家出牌
	if tableobj.action_type == EActionType.ACTION_TYPE_CHUPAI or tableobj.action_type == EActionType.ACTION_TYPE_FOLLOW_CHUPAI or
		tableobj.action_type == EActionType.ACTION_TYPE_CHECK then
		if tableobj.action_type ~= EActionType.ACTION_TYPE_CHECK and #tableobj.CardsHeaps > 0 then
			local roundheaps = tableobj.CardsHeaps[#tableobj.CardsHeaps]
			for k,v in ipairs(roundheaps[#roundheaps].cardHelper) do
				table.insert(noticemsg.cards,v)
			end
			----通知服务器当前牌桌的倍数,玩家的手牌数
			roomtablelogic.sendHandsInfo(tableobj)
		end
		tableobj.state = ETableState.TABLE_STATE_ONE_GAME_START
	end

	roomseatlogic.setSeatstate(tableobj)
	-- TO ADD操作类型
	msghelper:sendmsg_to_alltableplayer("DoactionResultNtc", noticemsg)

	local is_end_game = false
	if tableobj.action_type == EActionType.ACTION_TYPE_CHUPAI or tableobj.action_type == EActionType.ACTION_TYPE_FOLLOW_CHUPAI then
		for k,v in ipairs(tableobj.seats) do
			if #v.cards	== 0 then is_end_game = true break end
		end
	end
	--判断是否结束游戏
	if is_end_game then
		tableobj.state = ETableState.TABLE_STATE_ONE_GAME_END
		local roomgamelogic = msghelper:get_game_logic()
		roomgamelogic.run(tableobj.gamelogic)
		return
	end
	local next_action_index = 0
	local next_action_index_next = 0
	if tableobj.action_seat_index == 1 then
		next_action_index = 2
		next_action_index_next = 3
	elseif tableobj.action_seat_index == 2 then
		next_action_index = 3
		next_action_index_next = 1
	elseif	tableobj.action_seat_index == 3 then
		next_action_index = 1
		next_action_index_next = 2
	end
	----如果是在叫地主或者是抢地主过程中的各种操作,则需要把房间状态设置为等待玩家叫地主状态
	if roomtablelogic.isQiangdz(tableobj) then
		tableobj.state = ETableState.TABLE_STATE_WAIT_PLAYER_JDZ
	end
	if tableobj.state == ETableState.TABLE_STATE_WAIT_PLAYER_JDZ then
		if tableobj.action_type == EActionType.ACTION_TYPE_JIAODIZHU then
			seat.jdztag = 1 ----表示当前玩家已经叫过地主了
			tableobj.noputsCardsNum = 0
			if tableobj.jzdbegin_index == next_action_index and tableobj.seats[tableobj.action_seat_index].jdztag == 1 and
					tableobj.seats[next_action_index].jdztag < 0 and tableobj.seats[next_action_index_next].jdztag < 0 then
				----确定地主
				seat.jdztag = 1 ----表示当前玩家已经叫过地主了
				roomtablelogic.setdizhu(tableobj,tableobj.action_seat_index)
				return
			else
				-----通知下一家抢地主
				tableobj.action_type = EActionType.ACTION_TYPE_QIANGDIZHU
				tableobj.action_seat_index = next_action_index
			end
		elseif tableobj.action_type == EActionType.ACTION_TYPE_TIMEOUT_JDZ or tableobj.action_type == EActionType.ACTION_TYPE_BUJIAO_DIZHU then
			----玩家不叫地主或叫地主超时
			seat.jdztag = -1  ----表示当前玩家已经叫过地主了
			tableobj.noputsCardsNum = tableobj.noputsCardsNum + 1
			filelog.sys_error("------不叫地主-----",tableobj.noputsCardsNum)
			---尾家不叫地主
			if tableobj.jzdbegin_index == next_action_index and tableobj.seats[tableobj.action_seat_index].jdztag < 0 and
					((tableobj.seats[next_action_index].jdztag == 1 and tableobj.seats[next_action_index_next].jdztag < 0) or
							(tableobj.seats[next_action_index].jdztag < 0 and tableobj.seats[next_action_index_next].jdztag == 1)) then
				---设置地主
				local seatindex = tableobj.action_seat_index
				if tableobj.seats[next_action_index].jdztag == 1 and tableobj.seats[next_action_index_next] < 0 then
					seatindex = next_action_index
				elseif tableobj.seats[next_action_index].jdztag < 0 and tableobj.seats[next_action_index_next] == 1 then
					seatindex = next_action_index_next
				end
				roomtablelogic.setdizhu(tableobj,seatindex)
				return
			else
				-----通知下一家叫地主
				tableobj.action_type = EActionType.ACTION_TYPE_JIAODIZHU
				tableobj.action_seat_index = next_action_index
			end
		elseif tableobj.action_type == 	EActionType.ACTION_TYPE_TIMEOUT_QIANGDIZHU or tableobj.action_type == EActionType.ACTION_TYPE_BUQIANGDIZHU then
			----玩家不抢地主或抢地主超时
			seat.jdztag = -2
			filelog.sys_error("------玩家不抢地主或抢地主超时-----",tableobj.action_seat_index,tableobj.seats[tableobj.action_seat_index].jdztag,
				next_action_index,tableobj.seats[next_action_index].jdztag,next_action_index_next,tableobj.seats[next_action_index_next].jdztag)
			if tableobj.seats[next_action_index].jdztag == 2 then
				---确定地主
				local actionindex = next_action_index
				if tableobj.seats[next_action_index_next].jdztag == 2 then
					actionindex = next_action_index_next
				end
				roomtablelogic.setdizhu(tableobj,actionindex)
				return
			elseif tableobj.seats[next_action_index].jdztag == 1 then
				---通知下一家玩家抢地主
				if tableobj.seats[next_action_index_next].jdztag < 0 then
					roomtablelogic.setdizhu(tableobj,next_action_index)
					return
				else
					filelog.sys_error(" 通知下一家玩家抢地主 ",tableobj.action_seat_index,next_action_index)
					tableobj.action_seat_index = next_action_index
					tableobj.action_type = EActionType.ACTION_TYPE_QIANGDIZHU
				end
			elseif tableobj.seats[next_action_index].jdztag < 0 then
				if tableobj.seats[next_action_index_next].jdztag == 2 or tableobj.seats[next_action_index_next].jdztag == 1 then
					---确定地主
					roomtablelogic.setdizhu(tableobj,next_action_index_next)
					return
				end
			else
				tableobj.action_seat_index = next_action_index
				tableobj.action_type = EActionType.ACTION_TYPE_QIANGDIZHU
			end
		elseif tableobj.action_type == EActionType.ACTION_TYPE_QIANGDIZHU then
			seat.jdztag = 2 ----表示当前玩家已经抢过地主了
			tableobj.noputsCardsNum = 0
			tableobj.baseTimes = tableobj.baseTimes * 2
			local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
			roomtablelogic.sendHandsInfo(tableobj)
			---判断下一家是否抢过,如果抢过则,强地主规则结束
			filelog.sys_error("------玩家抢地主-----",tableobj.action_seat_index,tableobj.seats[tableobj.action_seat_index].jdztag,
				next_action_index,tableobj.seats[next_action_index].jdztag,next_action_index_next,tableobj.seats[next_action_index_next].jdztag)
			if tableobj.seats[next_action_index].jdztag == 2 then
				---确定地主
				roomtablelogic.setdizhu(tableobj,tableobj.action_seat_index)
				return
			elseif tableobj.seats[next_action_index].jdztag == 1 then
				---通知下一家玩家抢地主
				filelog.sys_error("------通知下一家玩家抢地主-----",next_action_index,tableobj.action_seat_index,next_action_index_next)
				tableobj.action_seat_index = next_action_index
				tableobj.action_type = EActionType.ACTION_TYPE_QIANGDIZHU
			elseif tableobj.seats[next_action_index].jdztag < 0 then
				if tableobj.seats[next_action_index_next].jdztag == 2 then
					---确定地主
					roomtablelogic.setdizhu(tableobj,tableobj.action_seat_index)
					return
				elseif tableobj.seats[next_action_index_next].jdztag == 1 then
					tableobj.action_seat_index = next_action_index_next
					tableobj.action_type = EActionType.ACTION_TYPE_QIANGDIZHU
				end
			else
				tableobj.action_seat_index = next_action_index
				tableobj.action_type = EActionType.ACTION_TYPE_QIANGDIZHU
			end
		end
		filelog.sys_error(" -------不叫地主的玩家数---------",tableobj.noputsCardsNum)
		if tableobj.noputsCardsNum >= 3 then
			----玩家都不叫地主，重新发牌
			roomtablelogic.noonejdz(tableobj)
			return
		end
	elseif tableobj.state == ETableState.TABLE_STATE_ONE_GAME_START then
		---通知下一位玩家跟牌
		if tableobj.action_type == EActionType.ACTION_TYPE_CHUPAI then
			tableobj.noputsCardsNum = 0
			tableobj.action_type = EActionType.ACTION_TYPE_FOLLOW_CHUPAI
		elseif tableobj.action_type == EActionType.ACTION_TYPE_CHECK or tableobj.action_type == EActionType.ACTION_TYPE_TIMEOUT_FOLLOW_CHUPAI then
			tableobj.noputsCardsNum =  tableobj.noputsCardsNum + 1
			if tableobj.noputsCardsNum == 2 then
				tableobj.action_type = EActionType.ACTION_TYPE_CHUPAI
			else
				tableobj.action_type = EActionType.ACTION_TYPE_FOLLOW_CHUPAI
			end
		elseif tableobj.action_type == EActionType.	ACTION_TYPE_FOLLOW_CHUPAI then
			tableobj.noputsCardsNum = 0
		end
		filelog.sys_error(" 出牌或者跟牌,或者让牌后",tableobj.action_seat_index,next_action_index,tableobj.noputsCardsNum,tableobj.action_type)
		tableobj.action_seat_index = next_action_index
	end

	--通知下一个玩家操作下发当前玩家操作协议
	tableobj.action_to_time = timetool.get_time() + tableobj.conf.action_timeout
	local doactionntcmsg = {
		rid = tableobj.seats[tableobj.action_seat_index].rid,
		roomsvr_seat_index = tableobj.action_seat_index,
		action_type = tableobj.action_type,
		action_to_time = tableobj.action_to_time,
	}
	filelog.sys_error(" doacton boardcost DoactionNtc ===",doactionntcmsg," tableobj .state === ",tableobj.state)
	msghelper:sendmsg_to_alltableplayer("DoactionNtc", doactionntcmsg)
	if tableobj.seats[tableobj.action_seat_index].is_tuoguan == EBOOL.TRUE then
		tableobj.timer_id = timer.settimer(ETuoguanDelayTime.TUOGUAN_DELAY_TIME*100, "doaction", doactionntcmsg)
	else
		tableobj.timer_id = timer.settimer(tableobj.conf.action_timeout*100, "doaction", doactionntcmsg)
	end
	if tableobj.state ~= ETableState.TABLE_STATE_WAIT_PLAYER_JDZ then
		tableobj.state = ETableState.TABLE_STATE_WAIT_CLIENT_ACTION
	end
end

function RoomGameLogic.continue_and_standup(gameobj)
	RoomGameLogic.continue(gameobj)
end

function RoomGameLogic.continue_and_leave(gameobj)
	filelog.sys_error("RoomGameLogic.continue_and_leave")
end


function RoomGameLogic.onegameend(gameobj)
	filelog.sys_error("RoomGameLogic.onegameend=====")
	-- body
	local tableobj = gameobj.tableobj

	if tableobj.timer_id >0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end
	----通知玩家游戏结束了
	if tableobj.action_type == EActionType.ACTION_TYPE_CHUPAI or tableobj.action_type == EActionType.ACTION_TYPE_FOLLOW_CHUPAI then
		local dizhuiswin = 0
		----判断最后一手是地主还是农民
		if tableobj.seats[tableobj.action_seat_index].isdz == EBOOL.FALSE then
			dizhuiswin = 0
		else
			dizhuiswin = 1
		end
		for k,v in ipairs(tableobj.seats) do
			if v.isdz == EBOOL.FALSE then
				v.win = ( dizhuiswin==1 ) and 0 or 1
			else
				v.win = ( dizhuiswin==1 ) and 1 or 0
			end
		end
		----结果结算逻辑处理部分
		local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
		roomtablelogic.balancegame(tableobj)
		local GameEndResultNtcmsg = {
			basecoins = tableobj.conf.base_coin,
			times = tableobj.baseTimes,
			playerinfos = nil,
		}
		GameEndResultNtcmsg.playerinfos = {}
		msghelper:copy_playerinfoingameend(GameEndResultNtcmsg.playerinfos)
		filelog.sys_error("---------游戏结束了-----------------",GameEndResultNtcmsg)
		msghelper:sendmsg_to_alltableplayer("GameEndResultNtc", GameEndResultNtcmsg)
	end
	local gameendmsg = {

	}
	---设置定时器，用于客户端展示牌局游戏结果界面
	tableobj.timer_id = timer.settimer(2*100, "onegameend", gameendmsg)
	---切换桌子状态为等待定时器结束
	local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
	for k,value in ipairs(tableobj.seats) do
		roomseatlogic.resetstate(value)
	end
	tableobj.state = ETableState.TABLE_STATE_WAIT_ONE_GAME_REAL_END
end

function RoomGameLogic.onegamerealend(gameobj)
	filelog.sys_error("RoomGameLogic.onegamerealend")
	-- body
	local tableobj = gameobj.tableobj

	if tableobj.timer_id >0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end

	local noticeDoReadymsg = {
		rid = 0,
		roomsvr_seat_index = 0,
		ready_to_time = 0,
	}
	for k,v in ipairs(tableobj.seats) do
		if v.rid ~= 0 and v.state == ESeatState.SEAT_STATE_WAIT_READY then
			noticeDoReadymsg.rid =  v.rid
			noticeDoReadymsg.roomsvr_seat_index = v.index
			noticeDoReadymsg.ready_to_time = timetool.get_time() + tableobj.conf.ready_timeout
			filelog.sys_error("--------游戏结束后通知玩家准备-------------------",noticeDoReadymsg)
			msghelper:sendmsg_to_alltableplayer("DoReadyNtc",noticeDoReadymsg)
			if v.ready_timer_id > 0 then
				timer.cleartimer(v.ready_timer_id)
				v.ready_timer_id = -1
			end
			local outoftimermsg = {
				rid = v.rid,
				roomsvr_seat_index = v.index,
			}
			----每个玩家增加准备倒计时定时器
			v.ready_timer_id = timer.settimer(tableobj.conf.ready_timeout*100, "doready", outoftimermsg)
		end
	end
	tableobj.state = ETableState.TABLE_STATE_WAIT_ALL_READY
	-- local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
	-- roomtablelogic.saveGamerecords(tableobj)
end

function RoomGameLogic.gameend(gameobj)
	local tableobj = gameobj.tableobj
	filelog.sys_error("RoomGameLogic.gameend")
	local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
	----重置桌子状态为等待玩家准备开始游戏的状态
	roomtablelogic.resetTable(tableobj)
end

function RoomGameLogic.onsitdowntable(gameobj, seat)
	filelog.sys_error("RoomGameLogic.onsitdowntable")
end

function RoomGameLogic.is_ingame(gameobj, seat)
	return (seat.state == ESeatState.SEAT_STATE_PLAYING
			or seat.state == ESeatState.SEAT_STATE_CHECK
			or seat.state == ESeatState.SEAT_STATE_CHUPAI
			or seat.state == ESeatState.SEAT_STATE_FOLLOW_CHUPAI
			or seat.state == ESeatState.SEAT_STATE_TAOPAO)
end

function RoomGameLogic.onegamestart_inittable(gameobj)
	local tableobj = gameobj.tableobj
	tableobj.action_seat_index = 0
	tableobj.action_to_time = 0
	tableobj.action_type = 0
	tableobj.dz_seat_index = 0
	if tableobj.ddzgame == nil then
		tableobj.ddzgame = ddzgamelogic:new()
	end
	tableobj.initCards = nil	   --牌池
	tableobj.baseTimes = tableobj.conf.common_times
	tableobj.CardsHeaps = nil 		---保存玩家出过的牌的牌堆
	tableobj.jzdbegin_index = 0
	tableobj.noputsCardsNum = 0
	tableobj.iswilldelete = 0
	tableobj.nojdznums = 0
	if tableobj.timer_id >= 0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end

end

function RoomGameLogic.standup_clear_seat(gameobj, seat)
	filelog.sys_error("RoomGameLogic.standup_clear_seat")
	local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
	roomseatlogic.clear_seat(seat)
end

------朋友桌发牌
function RoomGameLogic.RiffleandPostCards(gameobj)
	local tableobj = gameobj
	if tableobj.state == ETableState.TABLE_STATE_WAIT_COUNT_DOWN then
		----生成一副牌
		tableobj.ddzgame.InitCards(tableobj)
		----洗牌
		tableobj.ddzgame.Riffle(tableobj)
		----发牌
		local firstIndex = base.get_random(1,3)
		tableobj.ddzgame.PostCards(tableobj,firstIndex)
		-----发牌给客户端
		local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
		for key,value in pairs(tableobj.seats) do
			if value.state == ESeatState.SEAT_STATE_WAIT_START then
				roomseatlogic.dealcards(value)
				roomseatlogic.onegamestart_initseat(value)
			end
		end
		----设置桌子状态为等待明牌状态
		tableobj.state = ETableState.TABLE_STATE_WAIT_PLAYER_MINGPAI
		tableobj.action_type = EActionType.ACTION_TYPE_MINGPAI
		local roomgamelogic = msghelper:get_game_logic()
		roomgamelogic.run(tableobj.gamelogic)
	end
end

return RoomGameLogic