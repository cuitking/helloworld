--
-- Created by IntelliJ IDEA.
-- User: juzhong
-- Date: 2016/9/13
-- Time: 17:02
-- To change this template use File | Settings | File Templates.
--
--local base = require "base"
--local msghelper = require "tablehelper"
--local timetool = require "timetool"
--local timer = require "timer"
local math = math
local pairs = pairs
local ipairs = ipairs
local table = table
require "enum"
local MaxCardNum = 54
---54张牌编码
local CardsKey = {
    0,1,2,3,
    4,5,6,7,
    8,9,10,11,
    12,13,14,15,
    16,17,18,19,
    20,21,22,23,
    24,25,26,27,
    28,29,30,31,
    32,33,34,35,
    36,37,38,39,
    40,41,42,43,
    44,45,46,47,
    48,49,50,51,
    52,53
}
---编码对应的牌
local  CardsValue = {
    3,3,3,3,
    4,4,4,4,
    5,5,5,5,
    6,6,6,6,
    7,7,7,7,
    8,8,8,8,
    9,9,9,9,
    10,10,10,10,
    11,11,11,11,---J
    12,12,12,12,---Q
    13,13,13,13,---K
    14,14,14,14,---A
    15,15,15,15,---2
    16,17
}
---编码对应的花色
---0,1,2,3 黑桃,红桃,草花,方片
local CardsColor = {
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1
}

