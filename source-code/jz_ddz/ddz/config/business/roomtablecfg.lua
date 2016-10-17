table_conf_list_1 = {
    begin_id = 10100,
    num  = 50,    
    conf = {
        version = 1,
        room_type = 1,             --桌子的房间类型(新手场)
        game_type = 1,             --游戏的类型(普通游戏)
        min_player_num = 3,        --最少开始游戏人数
        max_player_num = 3,        --桌子座位数
        min_carry_coin = 1000,    --最小带入金币
        max_carry_coin = 0,     --最大带入金币
        name = "新手场",
        action_timeout = 5,      --玩家出牌操作倒计时
        action_timeout_count = -1,
        base_coin = 10,              --基础分数
        common_times = 15,            --公共倍数
        ready_timeout = 30,
    }
}


table_conf_list_2 = {
    begin_id   = 10200,
    num  = 50,    
    conf = {
        version = 1,
        room_type = 1,           --桌子的房间类型(初级场)
        game_type = 2,           --游戏的类型(普通游戏)
        min_player_num = 3,      --最少开始游戏人数
        max_player_num = 3,      --桌子座位数
        min_carry_coin = 1000,    --最小带入金币
        max_carry_coin = 0,   --最大带入金币
        name = "初级场",
        action_timeout = 10,        --玩家出牌操作倒计时
        action_timeout_count = -1,
        base_coin = 20,              --底分
        common_times = 15,            --公共倍数
        ready_timeout = 30,
    }
}

table_conf_list_3 = {
    begin_id  = 10300,
    num  = 50,    
    conf = {
        version = 1,
        room_type = 1,           --桌子的房间类型(中级场)
        game_type = 3,           --游戏的类型(普通游戏)
        min_player_num = 3,      --最少开始游戏人数
        max_player_num = 3,      --桌子座位数
        min_carry_coin = 1000,    --最小带入金币
        max_carry_coin = 0,       --最大带入金币(0为无限制)
        name = "中级场",
        action_timeout = 30,      --玩家出牌超时时间
        action_timeout_count = -1,
        base_coin = 50,            --基础分
        common_times = 15,            --公共倍数
        ready_timeout = 30,
    }
}

table_conf_list_4 = {
    begin_id  = 10400,
    num  = 50,    
    conf = {
        version = 1,
        room_type = 1,           --桌子的房间类型(高级场)
        game_type = 4,           --游戏的类型(普通游戏)
        min_player_num = 3,      --最少开始游戏人数
        max_player_num = 3,      --桌子座位数
        min_carry_coin = 1000,    --最小带入
        max_carry_coin = 0,   --最大带入
        name = "高级场",
        action_timeout = 5,      --玩家出牌超时时间
        action_timeout_count = -1,
        base_coin = 100,         --基础分
        common_times  = 15,       --公共倍数
        ready_timeout = 30,
    }
}
table_conf_list_5 = {
    begin_id  = 10500,
    num  = 50,
    conf = {
        version = 1,
        room_type = 1,           --桌子的房间类型
        game_type = 5,           --游戏的类型(快速游戏)
        min_player_num = 3,      --最少开始游戏人数
        max_player_num = 3,      --桌子座位数
        min_carry_coin = 1000,    --最小带入
        max_carry_coin = 0,   --最大带入
        name = "快速场",
        action_timeout = 5,      --玩家出牌超时时间
        action_timeout_count = -1,
        base_coin = 10,          --基础分
        common_times  = 15,       --公共倍数
        ready_timeout = 30,
    }
}