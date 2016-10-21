local logicmng = require "logicmng"
local tabletool = require "tabletool"
local timetool = require "timetool"
local msghelper = require "tablehelper"
local timer = require "timer"
local filelog = require "filelog"
local msgproxy = require "msgproxy"
local base = require "base"
local playerdatadao = require "playerdatadao"
require "enum"
local RoomTableLogic = {}

function RoomTableLogic.init(tableobj, conf, roomsvr_id)
	if conf == nil or roomsvr_id == nil then
		filelog.sys_error("RoomTableLogic.init conf == nil", conf, roomsvr_id)
		return false
	end

	local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
	tableobj.id = conf.id
	tableobj.svr_id = roomsvr_id



	local seatobj = require("object.seatobj")
	local seat
	local count = 1
    while count <= conf.max_player_num do
    	seat = seatobj:new({
    		--Add 座位其他变量
    		timeout_count = 0, --超时次数
    		--[[
				EWinResult = {
					WIN_RESULT_UNKNOW = 0,
					WIN_RESULT_WIN = 1,
					WIN_RESULT_LOSE = 2,
				}
    		]]
    		win = 0,             --表示玩家胜利还是失败
    		jdztag = 0,          --记录叫地主标识(不叫地址值为0, 1表示叫地主, 2表示抢地主)
    		isdz = EBOOL.FALSE,  --记录是否是地主
    		coin = 0,
    		ready_timer_id = -1, --准备倒计时定时器
    		ready_to_time = 0,   --准备到期时间
			cards = {},		     --玩家手牌
			ismingpai = 0,		 --是否明牌
			nojdznums = 0,		 ---玩家都不叫地主,重新发牌,同时该变量+1，当大于配置数时，随机选取地主
    	})
    	roomseatlogic.init(seat, count)
    	table.insert(tableobj.seats, seat) 
		count = count + 1
    end

    tableobj.conf = tabletool.deepcopy(conf)
	tableobj.baseTimes = conf.common_times
	local roomgamelogic = msghelper:get_game_logic()
	local game = require("object.gameobj")
	tableobj.gamelogic = game:new()
	roomgamelogic.init(tableobj.gamelogic, tableobj)

	----初始化桌子战绩记录
	RoomTableLogic.initGamerecords(tableobj)

	if conf.retain_time ~= nil and conf.retain_time > 0 then
		if tableobj.delete_table_timer_id > 0 then
			timer.cleartimer(tableobj.delete_table_timer_id)
			tableobj.delete_table_timer_id = -1
		end
    	tableobj.delete_table_timer_id = timer.settimer(conf.retain_time*100, "delete_table")
		tableobj.retain_to_time = timetool.get_time() + conf.retain_time
    end
    tableobj.state = ETableState.TABLE_STATE_GAME_START
    roomgamelogic.run(tableobj.gamelogic)

	return true
end

function RoomTableLogic.clear(tableobj)
	if tableobj.timer_id > 0 then
		timer.cleartimer(tableobj.timer_id)
		tableobj.timer_id = -1
	end

	if tableobj.delete_table_timer_id > 0 then
		timer.cleartimer(tableobj.delete_table_timer_id)
		tableobj.delete_table_timer_id = -1
	end

	for _, seat in ipairs(tableobj.seats) do
		if seat.ready_timer_id > 0 then
			timer.cleartimer(seat.ready_timer_id)
			seat.ready_timer_id = -1
		end
	end

	for k,v in pairs(tableobj) do
		tableobj[k] = nil
	end
	tableobj.gamerecords = nil
end

--[[
	seat: nil表示否， 非nil表示是
]]
function RoomTableLogic.entertable(tableobj, request, seat)
	if seat and seat.is_tuoguan == EBOOL.TRUE then
		seat.is_tuoguan = EBOOL.FALSE

		--TO ADD 视情况添加解除托管处理 
	else
		local waitinfo = tableobj.waits[request.rid]
		if waitinfo == nil then
			tableobj.waits[request.rid] = {}
			waitinfo = tableobj.waits[request.rid]
			waitinfo.playerinfo = {}
			tableobj.waits[request.rid] = waitinfo			
		end
		waitinfo.rid = request.rid
		waitinfo.gatesvr_id = request.gatesvr_id
		waitinfo.agent_address = request.agent_address
		waitinfo.playerinfo.rolename=request.playerinfo.rolename
		waitinfo.playerinfo.logo=request.playerinfo.rolename
		waitinfo.playerinfo.sex=request.playerinfo.sex
	end
