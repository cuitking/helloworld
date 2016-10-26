
local commonconst = require "common_const"

local tabletool = require "tabletool"
local timetool = require "timetool"
local base = require "base"

local TexasCard = {} 

function TexasCard.compose_card(type, value)
    return type * 13 + value
end

function TexasCard.get_cardtype(card)
    return math.floor(card / 13)
end

function TexasCard.get_cardvalue(card)
    return (card % 13)
end

function TexasCard.issame_cardtype(card1, card2)
    return TexasCard.get_cardtype(card1) == TexasCard.get_cardtype(card2)
end

function TexasCard.issame_cardvalue(card1, card2)
    return TexasCard.get_cardvalue(card1) == TexasCard.get_cardvalue(card2)
end

function TexasCard.card_tostring(card)
    local tmp = nil
    local cardtype = TexasCard.get_cardtype(card)
    if cardtype == commonconst.CARD_TYPE_SPADE then
        tmp = "黑"
    elseif cardtype == commonconst.CARD_TYPE_HEART then
        tmp = "红"
    elseif cardtype == commonconst.CARD_TYPE_DIAMOND then
        tmp = "红"     
    elseif cardtype == commonconst.CARD_TYPE_CLUB then
        tmp = "花"
    else
        tmp = "错"
    end

    local cardvalue = TexasCard.get_cardvalue(card) 

    if cardvalue == commonconst.CARD_VALUE_2 then
        tmp = tmp.."2"        
    elseif cardvalue == commonconst.CARD_VALUE_3 then
        tmp = tmp.."3"                
    elseif cardvalue == commonconst.CARD_VALUE_4 then
        tmp = tmp.."4"                
    elseif cardvalue == commonconst.CARD_VALUE_5 then
        tmp = tmp.."5"                
    elseif cardvalue == commonconst.CARD_VALUE_6 then
        tmp = tmp.."6"                
    elseif cardvalue == commonconst.CARD_VALUE_7 then
        tmp = tmp.."7"                
    elseif cardvalue == commonconst.CARD_VALUE_8 then
        tmp = tmp.."8"                        
    elseif cardvalue == commonconst.CARD_VALUE_9 then
        tmp = tmp.."9"                                
    elseif cardvalue == commonconst.CARD_VALUE_10 then
        tmp = tmp.."10"                                
    elseif cardvalue == commonconst.CARD_VALUE_JACK then
        tmp = tmp.."J"                                
    elseif cardvalue == commonconst.CARD_VALUE_QUEEN then
        tmp = tmp.."Q"                                
    elseif cardvalue == commonconst.CARD_VALUE_KING then
        tmp = tmp.."K"                                        
    elseif cardvalue == commonconst.CARD_VALUE_ACE then
        tmp = tmp.."A"                                                
    else
        tmp = tmp.."X"
    end

    return tmp
end

function TexasCard.cards_tostring(cards)
    local tmp = ""

    for _, card in pairs(cards) do
        tmp = tmp..(TexasCard.card_tostring(card))
    end

    return tmp
end

function TexasCard.parsecard_from_string(str)
    local  card_type
    local  card_value

    local tmp = string.sub(str, 1, 3)

    if tmp == "黑" then
        card_type = commonconst.CARD_TYPE_SPADE
    elseif tmp == "花" then
        card_type = commonconst.CARD_TYPE_CLUB
    elseif tmp == "红" then
        card_type = commonconst.CARD_TYPE_HEART
    elseif tmp == "方" then
        card_type = commonconst.CARD_TYPE_DIAMOND
    else 
        return commonconst.POKER_UNKNOW_CARD
    end

    tmp = string.sub(4, -1)    
    if tmp == "2" then
        card_value = commonconst.CARD_VALUE_2
    elseif tmp == "3" then 
        card_value = commonconst.CARD_VALUE_3
    elseif tmp == "4" then
        card_value = commonconst.CARD_VALUE_4
    elseif tmp == "5" then 
        card_value = commonconst.CARD_VALUE_5
    elseif tmp == "6" then
        card_value = commonconst.CARD_VALUE_6
    elseif tmp == "7" then
        card_value = commonconst.CARD_VALUE_7
    elseif tmp == "8" then
        card_value = commonconst.CARD_VALUE_8
    elseif tmp == "9" then
        card_value = commonconst.CARD_VALUE_9
    elseif tmp == "10" then
        card_value = commonconst.CARD_VALUE_10
    elseif tmp == "J" then
        card_value = commonconst.CARD_VALUE_JACK
    elseif tmp == "Q" then
        card_value = commonconst.CARD_VALUE_QUEEN
    elseif tmp == "K" then 
        card_value = commonconst.CARD_VALUE_KING
    elseif tmp == "A" then
        card_value = commonconst.CARD_VALUE_ACE
    else
        return commonconst.POKER_UNKNOW_CARD
    end
    return TexasCard.compose_card(card_type, card_value)