local DDZRoomGameLogic = {}
local CardHelper = {
    m_nLen = 0,
    m_eCardType = ECardType.DDZ_CARD_TYPE_UNKNOWN,
    m_keyMaxValue = 0,
    m_keyValue = {},
    m_keyColors = {},
}
local CardRuler = {
    ---1.单张
    [ECardType.DDZ_CARD_TYPE_SINGLE] = {
        isMatched = function(CardsObject)
            ---判断张数不是一张就返回
            if CardsObject.m_nLen ~= 1 then
                return false,ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            ---检测牌是否合法
            if CardsKey[CardsObject[1]] == nil then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            CardsObject.m_keyMaxValue = CardsValue[CardsObject[1]]
            return true, ECardType.DDZ_CARD_TYPE_SINGLE
        end,
        isBigThan = function(lparam,rparam)
            ----本牌必须是单牌类型，否则,对牌可以是炸弹，可以类型不同返回
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_SINGLE or
                    rparam.m_eCardType ~= ( ECardType.DDZ_CARD_TYPE_SINGLE or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                                            or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB )  then
                return false
            end
            if lparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SINGLE and rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SINGLE
                    and lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                return true
            end
            ---如果对面的牌是各种炸弹,则对面的牌大
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            return false
        end
    },
    ---2.对子
    [ECardType.DDZ_CARD_TYPE_PAIR] = {
        isMatched = function(CardsObject)
            ---判断张数不是两张就返回
            if CardsObject.m_nLen ~= 2 then
                return false,ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            ---牌值要一致
            if CardsKey[CardsObject[1]] == nil or CardsKey[CardsObject[2]] == nil or CardsKey[CardsObject[1]] ~= CardsKey[CardsObject[2]] then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            CardsObject.m_keyMaxValue = CardsValue[CardsObject[1]]

            return true, ECardType.DDZ_CARD_TYPE_PAIR
        end,
        isBigThan = function(lparam,rparam)
            ----类型不同返回
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_PAIR or
                    rparam.m_eCardType ~= ( ECardType.DDZ_CARD_TYPE_PAIR or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                        or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB ) then
                return false
            end
            if lparam.m_eCardType == ECardType.DDZ_CARD_TYPE_PAIR and rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_PAIR
                and lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                return true
            end
            ---如果对面的牌是各种炸弹,则对面的牌大
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            return false
        end
    },
    ---3.三张
    [ECardType.DDZ_CARD_TYPE_THREE] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen ~= 3 or #CardsObject.m_keyValue ~= 3 or #CardsObject.m_keyColors ~= 3 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            ---牌值要一致
            if CardsObject.m_keyValue[1] ~= CardsObject.m_keyValue[2] or CardsObject.m_keyValue[1] ~= CardsObject.m_keyValue[3] then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            CardsObject.m_keyMaxValue = CardsObject.m_keyValue[1]
            return true, ECardType.DDZ_CARD_TYPE_THREE
        end,
        isBigThan = function(lparam,rparam)
            ----类型不同返回
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_THREE or
                    rparam.m_eCardType ~= ( ECardType.DDZ_CARD_TYPE_THREE or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                            or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB )then
                return false
            end
            if lparam.m_eCardType == ECardType.DDZ_CARD_TYPE_THREE and rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_THREE
                    and lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                return true
            end
            ---如果对面的牌是各种炸弹,则对面的牌大
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            return false
        end
    },
    ---4.炸弹
    [ECardType.DDZ_CARD_TYPE_BOMB] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen ~= 4 or #CardsObject.m_keyValue ~= 4 or #CardsObject.m_keyColors ~= 4 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            ---牌值要一致
            if CardsObject.m_keyValue[1] ~= CardsObject.m_keyValue[2] or CardsObject.m_keyValue[1] ~= CardsObject.m_keyValue[3]
                or CardsObject.m_keyValue[1] ~= CardsObject.m_keyValue[4] then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            CardsObject.m_keyMaxValue = CardsObject.m_keyValue[1]
            return true, ECardType.DDZ_CARD_TYPE_BOMB
        end,
        isBigThan = function(lparam,rparam)
            ----类型不同返回
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_BOMB or
                    rparam.m_eCardType ~= ( ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB ) then
                return false
            end
            if lparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB and rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB
                and lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                return true
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            return false
        end
    },
    ---5.火箭(王炸)
    [ECardType.DDZ_CARD_TYPE_ROCKET] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen ~= 2 or #CardsObject.m_keyValue ~= 2 or #CardsObject.m_keyColors ~= 2 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            if CardsObject.m_keyValue[1] < 16 or  CardsObject.m_keyValue[2] < 16 or CardsObject.m_keyValue[1] == CardsObject.m_keyValue[2] then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            CardsObject.m_keyMaxValue = CardsObject.m_keyValue[1]
            return true, ECardType.DDZ_CARD_TYPE_ROCKET
        end,
        isBigThan = function(lparam,rparam)
            ----类型不同返回
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_ROCKET or
                rparam.m_eCardType ~= ( ECardType.DDZ_CARD_TYPE_ROCKET or ECardType.DDZ_CARD_TYPE_TIANBOMB )then
                return false
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            return false
        end
    },
    ---6.单顺
    [ECardType.DDZ_CARD_TYPE_ONE_STRAIGHT] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen < 5 or CardsObject.m_nLen > 12 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            for i = 1,CardsObject.m_nLen do
                local CardValue = CardsObject.m_keyValue[i]
                local CardValueNext = CardsObject.m_keyValue[i+1]
                if CardValue and CardValueNext then
                    if (CardValue == 15 or 16 or 17) or (CardValueNext == 15 or 16 or 17) then
                        return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
                    end
                    if CardValue ~= CardValueNext + 1 then
                        return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
                    end
                end
            end
            CardsObject.m_keyMaxValue = CardsObject.m_keyValue[1]
            return true, ECardType.DDZ_CARD_TYPE_ONE_STRAIGHT
        end,
        isBigThan = function(lparam,rparam)
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_ONE_STRAIGHT or
                    rparam.m_eCardType ~= ( ECardType.DDZ_CARD_TYPE_ONE_STRAIGHT or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB ) then
                return false
            end
            if lparam.m_eCardType == rparam.m_eCardType then
                if lparam.m_nLen ~= rparam.m_nLen then
                    return false
                else
                    if lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                        return true
                    else
                        return false
                    end
                end
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            return false
        end
    },
    ---7.连对
    [ECardType.DDZ_CARD_TYPE_TWO_STRAIGHT] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen < 6 or CardsObject.m_nLen % 2 ~= 0 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            for i = 1,CardsObject.m_nLen,2 do
                local CardValue = CardsObject.m_keyValue[i]
                local CardValueNext = CardsObject.m_keyValue[i+1]
                if CardValue and CardValueNext then
                    if (CardValue == 15 or 16 or 17) or (CardValueNext == 15 or 16 or 17) or (CardsObject.m_keyValue[i] ~= CardsObject.m_keyValue[i+1]) then
                        return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
                    end
                    if CardsObject.m_keyValue[i+2] then
                        if CardsObject.m_keyValue[i] ~= CardsObject.m_keyValue[i+2] + 1 then return false, ECardType.DDZ_CARD_TYPE_UNKNOWN end
                    end
                else
                    return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
                end
            end
            CardsObject.m_keyMaxValue = CardsObject.m_keyValue[1]
            return true, ECardType.DDZ_CARD_TYPE_TWO_STRAIGHT
        end,
        isBigThan = function(lparam,rparam)
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_TWO_STRAIGHT or
                    rparam.m_eCardType ~= (ECardType.DDZ_CARD_TYPE_TWO_STRAIGHT or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB) then
                return false
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            if lparam.m_eCardType == rparam.m_eCardType then
                if lparam.m_nLen ~= rparam.m_nLen then
                    return false
                else
                    if lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                        return true
                    else
                        return false
                    end
                end
            end
            return false
        end
    },
    ---8.三顺
    [ECardType.DDZ_CARD_TYPE_THREE_STRAIGHT] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen < 6 or CardsObject.m_nLen % 3 ~= 0 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            for i = 1, CardsObject.m_nLen, 3 do
                if CardsObject.m_keyValue[i] and CardsObject.m_keyValue[i+1] and CardsObject.m_keyValue[i+2] then
                    if CardsObject.m_keyValue[i] ~= CardsObject.m_keyValue[i+1] or CardsObject.m_keyValue[i] ~= CardsObject.m_keyValue[i+2] then
                        return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
                    end
                    if CardsObject.m_keyValue[i+3] then
                        if CardsObject.m_keyValue[i] ~= CardsObject.m_keyValue[i+3] + 1 then return false, ECardType.DDZ_CARD_TYPE_UNKNOWN end
                    end
                else
                    return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
                end
            end
            CardsObject.m_keyMaxValue = CardsObject.m_keyValue[1]
            return true, ECardType.DDZ_CARD_TYPE_THREE_STRAIGHT
        end,
        isBigThan = function(lparam,rparam)
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_THREE_STRAIGHT or
                    rparam.m_eCardType ~= ( ECardType.DDZ_CARD_TYPE_THREE_STRAIGHT or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB )then
                return false
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            if lparam.m_eCardType == rparam.m_eCardType then
                if lparam.m_nLen ~= rparam.m_nLen then
                    return false
                else
                    if lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                        return true
                    else
                        return false
                    end
                end
            end
            return false
        end
    },
    ---9.三带一
    [ECardType.DDZ_CARD_TYPE_THREE_ONE] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen ~= 4 or #CardsObject.m_keyValue ~= 4 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            if not (CardsObject.m_keyValue[1] == CardsObject.m_keyValue[2] and CardsObject.m_keyValue[1] == CardsObject.m_keyValue[3]
                        and CardsObject.m_keyValue[1] ~= CardsObject.m_keyValue[4]) or
                   not ( CardsObject.m_keyValue[2] == CardsObject.m_keyValue[3] and CardsObject.m_keyValue[2] == CardsObject.m_keyValue[4]
                    and CardsObject.m_keyValue[1] ~= CardsObject.m_keyValue[2] ) then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            CardsObject.m_keyMaxValue = CardsObject.m_keyValue[2]
            return true, ECardType.DDZ_CARD_TYPE_THREE_ONE
        end,
        isBigThan = function(lparam,rparam)
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_THREE_ONE or
                    rparam.m_eCardType ~= (ECardType.DDZ_CARD_TYPE_THREE_ONE or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB) then
                return false
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            if lparam.m_eCardType == rparam.m_eCardType then
                if lparam.m_nLen ~= rparam.m_nLen then
                    return false
                else
                    if lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                        return true
                    else
                        return false
                    end
                end
            end
            return false
        end
    },
    ----10.三带二
    [ECardType.DDZ_CARD_TYPE_THREE_PAIR] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen ~= 5 or #CardsObject.m_keyValue ~= 5 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            if(CardsObject.m_keyValue[1] == CardsObject.m_keyValue[2] and CardsObject.m_keyValue[3] == CardsObject.m_keyValue[4] 
                and CardsObject.m_keyValue[3] == CardsObject.m_keyValue[5]) or (CardsObject.m_keyValue[1] == CardsObject.m_keyValue[2] and 
                CardsObject.m_keyValue[3] == CardsObject.m_keyValue[4] and CardsObject.m_keyValue[3] == CardsObject.m_keyValue[5]) then
                CardsObject.m_keyMaxValue = CardsObject.m_keyValue[3]
            end
            
            return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
        end,
        isBigThan = function(lparam,rparam)
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_THREE_PAIR or
                    rparam.m_eCardType ~= (ECardType.DDZ_CARD_TYPE_THREE_PAIR or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB) then
                return false
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            if lparam.m_eCardType == rparam.m_eCardType then
                if lparam.m_nLen ~= rparam.m_nLen then
                    return false
                else
                    if lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                        return true
                    else
                        return false
                    end
                end
            end
            return false
        end
    },
    ----11.飞机带翅膀(单)
    [ECardType.DDZ_CARD_TYPE_THREE_WING_ONE] = {
        isMatched = function(CardsObject)
            return true, ECardType.DDZ_CARD_TYPE_THREE_WING_ONE
        end,
        isBigThan = function(lparam, rparam)
            return false
        end
    },
    ----12.飞机带翅膀(双)
    [ECardType.DDZ_CARD_TYPE_THREE_WING_PAIR] = {
        isMatched = function(CardsObject)
            return true, ECardType.DDZ_CARD_TYPE_THREE_WING_PAIR
        end,
        isBigThan = function(lparam,rparam)
            return false
        end
    },
    -----13.四带二张
    [ECardType.DDZ_CARD_TYPE_FOUR_TWO_ONE] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen ~= 6 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            for i = 1,3 do
                if (CardsObject.m_keyValue[i] == CardsObject.m_keyValue[i+1] and CardsObject.m_keyValue[i] == CardsObject.m_keyValue[i+2] 
                    and CardsObject.m_keyValue[i] == CardsObject.m_keyValue[i+3]) then
                    CardsObject.m_keyMaxValue = CardsObject.m_keyValue[i]
                    return true, ECardType.DDZ_CARD_TYPE_FOUR_TWO_ONE
                end
            end
            
            return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
        end,
        isBigThan = function(lparam, rparam)
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_FOUR_TWO_ONE or
                    rparam.m_eCardType ~= (ECardType.DDZ_CARD_TYPE_FOUR_TWO_ONE or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB) then
                return false
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            if lparam.m_eCardType == rparam.m_eCardType then
                if lparam.m_nLen ~= rparam.m_nLen then
                    return false
                else
                    if lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                        return true
                    else
                        return false
                    end
                end
            end
            return false
        end
    },
    -----14.四代两对
    [ECardType.DDZ_CARD_TYPE_FOUR_TWO_PAIR] = {
        isMatched = function(CardsObject)
            if CardsObject.m_nLen ~= 8 then
                return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
            end
            local mainValue = {}
            local tempValue = {}
            for i = 1,5 do
                if (CardsObject.m_keyValue[i] == CardsObject.m_keyValue[i+1] and CardsObject.m_keyValue[i] == CardsObject.m_keyValue[i+2] 
                    and CardsObject.m_keyValue[i] == CardsObject.m_keyValue[i+3]) then
                    table.insert(mainValue,CardsObject.m_keyValue[i])
                end
            end
            if #mainValue == 1 then
                for i = 1, CardsObject.m_nLen do
                    if mainValue[1] ~= CardsObject.m_keyValue[i] then table.insert(tempValue,CardsObject.m_keyValue[i]) end
                end
                for i = 1, #tempValue,2 do
                    if tempValue[i] and tempValue[i+1] and tempValue[i] != tempValue[i+1] then
                        return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
                    end
                end
                CardsObject.m_keyMaxValue = mainValue[1]
                return true, ECardType.DDZ_CARD_TYPE_FOUR_TWO_PAIR
            elseif #mainValue == 2 then
                CardsObject.m_keyMaxValue = (mainValue[1] > mainValue[2]) and mainValue[1] or mainValue[2]
                return true, ECardType.DDZ_CARD_TYPE_FOUR_TWO_PAIR
            end
            return false, ECardType.DDZ_CARD_TYPE_UNKNOWN
        end,
        isBigThan = function(lparam, rparam)
            if lparam.m_eCardType ~= ECardType.DDZ_CARD_TYPE_FOUR_TWO_PAIR or
                    rparam.m_eCardType ~= (ECardType.DDZ_CARD_TYPE_FOUR_TWO_PAIR or ECardType.DDZ_CARD_TYPE_BOMB or ECardType.DDZ_CARD_TYPE_ROCKET
                    or ECardType.DDZ_CARD_TYPE_SOFTBOMB or ECardType.DDZ_CARD_TYPE_TIANBOMB) then
                return false
            end
            if rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_BOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_ROCKET
                    or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_SOFTBOMB or rparam.m_eCardType == ECardType.DDZ_CARD_TYPE_TIANBOMB then
                return true
            end
            if lparam.m_eCardType == rparam.m_eCardType then
                if lparam.m_nLen ~= rparam.m_nLen then
                    return false
                else
                    if lparam.m_keyMaxValue < rparam.m_keyMaxValue then
                        return true
                    else
                        return false
                    end
                end
            end
            return false
        end
    },
}