end

function RoomTableLogic.reentertable(tableobj, request, seat)
	
	if not RoomTableLogic.is_onegameend(tableobj) then
		--如果在游戏中需要将手牌发给玩家		
		local reentablemsg = {
			handcards = nil,
			dealcards = {},
			cardsput = {},
			action_type = tableobj.action_type,
			action_to_time = tableobj.action_to_time,
			action_seat_index = tableobj.action_seat_index,
		}
		reentablemsg.handcards = tabletool.deepcopy(seat.cards)
        filelog.sys_error("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx====",tableobj.state)
        if tableobj.initCards and type(tableobj.initCards)== "table" and
                (tableobj.state ~= ETableState.TABLE_STATE_WAIT_PLAYER_JDZ and tableobj.state ~= ETableState.TABLE_STATE_PLAYER_JDZ) then
		    for k,v in ipairs(tableobj.initCards) do
			    table.insert(reentablemsg.dealcards,v)
            end
        end
		for k,value in ipairs(tableobj.seats) do
			local noticemsg = {
				rid = value.rid,
				putcards = {}
			}
			if value.state == ESeatState.SEAT_STATE_CHUPAI or value.state == ESeatState.SEAT_STATE_FOLLOW_CHUPAI then
				local roundtable = tableobj.CardsHeaps[#tableobj.CardsHeaps]
				for i = #roundtable,1,-1 do
					if 	roundtable[i].rid == value.rid then
						for m,n in ipairs(roundtable[i].cardHelper) do
							table.insert(noticemsg.putcards,n)
						end
						break
					end
				end
			end
			table.insert(reentablemsg.cardsput,noticemsg)
		end
		msghelper:sendmsg_to_tableplayer(seat, "ReenterTableNtc", reentablemsg)
		filelog.sys_error("----------------------断线重连---------------------",reentablemsg)
		--通知玩家当前该他操作
        if tableobj.action_seat_index == 0 then return end
		local doactionntcmsg = {
			rid = tableobj.seats[tableobj.action_seat_index].rid,
			roomsvr_seat_index = tableobj.action_seat_index,
			action_to_time = tableobj.action_to_time,
			action_type = tableobj.action_type,
		}
		msghelper:sendmsg_to_tableplayer(seat, "DoactionNtc", doactionntcmsg)
	end
end

--被动离开桌子，使用该接口时玩家必须是在旁观中
--记住使用者如果循环遍历旁观队列一定要使用原队列的copy队列
function RoomTableLogic.passive_leavetable(tableobj, rid, is_sendto_client)
	local leavetablemsg = {
		roomsvr_id = tableobj.svr_id,
		roomsvr_table_id = tableobj.id,
		roomsvr_table_address = skynet.self(),
		is_sendto_client = is_sendto_client,
		rid = rid,
	}
	msghelper:sendmsg_to_waitplayer(tableobj.waits[rid], "leavetable", leavetablemsg)
	tableobj.waits[rid] = nil	
end

function RoomTableLogic.leavetable(tableobj, request, seat)
	tableobj.waits[request.rid] = nil
end

--[[

--]]
function RoomTableLogic.sitdowntable(tableobj, request, seat)
	tableobj.waits[request.rid] = nil

	---filelog.sys_error("-------------sitdowntable---------------",request.coin)
	seat.rid = request.rid
	seat.gatesvr_id=request.gatesvr_id
	seat.agent_address = request.agent_address
	seat.playerinfo.rolename=request.playerinfo.rolename
	seat.playerinfo.logo=request.playerinfo.logo
	seat.playerinfo.sex=request.playerinfo.sex
	seat.playerinfo.totalgamenum = request.playerinfo.totalgamenum
	seat.playerinfo.winnum = request.playerinfo.winnum
	seat.playerinfo.highwininseries = request.playerinfo.highwininseries
	seat.playerinfo.maxcoinnum = request.playerinfo.maxcoinnum
	seat.playerinfo.coins = request.playerinfo.coins
	seat.playerinfo.diamonds = request.playerinfo.diamonds

	seat.state = ESeatState.SEAT_STATE_WAIT_READY
	seat.coin = request.coin
	seat.ready_to_time = timetool.get_time() + tableobj.conf.ready_timeout

	local noticemsg = {
		rid = seat.rid,
		seatinfo = {},
		tableplayerinfo = {},
	}
	msghelper:copy_seatinfo(noticemsg.seatinfo, seat)
	msghelper:copy_tableplayerinfo(noticemsg.tableplayerinfo, seat)
	msghelper:sendmsg_to_alltableplayer("SitdownTableNtc", noticemsg)

	if seat.is_tuoguan == EBOOL.TRUE then
		seat.is_tuoguan = EBOOL.FALSE
		--TO ADD 添加托管处理
	end

	if seat.ready_timer_id > 0 then
		timer.cleartimer(seat.ready_timer_id)
		seat.ready_timer_id = -1
	end
	local outoftimermsg = {
		rid = seat.rid,
		roomsvr_seat_index = seat.index,
	}
	seat.ready_timer_id = timer.settimer(tableobj.conf.ready_timeout*100, "doready", outoftimermsg)
    seat.ready_to_time = timetool.get_time() + tableobj.conf.ready_timeout
	local doreadyntcmsg = {
		rid = seat.rid,
		roomsvr_seat_index = seat.index,
		ready_to_time = timetool.get_time() + tableobj.conf.ready_timeout,
	}
	msghelper:sendmsg_to_alltableplayer("DoReadyNtc", doreadyntcmsg)	

	local roomgamelogic = logicmng.get_logicbyname("roomgamelogic")
    filelog.sys_error("---------sitdowntable----------",tableobj.state)
	roomgamelogic.onsitdowntable(tableobj.gamelogic, seat)
    if tableobj.state == ETableState.TABLE_STATE_WAIT_PLAYER_SITDOWN then
        tableobj.state = ETableState.TABLE_STATE_WAIT_ALL_READY
    end
	msghelper:report_table_state()

end

function RoomTableLogic.passive_standuptable(tableobj, request, seat, reason)
	local roomgamelogic = msghelper:get_game_logic()
    local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
	local table_data = tableobj

	if not RoomTableLogic.is_onegameend(tableobj) then
		----判断一下座位上是农民还是地主,如果是地主则，直接结束游戏
		seat.is_tuoguan = EBOOL.TRUE
		return
	end

	tableobj.sitdown_player_num = tableobj.sitdown_player_num - 1 

	local standuptablemsg = {
		rid = seat.rid,
		roomsvr_id = table_data.svr_id,
		roomsvr_seat_index = seat.index,
		roomsvr_table_id = table_data.id,
	}
	msghelper:sendmsg_to_tableplayer(seat, "standuptable", standuptablemsg)

	local noticemsg = {
		rid = seat.rid, 
		roomsvr_seat_index = seat.index,
		state = seat.state,
		reason = reason,
	}

	msghelper:sendmsg_to_alltableplayer("StandupTableNtc", noticemsg)

	seat.state = ESeatState.SEAT_STATE_NO_PLAYER

	if tableobj.waits[seat.rid] == nil then
		local waitinfo = {
			playerinfo = {},
		}
		tableobj.waits[seat.rid] = waitinfo

		waitinfo.rid = seat.rid
		waitinfo.gatesvr_id = seat.gatesvr_id
		waitinfo.agent_address = seat.agent_address
		waitinfo.playerinfo.rolename=seat.playerinfo.rolename
		waitinfo.playerinfo.logo=seat.playerinfo.rolename
		waitinfo.playerinfo.sex=seat.playerinfo.sex
	end
	--初始化座位数据
	roomgamelogic.standup_clear_seat(tableobj.gamelogic, seat)

	msghelper:report_table_state()
end

function RoomTableLogic.standuptable(tableobj, request, seat)
	local roomgamelogic = msghelper:get_game_logic()

	if not RoomTableLogic.is_onegameend(tableobj) then
		seat.is_tuoguan = EBOOL.TRUE
		return
	end
	tableobj.sitdown_player_num = tableobj.sitdown_player_num - 1
	local noticemsg = {
		rid = seat.rid, 
		roomsvr_seat_index = seat.index,
		state = seat.state,
		reason = EStandupReason.STANDUP_REASON_ONSTANDUP,
	}
	msghelper:sendmsg_to_alltableplayer("StandupTableNtc", noticemsg)
	seat.state = ESeatState.SEAT_STATE_NO_PLAYER
	if tableobj.waits[seat.rid] == nil then
		local waitinfo = {
			playerinfo = {},
		}
		tableobj.waits[seat.rid] = waitinfo
		waitinfo.rid = seat.rid
		waitinfo.gatesvr_id = seat.gatesvr_id
		waitinfo.agent_address = seat.agent_address
		waitinfo.playerinfo.rolename=seat.playerinfo.rolename
		waitinfo.playerinfo.logo=seat.playerinfo.rolename
		waitinfo.playerinfo.sex=seat.playerinfo.sex
	end


	--初始化座位数据
	roomgamelogic.standup_clear_seat(tableobj.gamelogic, seat)
	msghelper:report_table_state()
end

function RoomTableLogic.startgame(tableobj, request)
	if RoomTableLogic.is_canstartgame(tableobj) then
		local roomgamelogic = logicmng.get_logicbyname("roomgamelogic")
		tableobj.state = ETableState.TABLE_STATE_GAME_START
		roomgamelogic.run(tableobj.gamelogic)
	else
		table_data.state = ETableState.TABLE_STATE_WAIT_MIN_PLAYER
	end
end

function RoomTableLogic.doaction(tableobj, request, seat)
	tableobj.action_type = request.action_type
	tableobj.state = ETableState.TABLE_STATE_CONTINUE
	local roomgamelogic = msghelper:get_game_logic()
	roomgamelogic.run(tableobj.gamelogic)
end

function RoomTableLogic.disconnect(tableobj, request, seat)
	seat.gatesvr_id = ""
	seat.agent_address = -1
	seat.is_tuoguan = EBOOL.TRUE
	--TO ADD添加玩家掉线处理
    --将玩家站起
    ---测试需要将玩家站起后踢掉
    seat.ready_to_time = 0
    local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
    roomtablelogic.passive_standuptable(tableobj, request, seat, EStandupReason.STANDUP_REASON_DISCONNECTED)
end

function RoomTableLogic.standupallplayer(tableobj,reason)
	local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
	for k,value in ipairs(tableobj.seats) do
		roomtablelogic.passive_standuptable(tableobj, nil, value, reason)
	end
end

function RoomTableLogic.get_svr_id(tableobj)
	return tableobj.svr_id
end

function RoomTableLogic.get_sitdown_player_num(tableobj)
	return tableobj.sitdown_player_num
end

--根据指定桌位号获得一张空座位
function RoomTableLogic.get_emptyseat_by_index(tableobj, index)
	local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
	if index == nil or index <= 0 or index > tableobj.conf.max_player_num then
		for index, seat in pairs(tableobj.seats) do
			if roomseatlogic.is_empty(seat) then
				return seat
			end
		end
	else
		local seat = tableobj.seats[index]
		if roomseatlogic.is_empty(seat) then
			return seat
		end
	end
	return nil
end

function RoomTableLogic.get_seat_by_rid(tableobj, rid)
	for index, seat in pairs(tableobj.seats) do
		if rid == seat.rid then
			return seat
		end
	end
	return nil
end

--判断桌子是否满了
function RoomTableLogic.is_full(tableobj)
	return (tableobj.sitdown_player_num >= tableobj.conf.max_player_num)
end

--判断当前是否能够开始游戏
function RoomTableLogic.is_canstartgame(tableobj)
	return RoomTableLogic.is_full(tableobj)
end

--判断游戏是否结束
function RoomTableLogic.is_gameend(tableobj)
	if tableobj.state == ETableState.TABLE_STATE_GAME_END
            or tableobj.state == ETableState.TABLE_STATE_WAIT_ALL_READY then
		return true
	end

	return false
end

--判断当前局是否已经结束游戏
function RoomTableLogic.is_onegameend(tableobj)
	if tableobj.state == ETableState.TABLE_STATE_ONE_GAME_END 
		or tableobj.state == ETableState.TABLE_STATE_ONE_GAME_REAL_END then
		return true
	end

	if tableobj.state == ETableState.TABLE_STATE_WAIT_GAME_END 
		or tableobj.state == ETableState.TABLE_STATE_WAIT_ONE_GAME_REAL_END then
		return true
	end

	return RoomTableLogic.is_gameend(tableobj)
end

----玩家准备
function RoomTableLogic.gameready(tableobj, request, seat)
    filelog.sys_error("-----------RoomTableLogic.gameready-------------",tableobj.state)
	if tableobj.state ~= ETableState.TABLE_STATE_WAIT_ALL_READY then
		return
	end
	local noticemsg = {
		rid = seat.rid,
		roomsvr_seat_index = seat.index,
		isready = 0,
	}
	if seat.state == ESeatState.SEAT_STATE_WAIT_START then noticemsg.isready = 1 end
	msghelper:sendmsg_to_alltableplayer("GameReadyResultNtc", noticemsg)
	local isallready = true
	for k, v in ipairs(tableobj.seats) do
		if v.state ~= ESeatState.SEAT_STATE_WAIT_START then
			isallready = false
			break
		end
	end
	if isallready and tableobj.state == ETableState.TABLE_STATE_WAIT_ALL_READY then
		---如果桌子状态是等待玩家开始的状态,且所有玩家都准备好了,则桌子进入开始倒计时状态
		tableobj.state = ETableState.TABLE_STATE_ONE_GAME_START
		local roomgamelogic = msghelper:get_game_logic()
		roomgamelogic.run(tableobj.gamelogic)
		msghelper:report_table_state()
	end

end

function RoomTableLogic.balancegame(tableobj)
	if tableobj.state ~= ETableState.TABLE_STATE_ONE_GAME_END then
		return
	end
	local roomseatlogic = logicmng.get_logicbyname("roomseatlogic")
	local basevalue = math.floor(tableobj.baseTimes * tableobj.conf.base_coin)
	for k,value in ipairs(tableobj.seats) do
		local getvalue = 0
		if value.win == 0 then
			if value.isdz == 0 then
				getvalue = 0 - basevalue
			elseif value.isdz == 1 then
				getvalue = 0 - 2 * basevalue
			end
		elseif value.win == 1 then
			if value.isdz == 0 then
				getvalue = basevalue
			elseif value.isdz == 1 then
				getvalue = 2 * basevalue
			end
		end
		if value.coin + getvalue >= 0 then
			value.coin = value.coin + getvalue
		else
			value.coin = 0
		end
		roomseatlogic.balancegame(value,getvalue)
		if tableobj.conf.room_type==ERoomType.ROOM_TYPE_FRIEND_COMMON then
			if tableobj.gamerecords == nil then RoomTableLogic.initGamerecords(tableobj) end
			local onerecordmsg = {}
			onerecordmsg.rid = value.rid
			onerecordmsg.currencyid = ECurrencyType.CURRENCY_TYPE_COIN
			onerecordmsg.balancenum = getvalue
			onerecordmsg.rolename = value.playerinfo.rolename
			local hasplayerkey = 0
			for k,v in ipairs(tableobj.gamerecords) do
				if v.rid == value.rid then
					hasplayerkey = k
					break
				end
			end
			if hasplayerkey == 0 then
				table.insert(tableobj.gamerecords,onerecordmsg)
			elseif hasplayerkey > 0 then
				local playerrecord = tableobj.gamerecords[hasplayerkey]
				if playerrecord then
					playerrecord.balancenum = playerrecord.balancenum + getvalue
					playerrecord.rolename = value.playerinfo.rolename
				end
			end
		end
		---roomseatlogic.changeCurrency(value,ECurrencyType.CURRENCY_TYPE_COIN,getvalue,EReasonChangeCurrency.CHANGE_CURRENCY_NORMAL_GAME)
	end
end
----玩家出牌超时服务器处理为出一张最小的单牌
function RoomTableLogic.putCards(tableobj)
	local seatIndex = tableobj.action_seat_index
	local seat = tableobj.seats[seatIndex]
	if (not seat.cards) or #seat.cards <= 0 then
		return
	end
	local cards = { seat.cards[#seat.cards] }
	local cardHelper = tableobj.ddzgame.CreateCardsHelper(cards)
	cardHelper:GetCardsType(cardHelper)
	if cardHelper.m_eCardType ~= ECardType.DDZ_CARD_TYPE_UNKNOWN then
		----加入牌堆中
		table.remove(seat.cards,#seat.cards)
		if tableobj.CardsHeaps == nil then
			tableobj.CardsHeaps = {}
			tableobj.CardsHeaps[#tableobj.CardsHeaps+1] = {}
		end
		local heapOne = {
			rid = seat.rid,
			cardHelper = tabletool.deepcopy(cardHelper)
		}
		table.insert(tableobj.CardsHeaps[#tableobj.CardsHeaps],heapOne)
	end
end

function RoomTableLogic.sendGameStart(tableobj)
	local gamestartntcmsg = {}
	gamestartntcmsg.gameinfo = {}
	msghelper:copy_table_gameinfo(gamestartntcmsg.gameinfo)
	msghelper:sendmsg_to_alltableplayer("GameStartNtc", gamestartntcmsg)
end

function RoomTableLogic.sendHandsInfo(tableobj)
	local handsInfo = {}
	handsInfo.basecoins = tableobj.conf.base_coin
	handsInfo.times = tableobj.baseTimes
	handsInfo.seats = {}
	for k,v in ipairs(tableobj.seats) do
		local seatInfo = {}
		msghelper:copy_seatinfo(seatInfo,v)
		table.insert(handsInfo.seats,seatInfo)
	end
	msghelper:sendmsg_to_alltableplayer("PushhandsNumNtc",handsInfo)
end

function RoomTableLogic.resetTable(tableobj)
	if tableobj.iswilldelete == 1 then
		msghelper:event_process("lua", "cmd", "delete","gameover")
	end
	tableobj.state = ETableState.TABLE_STATE_GAME_START
	tableobj.action_type =  0		--玩家当前操作类型
	tableobj.initCards = nil		--牌池
	tableobj.jzdbegin_index = 0
	tableobj.CardsHeaps = nil		--保存玩家出过的牌的牌堆
	tableobj.retain_to_time = 0		 		--桌子保留到的时间(linux时间擢)
	tableobj.action_seat_index = 0			--当前操作玩家的座位号
	tableobj.action_to_time = 0				--当前操作玩家的到期时间
	tableobj.ddzgame = nil 		--棋牌
	tableobj.dz_seat_index = 0				--记录当前的地主座位号
	tableobj.baseTimes = 0		   	-- 基础倍数
	tableobj.noputsCardsNum = 0		---一个出牌回合里,没有出牌的玩家数,不出+1，出牌则置0
	tableobj.iswilldelete = 0 	---在游戏中如果收到删除指令,则置1,游戏结束再处理
	tableobj.nojdznums = 0
	---踢出还在托管状态的玩家
--	local roomtablelogic = logicmng.get_logicbyname("roomtablelogic")
--	for k,v in ipairs(tableobj.seats) do
--		if v.is_tuoguan == 1 then
--			roomtablelogic.passive_standuptable(tableobj, nil, v, EStandupReason.STANDUP_REASON_READYTIMEOUT_STANDUP)
--		end
--	end
	---RoomTableLogic.saveGamerecords(tableobj)
end

function RoomTableLogic.isQiangdz(tableobj)
	return (tableobj.action_type == EActionType.ACTION_TYPE_JIAODIZHU or tableobj.action_type == EActionType.ACTION_TYPE_QIANGDIZHU
				or tableobj.action_type == EActionType.ACTION_TYPE_TIMEOUT_JDZ or tableobj.action_type == EActionType.ACTION_TYPE_TIMEOUT_QIANGDIZHU
					or tableobj.action_type == EActionType.ACTION_TYPE_BUJIAO_DIZHU or tableobj.action_type == EActionType.ACTION_TYPE_BUQIANGDIZHU )
end

function RoomTableLogic.setdizhu(tableobj,seatindex)
	tableobj.dz_seat_index = seatindex
	tableobj.action_seat_index = seatindex
	tableobj.seats[seatindex].isdz = EBOOL.TRUE
	tableobj.state = ETableState.TABLE_STATE_WAIT_PLAYER_CHUPAI
	local roomgamelogic = msghelper:get_game_logic()
	roomgamelogic.run(tableobj.gamelogic)
end

function RoomTableLogic.noonejdz(tableobj)
	if tableobj.nojdznums >= EPushcardsType.COMMOM_LAST_TIMES then
		tableobj.nojdznums = 0
		local tmp_seed = base.RNG()
		if tmp_seed == nil then
			tmp_seed = timetool.get_10ms_time()
		end
		math.randomseed(tmp_seed)
		local randomIndex = base.get_random(1,#tableobj.seats)
		RoomTableLogic.setdizhu(tableobj,randomIndex)
		return
	end
	tableobj.initCards = nil
	for k,v in ipairs(tableobj.seats) do
		if type(v.cards) == "table" and #v.cards > 0 then
			v.state = ESeatState.SEAT_STATE_WAIT_START
			v.jdztag = 0
			v.cards = {}
		end
	end
	tableobj.nojdznums = tableobj.nojdznums + 1
	tableobj.noputsCardsNum = 0
	tableobj.state = ETableState.TABLE_STATE_WAIT_START_COUNT_DOWN
	local roomgamelogic = msghelper:get_game_logic()
	roomgamelogic.run(tableobj.gamelogic)
end

function RoomTableLogic.putCardInheaps(tableobj,actiontype,cardhelper)
end

function RoomTableLogic.setallseatstate(tableobj, state)
    for k,value in ipairs(tableobj.seats) do
        value.state = state
    end
end

----初始化牌桌战绩记录
function RoomTableLogic.initGamerecords(tableobj)
	-- body
	if tableobj.conf.room_type == ERoomType.ROOM_TYPE_FRIEND_COMMON and tableobj.gamerecords == nil then
		tableobj.gamerecords = {}
	end
end

function RoomTableLogic.saveGamerecords(tableobj)
	-- body
	filelog.sys_error("-------------saveGamerecords------------------",tableobj.conf.room_type,"++++++++++++",
		tableobj.gamerecords)
	if tableobj.conf.room_type == ERoomType.ROOM_TYPE_FRIEND_COMMON then
		if tableobj.gamerecords and type(tableobj.gamerecords) == "table" then
			for k,value in ipairs(tableobj.gamerecords) do
				local tablerecords = {}
				tablerecords.table_create_time = tableobj.conf.create_user_rid
				tablerecords.id = ""..tostring(tableobj.id)..tostring(tableobj.conf.create_user_rid)..tostring(value.rid)..tostring(timetool.get_time())
				tablerecords.table_id = tableobj.id
				tablerecords.table_create_time = tableobj.conf.create_time
				tablerecords.tablecreater_rid = tableobj.conf.create_user_rid
				tablerecords.rid = value.rid
				tablerecords.record = tabletool.deepcopy(tableobj.gamerecords)
				---msgproxy.sendrpc_noticemsgto_gatesvrd()
				filelog.sys_error("-------------saveGamerecords------------------",tablerecords)
				playerdatadao.save_player_tablerecords("insert",value.rid,tablerecords)
			end
		end
	end
end

function RoomTableLogic.insertGamerecords()
	-- body

end

return RoomTableLogic