end

function TexasCard.parsecards_from_string(cards, str, limit)

    local count = 0
    local start = 1
    local i = 0
    local tmpstr

    i = string.find(str, "|", start)
    while true  and i ~= nil do
        if limit ~= 0 and count >= limit then
            break
        end
        tmpstr = string.sub(str, start, i-1)
        start = i + 1
        local card = TexasCard.parsecard_from_string(tmpstr)
        if card == commonconst.POKER_UNKNOW_CARD then
            break
        end
        table.insert(cards, card)
        i = string.find(str, "|", start)
        count = count + 1
    end    
end

function TexasCard.cardform_tostring(card_form)
    local tmp = nil

    if card_form == commonconst.CARD_FORM_HIGH_CARD then
        tmp = "高牌"
    elseif card_form == commonconst.CARD_FORM_ONE_PAIR then
        tmp = "一对"
    elseif card_form == commonconst.CARD_FORM_TWO_PAIR then
        tmp = "两对"
    elseif card_form == commonconst.CARD_FORM_THREE_OF_A_KING then
        tmp = "三条"
    elseif card_form == commonconst.CARD_FORM_FLUSH then
        tmp = "顺子"
    elseif card_form == commonconst.CARD_FORM_STRAIGHT then
        tmp = "同花"
    elseif card_form == commonconst.CARD_FORM_FULL_HOUSE then
        tmp = "葫芦"
    elseif card_form == commonconst.CARD_FORM_FOUR_OF_A_KING then
        tmp = "四条"
    elseif card_form == commonconst.CARD_FORM_STRAIGHT_FLUSH then
        tmp = "同花顺"
    elseif card_form == commonconst.CARD_FORM_ROYAL_FLUSH then
        tmp = "皇家同花顺"
    else
        tmp = "未知牌型"
    end
    return tmp
end

function TexasCard.action_tostring(action)
    local tmp = nil
    if action == commonconst.seat_ACTION_BET then
        tmp = "下注"
    elseif action == commonconst.seat_ACTION_CALL then
        tmp = "跟牌"
    elseif action == commonconst.seat_ACTION_CHECK then
        tmp = "看牌"
    elseif action == commonconst.seat_ACTION_FOLD then
        tmp = "弃牌"
    elseif action == commonconst.seat_ACTION_RAISE then
        tmp = "加注"
    elseif action == commonconst.seat_ACTION_ALL_IN then
        tmp = "AllIn"
    else
        tmp = "未知"
    end
    return tmp
end