function CardHelper:new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    self.__newindex = self
    return obj
end
function CardHelper:sortCards(cardsObj)
    if not cardsObj or type(cardsObj) ~= "table" or #cardsObj == 0 then return end
    table.sort(cardsObj,
        function(lobj,robj)
            if CardsValue[lobj] and CardsValue[robj] then
                return CardsValue[lobj] > CardsValue[robj]
            end
        end)
end
function CardHelper:CardsNumToPointAndColor(cardsObj)
    for k,v in ipairs(cardsObj) do
        if CardsValue[v] then
            table.insert(cardsObj.m_keyValue,k,CardsValue[v])
        end
        if CardsColor[v] then
            table.insert(cardsObj.m_keyColors,k,CardsColor[v])
        end
    end
end
function CardHelper:Init(cardsObj)
    ---对一个牌堆排序,大值在前
    CardHelper:sortCards(cardsObj)
    cardsObj.m_nLen = #cardsObj
    ---牌数组值转换成牌值和牌值的花色
    CardHelper:CardsNumToPointAndColor(cardsObj)
end


function CardHelper:GetCardsType(cardsObj)
    for k,v in ipairs(CardRuler) do
        local success,cardType = v.isMatched(cardsObj)
        if not success then
            break
        else
            cardsObj.m_eCardType = cardType
        end
    end
