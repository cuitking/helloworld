local skynet = require "skynet"
local msghelper = require "tablestatesvrhelper"
local base = require "base"
local serverbase = require "serverbase"
local table = table
require "enum"
require "skynet.manager"

local params = ...

--构建和桌子人数对应的索引
local function build_tableplayernum_indexs()
	--[=[
	[room_type] = {
		[game_type] = {
			1,2,...5 指人数，5表示空
		    [1]={
				--[[
					id=true,
				]]
			},
			[2]={},
			……
			[5]={},
		},
	]=]
	local t = {}
	local room_types = {
		ERoomType.ROOM_TYPE_COMMON,
	}

	local game_types = {
		EGameType.GAME_TYPE_DDZ_NEW_PLAYER,	---新手场
		EGameType.GAME_TYPE_DDZ_PRIMARY,	    ---初级场
		EGameType.GAME_TYPE_DDZ_INTERMEDIATE,	---中级场
		EGameType.GAME_TYPE_DDZ_ADVANCED,	    ---高级场
		EGameType.GAME_TYPE_DDZ_QUICK,	    ---快速场
	}
	for _, room_type in pairs(room_types) do
		t[room_type] = {}
		for _, game_type in pairs(game_types) do
			t[room_type][game_type] = {}
			for playernum = 1, 5 do
				t[room_type][game_type][playernum] = {}
			end
		end
	end
	return t
end

local TableStatesvrd = serverbase:new({
	table_pool = {
		--[[
			[id] = {
				id = 0,
				state = 0,
				name = "",
				room_type = 0,
				game_type = 0,
				max_player_num = 0,
				cur_player_num = 0,
				game_time = 0, 棋局限时
				
				retain_to_time = 0, 桌子保留到的时间(linux时间擢)
				create_user_rid = 0,
				create_user_rolename = "",
				create_time = 0,
				create_table_id = "",
				create_user_logo = "",
				roomsvr_id = "",
				roomsvr_table_address = -1,
			}
		]]
	},

	create_table_indexs = {
		--[[
			[create_table_id] = id
		]]
	},

	--服务器serverid、房间类型、游戏类型相关的索引
	roomsvrs = {
	--[[
		roomsvr_id = {
			room_type = {
				game_type = {
					num=0,		--累计在线人数
					id1,
					id2
				},
			},
			update_time = 0,
		},
	]]
	},

	--根据创建者建立桌子的索引状态
	createusers_table_indexs = {
		--[[
			rid={
				id=true
			}
		]]
	},

	--和桌子人数对应的索引
	tableplayernumindexs = build_tableplayernum_indexs(),
})

function TableStatesvrd:tostring()
	return "TableStatesvrd"
end

local function tablestatesvrd_to_sring()
	return TableStatesvrd:tostring()
end

function  TableStatesvrd:init()
	msghelper:init(TableStatesvrd)
	self.eventmng.init(TableStatesvrd)
	self.eventmng.add_eventbyname("cmd", "tablestatesvrcmd")
	self.eventmng.add_eventbyname("notice", "tablestatesvrnotice")
	self.eventmng.add_eventbyname("request", "tablestatesvrrequest")
	TableStatesvrd.__tostring = tablestatesvrd_to_sring
end 

skynet.start(function()  
	if params == nil then
		TableStatesvrd:start()
	else		
		TableStatesvrd:start(table.unpack(base.strsplit(params, ",")))
	end	
end)