function TexasCard.cards_shuffle(cards, seed)
    -- 添加52张牌
    for card_type = commonconst.CARD_TYPE_SPADE,  commonconst.CARD_TYPE_DIAMOND do
        for card_value = commonconst.CARD_VALUE_2, commonconst.CARD_VALUE_ACE do
            table.insert(cards, TexasCard.compose_card(card_type, card_value))
        end
    end
    -- 洗牌
    local index
    local tmp_seed
    tmp_seed = base.RNG()
    if tmp_seed == nil then
        tmp_seed = timetool.get_10ms_time() + (seed or 0)
    end
    math.randomseed(tmp_seed)    

    for i = 1, #cards do
        index = math.random(#cards + 1 - i)
        cards[index], cards[#cards + 1 - i] = cards[#cards + 1 - i], cards[index]
    end
end

function TexasCard.cardsshuffle_with_prefinedcard(cards)
    --对所有已经有的牌构造table
    local  card_map = {}
    for _,value in pairs(cards) do
        card_map[value] = true
    end
    -- 添加到52张牌，已经有的不添加
    for card_type = commonconst.CARD_TYPE_SPADE,  commonconst.CARD_TYPE_DIAMOND do
        for card_value = commonconst.CARD_VALUE_2, commonconst.CARD_VALUE_ACE do
            if card_map[card_value] == nil or card_map[card_value] then
                table.insert(cards, TexasCard.compose_card(card_type, card_value))                
            end
        end
    end
end

--牌型分析器
function TexasCard.analyse(table_data, index)
    -- 输入检查
    if index > #(table_data.tableseats) then
        return false
    end
    local seat = table_data.tableseats[index]

    if #(seat.cards) ~= 2 then 
        return false
    end

    if #(table_data.community_cards) ~= 5 then
        return false
    end

    -- 保存所有7张牌
    local  all_cards = {}
    table.insert(all_cards, seat.cards[1])
    table.insert(all_cards, seat.cards[2])
    table.insert(all_cards, table_data.community_cards[1])
    table.insert(all_cards, table_data.community_cards[2])
    table.insert(all_cards, table_data.community_cards[3])
    table.insert(all_cards, table_data.community_cards[4])
    table.insert(all_cards, table_data.community_cards[5])

    return TexasCard.analysefromcards(all_cards, seat)
end

local function comps(card1, card2)
    return (TexasCard.get_cardvalue(card1) > TexasCard.get_cardvalue(card2)) or (TexasCard.get_cardvalue(card1) == TexasCard.get_cardvalue(card2) and TexasCard.get_cardtype(card1) > TexasCard.get_cardtype(card2)) 
end

function TexasCard.analysefromcards(cards, seat)
    -- 初始化
    seat.card_form = commonconst.CARD_FORM_UNKONWN
    seat.form_cards = {}

    -- 一个按照花色排序，一个按照点数排序
    table.sort(cards, comps)
    -- 皇家同花顺 & 同花顺
    if TexasCard.is_straightflush(cards, seat) then
        return true
    end

    -- 四条
    if TexasCard.is_fourofaking(cards, seat) then 
        return true
    end

    -- 葫芦 
    if TexasCard.is_fullhouse(cards, seat) then
        return true
    end

    -- 同花
    if TexasCard.is_straight(cards, seat) then
        return true
    end

    -- 顺子
    if TexasCard.is_flush(cards, seat) then
        return true
    end

    -- 三条
    if TexasCard.is_threeofaking(cards, seat) then 
        return true
    end

    -- 两对 & 一对
    if TexasCard.is_pair(cards, seat) then 
        return true
    end
    
    -- 高牌
    seat.form_cards = {}
    TexasCard.find_highcard(cards, seat)
    seat.card_form = commonconst.CARD_FORM_HIGH_CARD

    return true
end

function TexasCard.priocompare(seat1, seat2)
    return TexasCard.priocompare2(seat1.card_form, seat2.card_form, seat1.form_cards, seat2.form_cards)
end

function TexasCard.priocompare2(form1, form2,cards1, cards2)
    if form1 > form2 then
        return 1
    end
    if form1 < form2 then
        return -1
    end                                                                                                                                                 
    -- 特殊处理,如果顺子或者同花顺，A 5 4 3 2是最小的组合
    if form1 == commonconst.CARD_FORM_STRAIGHT_FLUSH or form1 == commonconst.CARD_FORM_FLUSH then
        local is_smalles1 = TexasCard.get_cardvalue(cards1[1]) == commonconst.CARD_VALUE_ACE and TexasCard.get_cardvalue(cards1[2]) == commonconst.CARD_VALUE_5
        local is_smalles2 = TexasCard.get_cardvalue(cards2[1]) == commonconst.CARD_VALUE_ACE and TexasCard.get_cardvalue(cards2[2]) == commonconst.CARD_VALUE_5
        if is_smalles1 and is_smalles2 then
            return 0
        elseif is_smalles1 then 
            return -1
        elseif is_smalles2 then 
            return 1
        end
    end

    local size = math.min(#cards1, #cards2)
    size = math.min(size, 5)
    for i = 1, size do
        if TexasCard.get_cardvalue(cards1[i]) > TexasCard.get_cardvalue(cards2[i]) then
             return 1
        end
        if TexasCard.get_cardvalue(cards1[i]) < TexasCard.get_cardvalue(cards2[i]) then
             return -1
        end
    end

    if #cards1 > #cards2 then 
        return 1
    end
    if #cards1 < #cards2 then 
        return -1
    end
    return 0
end

function TexasCard.getcardvaluediff(card1, card2)
    return TexasCard.get_cardvalue(card1) -  TexasCard.get_cardvalue(card2) 
end
    
function TexasCard.find_samevalue_card(all_cards, seat, num, except) --except = -1
    local tmp_cards = tabletool.deepcopy(seat.form_cards)
    local find_num = 0
    local all_cards_size = #all_cards
    local i = 1
    local j
    while i <= (all_cards_size-(num-1)) do
        local card = all_cards[i]
        -- 如果和except点数相同则不考虑
        if except == nil or TexasCard.get_cardvalue(card) ~= except then
            seat.form_cards = tabletool.deepcopy(tmp_cards)
            table.insert(seat.form_cards, card)
            find_num = 1
            if find_num == num then
                return true
            end
            j = i
            while j <= (all_cards_size-(num-find_num)) do
                local card2 = all_cards[j+1]
                -- 符合条件的话加入
                if TexasCard.issame_cardvalue(card, card2) then
                    table.insert(seat.form_cards, card2)
                    find_num =  find_num + 1
                    if find_num == num then 
                        return true
                    end
                -- 不符合条件则停止
                else
                    i = j
                    break
                end
                j = j + 1                
            end
        end
        i = i + 1           
    end

    seat.form_cards = tmp_cards
    return false
end

function TexasCard.find_highcard(all_cards, seat)
    if #(seat.form_cards) < 5 then
        for i=1, #all_cards do
            local card = all_cards[i]
            local not_exist = true
            for j=1, #(seat.form_cards) do
                
                if card == seat.form_cards[j] then
                    not_exist = false
                end
            end

            if not_exist then
                table.insert(seat.form_cards, card)
            end
        end        
    end
    return (#(seat.form_cards) == 5)
end

function TexasCard.findflush(all_cards, seat, is_need_straight)
    local j
    for i = 1, (#all_cards - 4) do
        seat.form_cards = {}
        table.insert(seat.form_cards, all_cards[i])

        j = i + 1
        while j <= (#all_cards-(4-#(seat.form_cards))) do
            local card1 = seat.form_cards[#(seat.form_cards)]
            local card2 = all_cards[j]

            local diff_value = TexasCard.getcardvaluediff(card1, card2)
            local is_straight = ((is_need_straight and TexasCard.issame_cardtype(card1, card2)) or not is_need_straight)

            -- 符合条件的话加入
            if is_straight and diff_value == 1 then
                table.insert(seat.form_cards, card2)
                if #seat.form_cards == 5 then
                    return true
                end
            end

            -- 点数差超过1则不继续
            if diff_value > 1 then 
                break
            end
            j = j + 1
        end
    end
    -- 特殊情况A 5 4 3 2，是最小的顺子
    for i = 1, (#all_cards-4) do
        local card = all_cards[i]
        if TexasCard.get_cardvalue(card) ~= commonconst.CARD_VALUE_ACE then
            break
        end
        seat.form_cards = {}
        table.insert(seat.form_cards,card)

        for value = commonconst.CARD_VALUE_5,  commonconst.CARD_VALUE_2, -1 do
            local find = false
            if is_need_straight then
                find = TexasCard.find_and_add(all_cards, seat, TexasCard.compose_card(TexasCard.get_cardtype(card), value))
            else
                find = TexasCard.find_and_addbyvalue(all_cards, seat, value)
            end
            if not find then
                break
            end
            if #(seat.form_cards) == 5 then 
                return true
            end
        end
    end
    return false
end

function TexasCard.find_and_add(all_cards, seat, card)
        for i, tmp_card in ipairs(all_cards) do
            if tmp_card == card then
                table.insert(seat.form_cards, tmp_card)
                return true
            end
        end 
    return false
end

function TexasCard.find_and_addbyvalue(all_cards, seat, value)
    for i,card in ipairs(all_cards) do
        if TexasCard.get_cardvalue(card) == value then
            table.insert(seat.form_cards, card)
            return true
        end
    end
    return false
end
-- 皇家同花顺 & 同花顺
function TexasCard.is_straightflush(all_cards, seat)
    seat.form_cards = {}
    -- 找出同花顺
    if not TexasCard.findflush(all_cards, seat, true) then
        return false
    end
    -- 找出
    local card_value1 = TexasCard.get_cardvalue(seat.form_cards[1])
    local card_value2 = TexasCard.get_cardvalue(seat.form_cards[2])
    if card_value2 == commonconst.CARD_VALUE_KING and card_value1 == commonconst.CARD_VALUE_ACE then
        seat.card_form = commonconst.CARD_FORM_ROYAL_FLUSH
    else
        seat.card_form = commonconst.CARD_FORM_STRAIGHT_FLUSH
    end
    return true
end
-- 四条
function TexasCard.is_fourofaking(all_cards, seat)
    seat.form_cards  = {}

    -- 先找出4张同点的
    if not TexasCard.find_samevalue_card(all_cards, seat, 4) then
        return false
    end

    -- 再找一张最大的牌
    TexasCard.find_highcard(all_cards, seat)
    seat.card_form = commonconst.CARD_FORM_FOUR_OF_A_KING
    return true
end
-- 葫芦 
function TexasCard.is_fullhouse(all_cards, seat)
    seat.form_cards = {}

    -- 先找出3张同点的
    if not TexasCard.find_samevalue_card(all_cards, seat, 3) then 
        return false
    end
    -- 再找出2张同点的
    if not TexasCard.find_samevalue_card(all_cards, seat, 2, TexasCard.get_cardvalue(seat.form_cards[1])) then
        return false
    end

    seat.card_form = commonconst.CARD_FORM_FULL_HOUSE
    return true
end

--同花
function TexasCard.is_straight(all_cards, seat)
    seat.form_cards = {}

    -- 找出张数超过5的花色
    for i = commonconst.CARD_TYPE_SPADE, commonconst.CARD_TYPE_DIAMOND do
        seat.form_cards = {}
        for j, card  in ipairs(all_cards) do            
            if TexasCard.get_cardtype(card) == i then
                table.insert(seat.form_cards, card)
                if #(seat.form_cards) == 5 then
                    seat.card_form = commonconst.CARD_FORM_STRAIGHT
                    return true
                end
            end
        end
    end
    return false
end
-- 顺子
function TexasCard.is_flush(all_cards, seat)
    seat.form_cards = {}

    -- 找出顺子
    if not TexasCard.findflush(all_cards, seat, false) then
         return false
    end

    seat.card_form = commonconst.CARD_FORM_FLUSH
    return true
end
-- 三条
function TexasCard.is_threeofaking(all_cards, seat)
    seat.form_cards = {}
    -- 先找出3张同点的
    if not TexasCard.find_samevalue_card(all_cards, seat, 3) then
       return false
    end

    -- 找出最大2张补齐
    TexasCard.find_highcard(all_cards, seat)
    seat.card_form = commonconst.CARD_FORM_THREE_OF_A_KING
    return true
end

-- 两对 & 一对
function TexasCard.is_pair(all_cards, seat)   
    seat.form_cards = {}

    -- 先找出2张同点的
    if not TexasCard.find_samevalue_card(all_cards, seat, 2) then
         return false
    end

    -- 找出另外2张同点的
    if TexasCard.find_samevalue_card(all_cards, seat, 2, TexasCard.get_cardvalue(seat.form_cards[1])) then
        TexasCard.find_highcard(all_cards, seat)
        seat.card_form = commonconst.CARD_FORM_TWO_PAIR
    -- 没找到就是一对
    else
        TexasCard.find_highcard(all_cards, seat)
        seat.card_form = commonconst.CARD_FORM_ONE_PAIR
    end

    return true
end

return TexasCard