end


local EActionType = {
    ACTION_TYPE_JDZ = 1,
    ACTION_TYPE_QDZ = 2,
    ACTION_TYPE_NO_JDZ = 3,
    ACTION_TYPE_NO_QDZ = 4,
}

math.randomseed(os.time)

local action_seat_index = math.random(1,3)
local tableobj = {
    action_type = EActionType.ACTION_TYPE_JDZ,
    jdz_begin = action_seat_index,

    seats = {
        [1] = {
            isjdz = 0, --- -2 不抢,-1 不叫,0, 1 叫地主, 2抢地主
        },
        [2] = {
            isjdz = 0,
        },
        [3] = {
            isjdz = 0
        },

    }
}  
local action_seat_index_next = 0
local action_seat_index_next_next = 0
if action_seat_index == 1 then
    action_seat_index_next = 2
    action_seat_index_next_next = 3
elseif action_seat_index == 2 then
    action_seat_index_next = 3
    action_seat_index_next_next = 1
elseif action_seat_index == 3 then
    action_seat_index_next = 1
    action_seat_index_next_next = 2 
end


if tableobj.action_type == EActionType.ACTION_TYPE_JDZ then
    ----尾家叫地主
    if tableobj.jdz_begin == action_seat_index_next and tableobj.seats[action_seat_index].isjdz == 1 and 
        tableobj.seats[action_seat_index_next].isjdz == 0 and tableobj.seats[action_seat_index_next_next] == 0 then
        ----确定地主

    else
        -----通知下一家抢地主
    end
    

elseif tableobj.action_type == EActionType.ACTION_TYPE_NO_JDZ then
    ---尾家不叫地主
    if tableobj.jdz_begin == action_seat_index_next and tableobj.seats[action_seat_index].isjdz == 0 and 
        ((tableobj.seats[action_seat_index_next].isjdz == 1 and tableobj.seats[action_seat_index_next_next] == 0) or 
            ((tableobj.seats[action_seat_index_next].isjdz == 0 and tableobj.seats[action_seat_index_next_next] == 1)) then
        ----确定地主

    else
        -----通知下一家叫地主
    end

elseif tableobj.action_type == EActionType.ACTION_TYPE_QDZ then
    ---判断下一家是否抢过,如果抢过则,强地主规则结束
    if tableobj.seats[action_seat_index_next].isjdz == 2 then
        ---确定地主
    elseif tableobj.seats[action_seat_index_next].isjdz == 1 then

    else
        
    end


end








