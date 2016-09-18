var cardTool = {}
global.GCardTool = cardTool

///////////牌型控制工具函数////////////
// 比较牌值的大小如果修改了同时修改CardControler.js的同名函数;
cardTool.compByPointAscending = function(a, b)
{// 升序排列; 返回值1则交换
    if (a > 51 || b > 51)
        return (a > b ? 1 : -1)
    var a_point = Math.floor( a%13 )
    var a_suit = Math.floor( a/13 )
    var b_point = Math.floor( b%13 )
    var b_suit = Math.floor( b/13 )
    if (a_point == b_point)
        return (a_suit < b_suit?1:-1)       // 方片，梅花, 红桃, 黑桃;
    else
    {
        var a_point = a_point <= 1 ? a_point + 13 : a_point
        var b_point = b_point <= 1 ? b_point + 13 : b_point
        return (a_point > b_point? 1:-1)
    }
}
cardTool.compByPointDescending = function(a, b)
{// 降序排列;
    if (a > 51 || b > 51)
        return (a < b ? 1 : -1)
    var a_point = Math.floor( a%13 )
    var a_suit = Math.floor( a/13 )
    var b_point = Math.floor( b%13 )
    var b_suit = Math.floor( b/13 )

    if (a_point == b_point)
        return (a_suit > b_suit?1:-1)      //  黑桃, 红桃, 梅花,方片
    else
    {
        var a_point = a_point <= 1 ? a_point + 13 : a_point
        var b_point = b_point <= 1 ? b_point + 13 : b_point
        return (a_point < b_point? 1:-1)
    }

},
cardTool.compByArrLengthDescending = function(a, b)
{//按数组长度的降序排列;
    if (global.GCardTool.isArray(a) == false || global.GCardTool.isArray(b) == false)
    {
        cc.log("param is not array @ Fun: compByArrLengthDescending")
        return
    }

    var a_len = a == undefined ? 0 : a.length
    var b_len = b == undefined ? 0 : b.length
    return a_len < b_len ? 1 : -1
}
cardTool.convertCardsNumToPoint = function(cards)
{
    var ret = []
    if (cards == undefined )
        return ret
    for (var i = 0; i < cards.length; i++)
    {
        // 已经被处理过的joker,JokerA/JokerB
        if (cards[i] >= global.GConst.Joker.JokerA)
        {
            ret.push(cards[i])
            continue;
        }
    
        var point = Math.floor( cards[i] % 13)
        var suit  = Math.floor( cards[i] / 13)
        if (suit == 4)
            point = point == 0 ? global.GConst.Joker.JokerA : global.GConst.Joker.JokerB
        point = point <= 1 ? point + 13 : point
        ret.push(point)
    }
    return ret
}
cardTool.convertCardNumToPoint = function(cardNum)
{
    // 已经被处理过的joker,JokerA/JokerB
    if (cardNum >= global.GConst.Joker.JokerA)
        return cardNum

    var point = Math.floor( cardNum % 13)
    var suit  = Math.floor( cardNum / 13)
    if (suit == 4)
        point = point == 0 ? global.GConst.Joker.JokerA : global.GConst.Joker.JokerB
    point = point <= 1 ? point + 13 : point
    return point
}
// 查询牌组里面是否有指定牌号的值;
cardTool.isContainInCards = function(cardNum, desCards)
{
    var ret = false
    for (var i=0; i<desCards.length; i++)
    {
        if(desCards[i] == cardNum)
        {
            ret = true
            break
        }
    }
    return ret
},
cardTool.jokerConstToCardNum = function(cards)
{  
    var arr = []
    for(var i=0; i<cards.length; i++)
    {
        if (cards[i] >= global.GConst.Joker.JokerA)
            arr.push(cards[i] - global.GConst.Joker.JokerA + 52)
        else
            arr.push(cards[i])
    }
    return arr
}
//数组去重;
cardTool.unique = function(arr)
{
    var result = [], hash = {}
    for (var i=0, elem; (elem = arr[i])!=null; i++)
    {
        if ( !hash[elem] )
        {
            result.push(arr[i])
            hash[elem] = true
        }
    }
    return result
}
//是否数组;
cardTool.isArray = function(o){
    if ( o && typeof o === 'object' && Array == o.constructor)
        return true
    return false
}
/*
Array.prototype.clone=function(){
   return this.slice(0);
}*/
//提取牌组中所有的非重复的单牌/对子/三条/四条,升序;
cardTool.extract = function(cards)
{
    var count = 0
    var container = 
    {
        danpai:[],
        duizi:[],
        santiao:[],
        sitiao:[],
    }
    for(var i=cards.length-1; i>=0; i--)
    {
        for(var j=cards.length-1; j>=0; j--)
        {
            if (cards[i] == cards[j])
                count++
        }
        if (count == 1)
        {
            container.danpai.push(cards[i])
        }
        else if (count == 2)
        {
            container.duizi.push(cards[i])
        }
        else if(count == 3)
        {
            container.santiao.push(cards[i])
        }
        else if(count == 4)
        {
            container.sitiao.push(cards[i])
        }
        count = 0
    }
    container.danpai = global.GCardTool.unique(container.danpai)
    container.duizi = global.GCardTool.unique(container.duizi)
    container.santiao = global.GCardTool.unique(container.santiao)
    container.sitiao = global.GCardTool.unique(container.sitiao)

    container.danpai.sort( global.GCardTool.compByPointAscending )
    container.duizi.sort( global.GCardTool.compByPointAscending )
    container.santiao.sort( global.GCardTool.compByPointAscending )
    container.sitiao.sort( global.GCardTool.compByPointAscending )
    return container
}

/////////////牌型判断//////////////
//ret = {flag:false, beg: -1, len: -1}
//
// 单牌; ret:true + 主值;
cardTool.isDan = function(cards)
{
    if (cards != undefined && cards.length == 1){
        return {flag:true, beg:cards[0], len:-1}
    }
        
    return {flag:false, beg:-1, len:-1}
},
//对子;
cardTool.isDuiZi = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length == 2) 
    {
        if (arr[0] == arr[1]) 
            return {flag:true, beg: arr[0], len: -1}
    }
    return {flag:false, beg: -1, len: -1}
},
//3个不带;
cardTool.isSanBuDai = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if(arr.length == 3 && arr[0] == arr[1] && arr[0] == arr[2])
    {
        return {flag:true, beg: arr[0], len: -1}
    }
    return {flag:false, beg: -1, len: -1}
},
////三带一;
//@ ret: true + 三带一的主值; 
cardTool.isSanDaiYi = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length == 4) 
    {
        arr.sort(global.GCardTool.compByPointAscending)
        if (arr[1] == arr[0] && arr[2] == arr[0] && arr[3] == arr[0])
        {// sitiao -> false
            return {flag:false, beg: -1, len: -1}
        }
        else if ( arr[1] == arr[0] && arr[1] == arr[2] || 
            arr[1] == arr[3] && arr[1] == arr[2] )
        {
            return {flag:true, beg: arr[1], len: -1}
        }
    }
    return {flag:false, beg: -1, len: -1}
}
//三带对;
cardTool.isSanDaiDui = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length == 5)
    { 
        arr.sort(global.GCardTool.compByPointAscending)
        if ( (arr[0] == arr[1] && arr[2] == arr [3] && arr[2] == arr[4]) ||
            (arr[3] == arr[4] && arr[2] == arr[0] && arr[2] == arr[1]) )
        {
            return {flag:true, beg: arr[2], len: -1}
        }            
    }
    return {flag:false, beg: -1, len: -1}
}
//顺子;
//@ ret, true+起值+长度;
cardTool.isShunZi = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length<5 || arr.length >12)
        return {flag:false, beg: -1, len: -1}
    arr.sort(global.GCardTool.compByPointAscending)
    for(var i=0; i < arr.length - 1; i++)
    {
        var pre = arr[i]
        var next = arr[i+1]
        if(pre == 14 || pre == global.GConst.Joker.JokerA || pre == global.GConst.Joker.JokerB ||
            next == 14 || next == global.GConst.Joker.JokerA || next == global.GConst.Joker.JokerB)
        {// 2(转码值=14), jokerA,jokerB
            return {flag:false, beg: -1, len: -1}
        }
        else
        {
            if ((pre - next) != -1 )
            {// not continuous
                return {flag:false, beg: -1, len: -1}
            }
        }
    }
    return {flag:true, beg: arr[0], len: arr.length}
},
//连对;
//@ret, true + 起值 + 长度
cardTool.isLianDui = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    var len = arr.length / 2
    if (arr.length < 6 || arr.length % 2 != 0)
    {
        return {flag:false, beg: -1, len: -1}
    }
    else
    {
        arr.sort(global.GCardTool.compByPointAscending)
        for (var i = 0; i < arr.length; i = i + 2)
        {
            if (arr[i] != arr[i+1] || arr[i] >= 14 || arr[i+1] >= 14)
            { // 2, jokerA, jokerB
                return {flag:false, beg: -1, len: -1}
            }
            if (i+2 < arr.length)
            {
                if ((arr[i] - arr[i+2]) != -1 )
                {
                    return {flag:false, beg: -1, len: -1}
                }
            }
        }
    }
    return {flag:true, beg: arr[0], len: len}
},
//飞机(该函数功能不单一,已废弃); 
cardTool.isFeiJi = function(cards)
{
    var ret = {flag:false, beg: -1, len: -1}
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    var len = arr.length
    if (arr.length >= 6)
    {
        arr.sort(global.GCardTool.compByPointAscending)
        ret = global.GCardTool.isFeiJiBuDai(arr)      //飞机不带;
        if (ret[0] == true)
            return ret
        
        ret = global.GCardTool.isFeiJiDaiDan(arr)     //飞机带单牌;
        if (ret[0] == true)
            return ret
        
        ret = global.GCardTool.isFeiJiDaiDui(arr)     //飞机带对子;
        if (ret[0] == true)
            return ret
    }
    else
        return ret
}
//飞机不带/三顺;
//@ret , true + 起值 + 长度;
cardTool.isFeiJiBuDai = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    var num = arr.length / 3
    if (arr.length < 6 || arr.length % 3 != 0)
        return {flag:false, beg: -1, len: -1}

    arr.sort(global.GCardTool.compByPointAscending)
    var main = []
    for(var i = 0; i < arr.length; i=i+3)
    {
        if (arr[i] == arr[i+1] && arr[i] == arr[i+2] && arr[i] < 14)
        {//2(14)不能作为主体;
            main.push(arr[i])
        }
        else
            return {flag:false, beg: -1, len: -1}
    }
    for(var i = 0; i < num-1; i++)
    {
        if (main[i+1] - main[i] != 1)
        {
            cc.log("连续的三条才是飞机," + main[i] + " " + main[i+1] + "不连续")
            return {flag:false, beg: -1, len: -1}
        }
    }
    return {flag:true, beg: main[0], len: num}
},
//飞机带单;
//@ret, true + 起值 + 长度;
cardTool.isFeiJiDaiDan = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    var num = arr.length / 4 
    if (arr.length < 8 || arr.length % 4 != 0)
        return {flag:false, beg: -1, len: -1}
    arr.sort(global.GCardTool.compByPointAscending)
    var main = []
    for (var i=2; i<arr.length; i++)
    {
        if (arr[i] == arr[i-1] && arr[i] == arr[i-2] && arr[i] < 14)
        {   
            // 四条只计算一次;
            var isFind = global.GCardTool.isContainInCards( arr[i], main )
            if (isFind == false)
            {//主值;
                main.push(arr[i])
            }
        }
    }
    main.sort(global.GCardTool.compByPointDescending)
    // eg: 777 555 444 333 or 888 777 666 555 4444 or 8888 777 666 555 444,20张牌的时候只有这些,所有特殊处理;
    for (var i=0; i<main.length; i++)
    {
        var isFind = true
        for (var j=0; j<num; j++)
        {
            var target = main[i] - j
            isFind = global.GCardTool.isContainInCards(target, main)
            if (isFind == false)
            {
                break
            }
        }
        if (isFind == true)
        {
            var key = main[i] - num + 1
            return {flag:true, beg:key, len:num}
        }
    }
    return {flag:false, beg: -1, len: -1}
}
//飞机带对子;
cardTool.isFeiJiDaiDui = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    var num = arr.length / 5
    if (arr.length < 10 || arr.length % 5 != 0)
        return {flag:false, beg: -1, len: -1}
    arr.sort(global.GCardTool.compByPointAscending)
    var main = []
    var sub = []
    for (var i=2; i<arr.length; i++)
    {
        if (arr[i] == arr[i-1] && arr[i] == arr[i-2] && arr[i] != 14)
        {   
            var isFind = false
            var idx    = -1
            for(var j=0; j<main.length; j++)
            {
                if (main[j] == arr[i])
                {
                    isFind = true
                    idx = j
                    break
                }
            }
            if (isFind == false)
            {//提取主值;
                main.push(arr[i])
            }
            else
            {//四条不是飞机带对主值;eg: 22 3333 444 555 666, 333 444 555 6666 77
                main.splice(idx, 1)
            }
        }
    }
    for (var i=0; i<arr.length; i++)
    {// 提取辅值
        var isFind = global.GCardTool.isContainInCards(arr[i], main)
        if (isFind == false)
            sub.push(arr[i])
    }
    sub.sort(global.GCardTool.compByPointAscending)
    for (var i=0; i < sub.length - 1; i=i+2)
    {// 验证辅值;
        if (sub[i+1] != sub[i])
            return {flag:false, beg: -1, len: -1}
    }

    main.sort(global.GCardTool.compByPointDescending)
    // eg: 77 6666 555 444 333 or 888 777 666 555 4444 or 8888 777 666 555 444,20张牌的时候只有这些,所有特殊处理;
    for (var i=0; i<main.length; i++)
    {
        var isFind = true
        for (var j=0; j<num; j++)
        {
            var target = main[i] - j
            isFind = global.GCardTool.isContainInCards(target, main)
            if (isFind == false)
            {
                break
            }
        }
        if (isFind == true)
        {
            var key = main[i] - num + 1
            return {flag:true, beg:key, len:num}
        }
    }
    return {flag:false, beg: -1, len: -1}
}
//四带两个单牌;
//@ret, true + 主值
cardTool.isSiDaiEr_Dan = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length == 6)
    {
        arr.sort(global.GCardTool.compByPointAscending)
        for (var i = 0; i < 3; i++) {
            if (arr[i] == arr[i+1] && arr[i] == arr[i+2] && arr[i] == arr[i+3])
            {
                return {flag:true, beg: arr[i], len: 1}
            }
        }
    }
    return {flag:false, beg: -1, len: -1}
},
//四带两个对子;
//@ret, true + 主值
cardTool.isSiDaiEr_Dui = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length == 8)
    {
        var main = []
        var sub = []
        arr.sort(global.GCardTool.compByPointAscending)
        for (var i = 0; i < 5; i++) {
            if (arr[i] == arr[i+1] && arr[i] == arr[i+2] && arr[i] == arr[i+3])
            {
                main.push(arr[i])
            }
        }
        if (main.length > 0)
        {
            if (main.length == 1)
            {
                for (var i=0; i<arr.length; i++)
                {// 提取辅值
                    var isFind = global.GCardTool.isContainInCards(arr[i], main)
                    if (isFind == false)
                        sub.push(arr[i])
                }
                for (var i=0; i < sub.length; i=i+2)
                {// 验证辅值;
                    if (sub[i+1] != sub[i])
                        return {flag:false, beg: -1, len: -1}
                }
                return {flag:true, beg: main[0], len: 1}
            }
            else if (main.length == 2)
            {//两四条
                var max = main[0] >= main[1] ? main[0] : main[1]
                return {flag:true, beg: max, len: 1}
            }
        }
    }
    return {flag:false, beg: -1, len: -1}
},
//炸弹;
cardTool.isZhaDan = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length == 4 && arr[0] == arr[1] && arr[0] == arr[2] && arr[0] == arr[3])
    {
        return {flag:true, beg: arr[0], len: 1}
    }
    return {flag:false, beg: -1, len: -1}
},
//王炸,一对王;
cardTool.isWangZha = function(cards)
{
    var arr = global.GCardTool.convertCardsNumToPoint(cards)
    if (arr.length == 2 && arr[0] >= global.GConst.Joker.JokerA && arr[1] >= global.GConst.Joker.JokerA)
        return {flag:true, beg: -1, len: -1}
    return {flag:false, beg: -1, len: -1}
},

///////////////确认牌型///////////////
//@ret:{cardType:0, beg:-1, len:-1} 牌型, 主值起值, 主值长度;
cardTool.getCardType = function(in_cards)
{  
    var cards = global.GCardTool.convertCardsNumToPoint(in_cards)
    var card_type = global.GConst.CardType.UNDEFINE;
    var ret = {}
    if (cards != undefined) 
    {
        ret = global.GCardTool.isDan(cards)
        if ( ret.flag == true)
        {//单牌;                                  
            card_type = global.GConst.CardType.DAN;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }

        ret = global.GCardTool.isDuiZi(cards)
        if (ret.flag == true) 
        {//对子;
            card_type = global.GConst.CardType.DUI_ZI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }

        ret = global.GCardTool.isSanBuDai(cards)
        if (ret.flag == true)
        {//三不带;
            card_type = global.GConst.CardType.SAN_BU_DAI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }

        ret = global.GCardTool.isSanDaiYi(cards)
        if (ret.flag == true)
        {//三带一;
            card_type = global.GConst.CardType.SAN_DAI_YI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }
        
        ret = global.GCardTool.isSanDaiDui(cards)
        if (ret.flag == true)
        {//三带对;
            card_type = global.GConst.CardType.SAN_DAI_DUI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }

        ret = global.GCardTool.isShunZi(cards)
        if (ret.flag == true)
        {//顺子;
            card_type = global.GConst.CardType.SHUN_ZI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }

        ret = global.GCardTool.isLianDui(cards)
        if (ret.flag == true)
        {//连对;
            card_type = global.GConst.CardType.LIAN_DUI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }
        
        ret = global.GCardTool.isFeiJiBuDai(cards)
        if (ret.flag == true)
        {//三顺;
            card_type = global.GConst.CardType.FEI_JI_BU_DAI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }
        
        ret = global.GCardTool.isFeiJiDaiDan(cards)
        if (ret.flag == true)
        { //飞机带单牌;  eg: 3333 4444 优先判定为飞机;
            card_type = global.GConst.CardType.FEI_JI_DAI_DAN;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }
        
        ret = global.GCardTool.isFeiJiDaiDui(cards)
        if (ret.flag == true)
        { //飞机带对子;  
            card_type = global.GConst.CardType.FEI_JI_DAI_DUI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }

        ret = global.GCardTool.isSiDaiEr_Dan(cards)
        if (ret.flag == true)
        {  //四带两个单牌;      
            card_type = global.GConst.CardType.SI_DAI_DAN;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }
        
        ret = global.GCardTool.isSiDaiEr_Dui(cards)
        if (ret.flag == true)
        {  //四带两对子;    eg: 3333 4444 优先判定为飞机;
            card_type = global.GConst.CardType.SI_DAI_DUI;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }
        
        ret = global.GCardTool.isZhaDan(cards)
        if (ret.flag == true)
        {  //炸弹;
            card_type = global.GConst.CardType.ZHA_DAN;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }

        ret = global.GCardTool.isWangZha(cards)
        if (ret.flag == true)
        {  //王炸;
            card_type = global.GConst.CardType.WANG_ZHA;
            return {cardType: card_type, beg:ret.beg, len:ret.len}
        }
    }
    return {cardType: card_type, beg: -1, len: -1}
},

//////////牌型比较////////////
/*@ my_Cards, 本家出牌,
 *@ pre_Cards,上家出牌,
 *@ ret true/false
 */
cardTool.isOvercomePrev = function(my_Cards, pre_Cards)
{
    if(my_Cards == undefined || pre_Cards == undefined)
        return false
    var my_cardsInfo    = global.GCardTool.getCardType(my_Cards)
    var pre_cardsInfo   = global.GCardTool.getCardType(pre_Cards)
    
    var myCards = global.GCardTool.convertCardsNumToPoint(my_Cards)
    var myCardType = my_cardsInfo.cardType
    var preCards = global.GCardTool.convertCardsNumToPoint(pre_Cards)
    var preCardType = pre_cardsInfo.cardType
    
    myCards.sort(global.GCardTool.compByPointAscending)
    preCards.sort(global.GCardTool.compByPointAscending)

    var preSize = preCards.length
    var mySize = myCards.length
    if (preSize==0 && mySize != 0)  //我是第一家出牌;
        return true
    if (preCards.length == 0 && preCardType == global.GConst.CardType.UNDEFINE)
        return true

    if (preCardType == global.GConst.CardType.WANG_ZHA)     
        return false;
    else if (myCardType == global.GConst.CardType.WANG_ZHA) 
        return true;                
    else if(myCardType == global.GConst.CardType.ZHA_DAN && preCardType != global.GConst.CardType.ZHA_DAN)
        return true;
    
    if (myCardType != preCardType)
        return false
    else if ( myCardType == global.GConst.CardType.DAN ||           //单牌;
            myCardType == global.GConst.CardType.DUI_ZI ||          //对子;
            myCardType == global.GConst.CardType.SAN_BU_DAI ||      //三不带;
            myCardType == global.GConst.CardType.SAN_DAI_YI ||      //三带一;
            myCardType == global.GConst.CardType.SAN_DAI_DUI ||     //三带二;
            myCardType == global.GConst.CardType.SI_DAI_DAN ||      //四带两个单牌;
            myCardType == global.GConst.CardType.SI_DAI_DUI ||      //四带两个对子;
            myCardType == global.GConst.CardType.ZHA_DAN )          //砸蛋; 
    {
        return my_cardsInfo.beg > pre_cardsInfo.beg
    }

    else if ( myCardType == global.GConst.CardType.SHUN_ZI ||           //顺子;
            myCardType == global.GConst.CardType.LIAN_DUI ||            //连对;
            myCardType == global.GConst.CardType.FEI_JI_BU_DAI ||       //三顺;
            myCardType == global.GConst.CardType.FEI_JI_DAI_DAN ||      //飞机带单,几个三连就带几个单;
            myCardType == global.GConst.CardType.FEI_JI_DAI_DUI )        //飞机带对,几个三连就带几个对;
    {
        if (my_cardsInfo.len == pre_cardsInfo.len)
        {
            return my_cardsInfo.beg > pre_cardsInfo.beg
        }
    }
    return false
},

/////////////简单AI的出牌判定,且选出一组可用牌////////////
/*@ 查询手牌中是否有比上家更大的牌，AI简单出牌
 *@ my_Cards, 本家所有的牌,
 *@ pre_Cards,  上家出牌,
 *@ preCardType,上家的牌型,
 *@ ret = { flag: false,
            cards: []       // 推荐可以出的第一组牌;
        }
 */
cardTool.hasOverComePre = function(my_Cards, pre_Cards, preCardType)
{
    if (my_Cards == undefined || pre_Cards == undefined)
        return false
    if (preCardType == undefined)
    {
        cc.log("上家手牌类型错误")
        return {flag:false, cards:[]}
    }
    var retCards = []

    var myCards = global.GCardTool.convertCardsNumToPoint(my_Cards)
    var mySize = myCards.length
    myCards.sort(global.GCardTool.compByPointDescending)
    //提取所有的单牌/对子/三条/四条;
    var container = {}
    container = global.GCardTool.extract(myCards)

    var pre_cardsInfo   = global.GCardTool.getCardType(pre_Cards)
    var preCards = global.GCardTool.convertCardsNumToPoint(pre_Cards)
    preCards.sort(global.GCardTool.compByPointDescending)     
    var preSize = pre_Cards.length

    if (preSize == 0 && mySize != 0)
    {//先出牌,暂时出一张最小的单牌;
        var ret = global.GCardTool.getBiggerCards(container, 0, 1)
        if (ret.flag == true)
            return {flag:true, cards: ret.cards}
    }

    if( preCardType == global.GConst.CardType.WANG_ZHA)
        return {flag:false, cards:[]}
    
    /////////////////////优先匹配牌型///////////////////
    if (preCardType == global.GConst.CardType.DAN)
    {//单牌;
        var ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 1, false)
        if (ret.flag == true)
            return {flag:true, cards: ret.cards}
    }
    else if (preCardType == global.GConst.CardType.DUI_ZI)
    {//对子;
        if (mySize < 2)
            return {flag:false, cards:[]}
        var ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 2, false)
        if (ret.flag == true)
            return {flag:true, cards: ret.cards}
    }
    else if (preCardType == global.GConst.CardType.SAN_BU_DAI)
    {//三不带;
        if (mySize < 3)
            return {flag:false, cards:[]}
        var ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 3, false)
        if (ret.flag == true)
            return {flag:true, cards: ret.cards}
    }
    else if (preCardType == global.GConst.CardType.SAN_DAI_YI)
    {//三带一
        if (mySize < 4)
            return {flag:false, cards:[]}
        //主值;
        var main_ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 3, false)
        if (main_ret.flag == true)
        {
            var sub_ret = global.GCardTool.getSubCards(container, 1, main_ret.cards )
            if (sub_ret.flag == true)
            {
                retCards = main_ret.cards.concat( sub_ret.cards )
                return {flag:true, cards: retCards}
            }
        }
    }
    else if (preCardType == global.GConst.CardType.SAN_DAI_DUI)
    {//三带对;
        if (mySize < 5)
            return {flag:false, cards:[]}
        var main_ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 3, false)
        if (main_ret.flag == true)
        {
            var sub_ret = global.GCardTool.getSubCards(container, 2, main_ret.cards )
            if (sub_ret.flag == true)
            {
                retCards = main_ret.cards.concat( sub_ret.cards )
                return {flag:true, cards: retCards}
            }
        }
    }

    else if (preCardType == global.GConst.CardType.SI_DAI_DAN)
    {//四带两个单牌;
        if (mySize < 4)
            return {flag:false, cards:[]}

        var main_ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 4)
        if (main_ret.flag == true)
        {
            if (mySize < 6)
            {////只能出炸弹;
                return {flag:true, cards:main_ret.cards}
            }
            else
            {//带2个单;
                var len = 2
                var temp = []
                for(var i=0; i< container.danpai.length; i++)
                {//纯单牌;
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.danpai[i])
                    len--
                }
                for( var i=0; i< container.duizi.length; i++ )
                {//纯对子;
                    if (len==0)
                    {
                        break
                    }
                    for(var j=0; j<2; j++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.duizi[i])
                        len--
                    }
                }
                for( var i=0; i< container.santiao.length; i++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    for(var j=0; j<3; j++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.santiao[i])
                        len--
                    }
                }
                for (var i=0; i< container.sitiao.length; i++)
                {//拆四条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.sitiao[i], main_ret.cards)
                    if (flag == false)
                    {
                        for(var j=0; j<4; j++)
                        {
                            if (len==0)
                            {
                                break
                            }
                            temp.push(container.sitiao[i])
                            len--
                        }
                    }
                }
                if (len == 0)
                {
                    retCards = main_ret.cards.concat(temp)
                    return {flag:true, cards:retCards}
                }
            }
            return {flag:true, cards:main_ret.cards}    //以防bug;
        }
    }
    else if (preCardType == global.GConst.CardType.SI_DAI_DUI)
    {//四带两个对子;
        if (mySize < 4)
            return {flag:false, cards:[]}
        
        var main_ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 4)
        if (main_ret.flag == true)
        {
            if (mySize < 8)
            {////只能出炸弹;
                return {flag:true, cards:main_ret.cards}
            }
            else
            {//辅牌2对子;
                var len = 2
                var temp = []
                for( var i=0; i< container.duizi.length; i++ )
                {//纯对子;
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.duizi[i])
                    temp.push(container.duizi[i])
                    len--
                }
                for( var i=0; i< container.santiao.length; i++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.santiao[i])
                    temp.push(container.santiao[i])
                    len--
                }
                for (var i=0; i< container.sitiao.length; i++)
                {//拆四条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.sitiao[i], main_ret.cards)
                    if (flag == false)
                    {
                        for(var k=0; k<2; k++)
                        {
                            if (len==0)
                                break
                            temp.push(container.sitiao[i])
                            temp.push(container.sitiao[i])
                            len --
                        }
                    }
                }
                if (len == 0)
                {
                    retCards = main_ret.cards.concat(temp)
                    return {flag:true, cards:retCards}
                }
            }
            return {flag:true, cards:main_ret.cards}    //以防bug;
        }
    }
    
    else if (preCardType == global.GConst.CardType.SHUN_ZI)
    {//顺子;
        var ret = global.GCardTool.getBiggerShunZi(myCards, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.SHUN_ZI)
        if (ret.flag == true)
            return ret
    }

    else if (preCardType == global.GConst.CardType.LIAN_DUI)
    {//连对;
        //默认拼接连对牌型时可以拆分三条和四条;
        var des = []
        des = container.duizi.concat( container.santiao )
        des = des.concat( container.sitiao )
        des.sort(global.GCardTool.compByPointAscending)
        //TOTEST:可能有BUG;
        var ret = global.GCardTool.getBiggerShunZi(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.LIAN_DUI)
        if (ret.flag == true)
            return ret
    }

    else if (preCardType == global.GConst.CardType.FEI_JI_BU_DAI)
    {//三顺;可以拆分三条和四条
        var des = []
        des = container.santiao.concat( container.sitiao )
        des.sort( global.GCardTool.compByPointAscending )
        //TOTEST:可能有BUG;
        var ret = global.GCardTool.getBiggerShunZi(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.FEI_JI_BU_DAI)
        if (ret.flag == true)
            return ret
    }
    else if (preCardType == global.GConst.CardType.FEI_JI_DAI_DAN)
    {//飞机带单;
        //先找飞机的主体;可以拆分三条和四条
        var des = []
        des = container.santiao.concat( container.sitiao )
        des.sort( global.GCardTool.compByPointAscending )
        //TOTEST:可能有BUG;
        var ret = global.GCardTool.getBiggerShunZi(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.FEI_JI_BU_DAI)
        if (ret.flag == true)
        {//辅牌;
            var len = pre_cardsInfo.len
            var temp = []
            for(var i=0; i< container.danpai.length; i++)
            {//纯单牌;
                if (len==0)
                {
                    break
                }
                temp.push(container.danpai[i])
                len--
            }
            for( var i=0; i< container.duizi.length; i++ )
            {//纯对子;
                if (len==0)
                {
                    break
                }
                for(var j=0; j<2; j++)
                {
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.duizi[i])
                    len--
                }
            }
            for( var i=0; i< container.santiao.length; i++)
            {//拆三条;
                if (len==0)
                {
                    break
                }
                //不能存在于主值中;
                var flag = global.GCardTool.isContainInCards(container.santiao[i], ret.cards)
                if (flag == false)
                {
                    for(var j=0; j<3; j++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.santiao[i])
                        len--
                    }
                }
            }
            for (var i=0; i< container.sitiao.length; i++)
            {//拆四条;
                if (len==0)
                {
                    break
                }
                var flag = global.GCardTool.isContainInCards(container.sitiao[i], ret.cards)
                if (flag == false)
                {//四条可能被拆分成飞机的翅膀;
                    for(var j=0; j<4; j++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.sitiao[i])
                        len--
                    }
                }
                else
                {//只能加入一次;
                    temp.push(container.sitiao[i])
                    len--
                }
            }
            if (len == 0)
            {
                retCards = ret.cards.concat(temp)
                return {flag:true, cards:retCards}
            }
        }
    }
    else if (preCardType == global.GConst.CardType.FEI_JI_DAI_DUI)
    {//飞机带对子;
        //先找飞机的主体;可以拆分三条和四条
        var des = []
        des = container.santiao.concat( container.sitiao )
        des.sort( global.GCardTool.compByPointAscending )
        //TOTEST:可能有BUG;
        var ret = global.GCardTool.getBiggerShunZi(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.FEI_JI_BU_DAI)
        if (ret.flag == true)
        {//辅牌
            var len = pre_cardsInfo.len
            var temp = []
            for( var i=0; i< container.duizi.length; i++ )
            {//纯对子;
                if (len==0)
                {
                    break
                }
                temp.push(container.duizi[i])
                temp.push(container.duizi[i])
                len--
            }
            for( var i=0; i< container.santiao.length; i++)
            {//拆三条;
                if (len==0)
                {
                    break
                }
                //不能存在于主值中;
                var flag = global.GCardTool.isContainInCards(container.santiao[i], ret.cards)
                if (flag == false)
                {
                    temp.push(container.santiao[i])
                    temp.push(container.santiao[i])
                    len--
                }
            }
            for (var i=0; i< container.sitiao.length; i++)
            {//拆四条;
                if (len==0)
                {
                    break
                }
                var flag = global.GCardTool.isContainInCards(container.sitiao[i], ret.cards)
                if (flag == false)
                {
                    for(var k=0; k<2; k++)
                    {
                        if (len==0)
                            break
                        temp.push(container.sitiao[i])
                        temp.push(container.sitiao[i])
                        len --
                    }
                }
            }
            if (len == 0)
            {
                retCards = ret.cards.concat(temp)
                return {flag:true, cards:retCards}
            }
        }
    }
    else if (preCardType == global.GConst.CardType.ZHA_DAN)
    {//炸弹;
        var main_ret = global.GCardTool.getBiggerCards(container, pre_cardsInfo.beg, 4)
        if (main_ret.flag == true)
            return {flag:true, cards:main_ret.cards}

        if (mySize >= 2 )
        {//我有王炸;
            var retCards = []
            retCards.push(myCards[0])
            retCards.push(myCards[1])
            var ret = global.GCardTool.isWangZha(retCards) 
            if (ret.flag == true)
                return {flag:true, cards: retCards}
        }
        return {flag:false, cards:[]}
    }


    //最后考虑炸弹和王炸;
    if(mySize >= 4)
    {
        var main_ret = global.GCardTool.getBiggerCards(container, -1, 4)   //取任意4条,
        if (main_ret.flag == true)
            return {flag:true, cards:main_ret.cards}
    }
    if (mySize >= 2 )
    {//王炸;
        var retCards = []
        retCards.push(myCards[0])
        retCards.push(myCards[1])
        var ret = global.GCardTool.isWangZha(retCards) 
        if (ret.flag == true)
            return {flag:true, cards: retCards}
    }  

    return {flag:false, cards:[]}
},

//判断des牌组里面是否有比src更大的顺子/连队/三顺的组合;
//@srcbeg,src的牌型起值, srclen,src的牌型长度;
//@type:global.GConst.CardType.SHUN_ZI
//      global.GConst.CardType.LIAN_DUI
//      global.GConst.CardType.FEI_JI_BU_DAI
cardTool.getBiggerShunZi = function(desCards, srcbeg, srclen, type)
{
    desCards.sort(global.GCardTool.compByPointAscending)
    //srcCards.sort(global.GCardTool.compByPointAscending)
    var len_des = desCards.length
    var len_src = srclen //srcCards.length
    var delta = len_des - (len_src - 1)
    if (delta <=0)
        return {flag:false, cards:[]}
    
    var isFind = true
    var bigger_cards = []
    for(var j=0; j<delta; j++)
    {
        isFind = true
        if (desCards[j] > srcbeg)
        {
            for(var i=0; i < len_src; i++)
            {
                var target_val = desCards[j] + i
                if (target_val >= 14)
                {// 2不能算在连子牌型里;
                    isFind = false
                    bigger_cards = []
                    break
                }
                var count = 1
                if (type == global.GConst.CardType.FEI_JI_BU_DAI)
                    count = 3
                else if(type == global.GConst.CardType.LIAN_DUI)
                    count = 2
                else
                    count = 1

                for (var k=0; k<count; k++)
                {
                    bigger_cards.push(target_val)
                }

                var flag = global.GCardTool.isContainInCards(target_val, desCards)
                if (flag == false)
                {
                    isFind = false
                    bigger_cards = []
                    break
                }
            }
            if (isFind == true)
            {
                break
            }
        }
        else
        {
            isFind = false
        }
    }
    return {flag:isFind, cards:bigger_cards}
},


/* 从container中取比[beg/len]大的一种牌, 单牌/对子/三条/四条;
 * @ container = {danpai:[],duizi:[],santiao:[],sitiao:[]}
 * @ beg: 起值(关键值), target_len:取出值长度;
 * @ flag: 是否允许拆分四条,默认或不设置为允许;
 * @ ret = {flag:false, cards:[]}
 **/
cardTool.getBiggerCards = function(container, beg, target_len, flag)
{
    var con = container
    var len = target_len
    var retCards = []
    if (len <= 1)
    {
        for (var i=0; i<con.danpai.length; i++)
        {
            if (con.danpai[i] > beg)
            {
                retCards.push(con.danpai[i])
                return {flag:true, cards:retCards}
            }
        }
    }
    if (len <= 2)
    {
        for (var i=0; i<con.duizi.length; i++)
        {
            if (con.duizi[i] > beg)
            {
                for(var j=0; j<len; j++)
                {
                    retCards.push(con.duizi[i])
                }
                return {flag:true, cards:retCards}
            }
        }

    }
    if (len <= 3)
    {
        for (var i=0; i<con.santiao.length; i++)
        {
            if (con.santiao[i] > beg)
            {
                for(var j=0; j<len; j++)
                {
                    retCards.push(con.santiao[i])
                }
                return {flag:true, cards:retCards}
            }
        }
    }
    if (flag == undefined || flag == true)
    {
        if (len <= 4)
        {
            for (var i=0; i<con.sitiao.length; i++)
            {
                if (con.sitiao[i] > beg)
                {
                    for(var j=0; j<len; j++)
                    {
                        retCards.push(con.sitiao[i])
                    }
                    return {flag:true, cards:retCards}
                }
            }
        }
    }
    return {flag:false, cards:[]}
}
// 从container中取一组辅牌, 单牌/对子/三条;
// @ container = {danpai:[],duizi:[],santiao:[],sitiao:[]}
// @ len:1/2/3, 单牌/对子/三条, 类型长度;
// @ excludes: 需要排除的数值,
// @ ret = {flag:false, cards:[]}
cardTool.getSubCards = function(container, len, excludes)
{
    var con = container
    var len = len
    var retCards = []
    var hash = {}
    if (excludes != undefined)
    {
        for(var i=0, elem; (elem=excludes[i])!=null; i++)
        {
            hash[elem] = true
        }
    }

    if (len <= 1)
    {
        //双王同时存在则剔除双王;
        //var danpai = global.GCardTool.splitShuangWang(con.danpai)
        for (var i=0; i<con.danpai.length; i++)
        {
            retCards.push(con.danpai[i])
            return {flag:true, cards:retCards}
        }
    }
    if (len <= 2)
    {
        for (var i=0; i<con.duizi.length; i++)
        {
            for(var j=0; j<len; j++)
            {
                retCards.push(con.duizi[i])
            }
            return {flag:true, cards:retCards}
        }

    }
    if (len <= 3)
    {
        for (var i=0; i<con.santiao.length; i++)
        {
            // 排除excludes中指定的牌值;
            if (hash[con.santiao[i]] == true)
                continue
            for(var j=0; j<len; j++)
            {
                retCards.push(con.santiao[i])
            }
            return {flag:true, cards:retCards}
        }
    }
    return {flag:false, cards:[]}
}

/*从container中取比[beg/len]大的一组牌, 单牌/对子/三条/四条;
 *@ container = {danpai:[],duizi:[],santiao:[],sitiao:[]}
 *@ beg: 起值(关键值), target_len:取出值长度;
 *@ flag: 是否允许拆分四条, 默认或未设置为允许;
 *@ ret = {flag:false, cards:[]}
 */
cardTool.getBiggerCardsArr = function(container, beg, target_len, flag)
{
    var con = container
    var len = target_len
    var retCards = []
    if (len <= 1)
    {
        for (var i=0; i<con.danpai.length; i++)
        {
            var temp = []
            if (con.danpai[i] > beg)
                temp.push(con.danpai[i])
            if (temp.length > 0)
                retCards.push(temp)
        }
    }
    if (len <= 2)
    {
        for (var i=0; i<con.duizi.length; i++)
        {
            if (con.duizi[i] > beg)
            {
                var temp = []
                for(var j=0; j<len; j++)
                    temp.push(con.duizi[i])
                if (temp.length > 0)
                    retCards.push(temp)
            }
        }

    }
    if (len <= 3)
    {
        for (var i=0; i<con.santiao.length; i++)
        {
            if (con.santiao[i] > beg)
            {
                var temp = []
                for(var j=0; j<len; j++)
                    temp.push(con.santiao[i])
                if (temp.length > 0)
                    retCards.push(temp)
            }
        }
    }
    if (flag == undefined || flag == true)
    {
        if (len <= 4)
        {
            for (var i=0; i<con.sitiao.length; i++)
            {
                if (con.sitiao[i] > beg)
                {
                    var temp = []
                    for(var j=0; j<len; j++)
                        temp.push(con.sitiao[i])
                    if (temp.length > 0)
                        retCards.push(temp)
                }
            }
        }
    }
    return retCards
}

//获取des牌组里所有比src更大的顺子/连队/三顺的组合的集合;
//@srcbeg,src的牌型起值, srclen,src的牌型长度;
//@type:global.GConst.CardType.SHUN_ZI
//      global.GConst.CardType.LIAN_DUI
//      global.GConst.CardType.FEI_JI_BU_DAI
cardTool.getBiggerShunZiArr = function(desCards, srcbeg, srclen, type)
{
    desCards.sort(global.GCardTool.compByPointAscending)
    var len_des = desCards.length
    var len_src = srclen
    var delta = len_des - (len_src - 1)
    
    var isFind = true
    var ret_arr = []            // 二维;
    var bigger_cards = []

    for(var j=0; j<delta; j++)
    {
        isFind = true
        if (desCards[j] > srcbeg)
        {
            for(var i=0; i < len_src; i++)
            {
                var target_val = desCards[j] + i
                if (target_val >= 14)
                {// 2不能算在连子牌型里;
                    isFind = false
                    bigger_cards = []
                    break
                }
                var count = 1
                if (type == global.GConst.CardType.FEI_JI_BU_DAI)
                    count = 3
                else if(type == global.GConst.CardType.LIAN_DUI)
                    count = 2
                else
                    count = 1

                for (var k=0; k<count; k++)
                {
                    bigger_cards.push(target_val)
                }

                var flag = global.GCardTool.isContainInCards(target_val, desCards)
                if (flag == false)
                {
                    isFind = false
                    bigger_cards = []
                    break
                }
            }
            if (isFind == true)
            {
                ret_arr.push(bigger_cards)
                bigger_cards = []
            }
        }   
    }
    return ret_arr
},
//四条和王炸的集;
//@parm:
cardTool.getSitiao_Wangzha = function(container)
{
    var special_arr = []
    special_arr = global.GCardTool.getBiggerCardsArr(container, -1, 4, true)
    var cards = []
    var len = container.danpai.length
    if (len >= 2)
    {
        container.danpai.sort( global.GCardTool.compByPointAscending)
        cards.push(container.danpai[len-1])
        cards.push(container.danpai[len-2])
        var ret = global.GCardTool.isWangZha(cards)
        if (ret.flag == true)
            special_arr.push(cards)
    }    
    return special_arr
}
cardTool.getWangzha = function(container)
{
    var wangzha = []
    var len = container.danpai.length
    if (len >= 2)
    {
        container.danpai.sort( global.GCardTool.compByPointAscending)
        wangzha.push(container.danpai[len-1])
        wangzha.push(container.danpai[len-2])
        var ret = global.GCardTool.isWangZha(wangzha)
        if (ret.flag == true)
            return {flag:true, cards:wangzha}
    }
    return {flag:false, cards:[]}
}

//////////////////////////////////////////////////////////
/////////////提示,获取克制上家牌型的所有牌组序列/////////////
cardTool.getTips = function(my_Cards, pre_Cards, preCardType)
{
    if (preCardType == undefined)
    {
        cc.log("上家出牌类型错误")
        return []
    }

    var pre_cardsInfo = global.GCardTool.getCardType(pre_Cards)
    var preCards = global.GCardTool.convertCardsNumToPoint(pre_Cards)
    preCards.sort(global.GCardTool.compByPointDescending)
    var preSize = pre_Cards.length
    if (pre_cardsInfo.cardType != preCardType)
    {
        cc.log("传入的上家出牌类型和本地计算的出牌类型不匹配")
        return []
    }

    var myCards = global.GCardTool.convertCardsNumToPoint(my_Cards)
    var mySize = myCards.length
    myCards.sort(global.GCardTool.compByPointDescending)
    //提取所有的单牌/对子/三条/四条;
    var container = {}
    container = global.GCardTool.extract(myCards)

    if (preSize == 0 && mySize != 0)
    {//获取玩家先出牌的提示序列组;
        var retCardsArr = this.getFirstTips(myCards)
        return retCardsArr
    }

    if( preCardType == global.GConst.CardType.WANG_ZHA)
        return {flag:false, cards:[]}

    if (preCardType == global.GConst.CardType.DAN)
    {//单牌;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 1, false)
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.DUI_ZI)
    {//对子;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 2, false)
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.SAN_BU_DAI)
    {//三不带;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 3, false)
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.SAN_DAI_YI)
    {//三带一
        //主值;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 3, false)
        var exceptArr = []
        for (var i=0; i<retCardsArr.length; i++)
        {
            var sub_ret = global.GCardTool.getSubCards(container, 1, retCardsArr[i] )
            if (sub_ret.flag == true)
                retCardsArr[i] = retCardsArr[i].concat( sub_ret.cards )
            else
            {//没有可匹配的辅值,标记为排除;
                exceptArr.push(retCardsArr[i])
            }
        }
        for(var i=0; i<exceptArr.length; i++)
        {
            for(var j=0; j<retCardsArr.length; j++)
            {
                if (exceptArr[i].toString() == retCardsArr[j].toString())
                {
                    retCardsArr.splice(j, 1)
                    break
                }
            }
        }

        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.SAN_DAI_DUI)
    {//三带对;
        //主值;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 3, false)
        var exceptArr = []
        for (var i=0; i<retCardsArr.length; i++)
        {
            var sub_ret = global.GCardTool.getSubCards(container, 2, retCardsArr[i] )
            if (sub_ret.flag == true)
                retCardsArr[i] = retCardsArr[i].concat( sub_ret.cards )
            else
            {//没有可匹配的辅值,标记为排除;
                exceptArr.push(retCardsArr[i])
            }
        }
        for(var i=0; i<exceptArr.length; i++)
        {
            for(var j=0; j<retCardsArr.length; j++)
            {
                if (exceptArr[i].toString() == retCardsArr[j].toString())
                {
                    retCardsArr.splice(j, 1)
                    break
                }
            }
        }
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.SI_DAI_DAN)
    {//四带两个单牌;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 4, true)
        if (retCardsArr.length > 0)
        {
            var exceptArr = []
            for (var i=0; i<retCardsArr.length; i++)
            {//两单;
                var len = 2
                var temp = []
                for(var j=0; j< container.danpai.length; j++)
                {
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.danpai[j])
                    len--
                }
                for( var j=0; j< container.duizi.length; j++ )
                {
                    if (len==0)
                    {
                        break
                    }
                    for(var k=0; k<2; k++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.duizi[j])
                        len--
                    }
                }
                for( var j=0; j< container.santiao.length; j++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    for(var k=0; k<3; k++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.santiao[j])
                        len--
                    }
                }
                for (var j=0; j< container.sitiao.length; j++)
                {//拆四条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.sitiao[j], retCardsArr[i])
                    if (flag == false)
                    {
                        for(var k=0; k<4; k++)
                        {
                            if (len==0)
                            {
                                break
                            }
                            temp.push(container.sitiao[j])
                            len--
                        }
                    }
                }
                if (len == 0)
                {
                    retCardsArr[i] = retCardsArr[i].concat(temp)
                }
                else
                {//没有可匹配的辅值,标记为排除;
                    exceptArr.push(retCardsArr[i])
                }
            }
            for(var i=0; i<exceptArr.length; i++)
            {
                for(var j=0; j<retCardsArr.length; j++)
                {
                    if (exceptArr[i].toString() == retCardsArr[j].toString())
                    {
                        retCardsArr.splice(j, 1)
                        break
                    }
                }
            }
        }
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.SI_DAI_DUI)
    {//四带两个对子;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 4, true)
        if (retCardsArr.length > 0)
        {
            var exceptArr = []
            for (var i=0; i<retCardsArr.length; i++)
            {//2对子;
                var len = 2
                var temp = []
                for( var j=0; j< container.duizi.length; j++ )
                {
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.duizi[j])
                    temp.push(container.duizi[j])
                    len--
                }
                for( var j=0; j< container.santiao.length; j++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.santiao[j])
                    temp.push(container.santiao[j])
                    len--
                }
                for (var j=0; j< container.sitiao.length; j++)
                {//拆四条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.sitiao[j], retCardsArr[i])
                    if (flag == false)
                    {
                        for(var k=0; k<2; k++)
                        {
                            if (len==0)
                                break
                            temp.push(container.sitiao[j])
                            temp.push(container.sitiao[j])
                            len --
                        }
                    }
                }
                if (len == 0)
                {
                    retCardsArr[i] = retCardsArr[i].concat(temp)
                }
                else
                {
                    exceptArr.push(retCardsArr[i])
                }
            }
            for(var i=0; i<exceptArr.length; i++)
            {
                for(var j=0; j<retCardsArr.length; j++)
                {
                    if (exceptArr[i].toString() == retCardsArr[j].toString())
                    {
                        retCardsArr.splice(j, 1)
                        break
                    }
                }
            }
        }
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.SHUN_ZI)
    {//顺子;
        var retCardsArr = global.GCardTool.getBiggerShunZiArr(myCards, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.SHUN_ZI)
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.LIAN_DUI)
    {//连对;
        var des = []
        des = container.duizi.concat( container.santiao )
        des = des.concat( container.sitiao )
        des.sort( global.GCardTool.compByPointAscending )
        var retCardsArr = global.GCardTool.getBiggerShunZiArr(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.LIAN_DUI)
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.FEI_JI_BU_DAI)
    {//三顺
        var des = []
        des = container.santiao.concat( container.sitiao )
        des.sort( global.GCardTool.compByPointAscending )
        var retCardsArr = global.GCardTool.getBiggerShunZiArr(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.FEI_JI_BU_DAI)
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }

    else if (preCardType == global.GConst.CardType.FEI_JI_DAI_DAN)
    {//飞机带单;
        var des = []
        des = container.santiao.concat( container.sitiao )
        des.sort( global.GCardTool.compByPointAscending )
        var retCardsArr = global.GCardTool.getBiggerShunZiArr(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.FEI_JI_BU_DAI)
        if (retCardsArr.length > 0)
        {
            var exceptArr = []
            for (var i=0; i<retCardsArr.length; i++)
            {
                var len = pre_cardsInfo.len     //飞机单排数目和主体数目相同;
                var temp = []
                for(var j=0; j< container.danpai.length; j++)
                {
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.danpai[j])
                    len--
                }
                for( var j=0; j< container.duizi.length; j++ )
                {
                    if (len==0)
                    {
                        break
                    }
                    for(var k=0; k<2; k++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.duizi[j])
                        len--
                    }
                }
                for( var j=0; j< container.santiao.length; j++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards( container.santiao[j], retCardsArr[i] )
                    if (flag == false)
                    {
                        for(var k=0; k<3; k++)
                        {
                            if (len==0)
                            {
                                break
                            }
                            temp.push(container.santiao[j])
                            len--
                        }
                    }
                }
                for (var j=0; j< container.sitiao.length; j++)
                {//拆四条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.sitiao[j], retCardsArr[i])
                    if (flag == false)
                    {
                        for(var k=0; k<4; k++)
                        {
                            if (len==0)
                            {
                                break
                            }
                            temp.push(container.sitiao[j])
                            len--
                        }
                    }
                }
                if (len == 0)
                {
                    retCardsArr[i] = retCardsArr[i].concat(temp)
                }
                else
                {//没有可匹配的辅值,标记为排除;
                    exceptArr.push(retCardsArr[i])
                }
            }
            for(var i=0; i<exceptArr.length; i++)
            {
                for(var j=0; j<retCardsArr.length; j++)
                {
                    if (exceptArr[i].toString() == retCardsArr[j].toString())
                    {
                        retCardsArr.splice(j, 1)
                        break
                    }
                }
            }
        }
        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.FEI_JI_DAI_DUI)
    {//飞机带对子;
        var des = []
        des = container.santiao.concat( container.sitiao )
        des.sort( global.GCardTool.compByPointAscending )
        var retCardsArr = global.GCardTool.getBiggerShunZiArr(des, pre_cardsInfo.beg, pre_cardsInfo.len, global.GConst.CardType.FEI_JI_BU_DAI)
        if (retCardsArr.length > 0)
        {
            var exceptArr = []  //需要排除的主值项目;
            for (var i=0; i<retCardsArr.length; i++)
            {//匹配辅值;
                var len = pre_cardsInfo.len
                var temp = []
                for( var j=0; j< container.duizi.length; j++ )
                {
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.duizi[j])
                    temp.push(container.duizi[j])
                    len--
                }
                for( var j=0; j< container.santiao.length; j++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.santiao[j], retCardsArr[i])
                    if (flag == false)
                    {
                        temp.push(container.santiao[j])
                        temp.push(container.santiao[j])
                        len--
                    }
                }
                for (var j=0; j< container.sitiao.length; j++)
                {//拆四条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.sitiao[j], retCardsArr[i])
                    if (flag == false)
                    {
                        for(var k=0; k<2; k++)
                        {
                            if (len==0)
                                break
                            temp.push(container.sitiao[j])
                            temp.push(container.sitiao[j])
                            len --
                        }
                    }
                }
                if (len == 0)
                {
                    retCardsArr[i] = retCardsArr[i].concat(temp)
                }
                else
                {//匹配失败备案;
                    exceptArr.push(retCardsArr[i])
                }
            }
            for(var i=0; i<exceptArr.length; i++)
            {
                for(var j=0; j<retCardsArr.length; j++)
                {
                    if (exceptArr[i].toString() == retCardsArr[j].toString())
                    {
                        retCardsArr.splice(j, 1)
                        break
                    }
                }
            }
        }

        var special_arr = global.GCardTool.getSitiao_Wangzha(container)
        retCardsArr = retCardsArr.concat( special_arr )
        if (retCardsArr.length > 0)
            return retCardsArr
    }
    else if (preCardType == global.GConst.CardType.ZHA_DAN)
    {//炸弹;
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, pre_cardsInfo.beg, 4, true)
        var ret = global.GCardTool.getWangzha(container)
        if (ret.flag == true)
            retCardsArr.push(ret.cards)
        if (retCardsArr.length > 0)
            return retCardsArr
    }

    return []
}

/*获得第一家出牌的提示序列;
 *cards:手牌, container:手牌的分类
 *ret: cards:[]
 */  
cardTool.getFirstTips = function(cards)
{
    var myCards = global.GCardTool.convertCardsNumToPoint(cards)
    var mySize = myCards.length
    myCards.sort(global.GCardTool.compByPointDescending)

    var container = {}
    container = global.GCardTool.extract(myCards)

    var finalArr = []    //二维;
    //仅剩两张优先王炸 
    if (mySize == 2)
    {
        var ret = global.GCardTool.isWangZha(myCards)
        if (ret.flag == true)
        {
            finalArr.push(myCards)
            return finalArr
        }
    }
    //仅剩四张优先炸弹;
    if (mySize == 4)
    {
        var ret = global.GCardTool.isZhaDan(myCards)
        if (ret.flag == true)
        {
            finalArr.push(myCards)
            return finalArr
        }
    }
    //不允许拆掉四条，也不允许出四带二;
    //飞机带对->飞机带单牌->三顺->连对子->顺子->三带对子->三带一->三不带->对子->单牌-> 炸弹;
    //1.飞机带对子;
    {
        var topCount = Math.floor(mySize/5)
        var  retCardsArr= []
        for (var i=topCount; i>=2; i--)
        {//主值长度多到少的降序查找;
            var tempRetArr = global.GCardTool.getBiggerShunZiArr(container.santiao, -1, i, global.GConst.CardType.FEI_JI_BU_DAI)
            if (tempRetArr.length > 0)
                retCardsArr = retCardsArr.concat(tempRetArr)
        }
        if (retCardsArr.length > 0)
        {
            var exceptArr = []  //需要排除的主值项;
            for (var i=0; i<retCardsArr.length; i++)
            {//匹配辅值;
                var len = retCardsArr[i].length / 3         //主体长度;
                var temp = []
                for( var j=0; j< container.duizi.length; j++ )
                {//对子;
                    if (len==0)
                    {
                        break
                    }
                    temp.push(container.duizi[j])
                    temp.push(container.duizi[j])
                    len--
                }
                for( var j=0; j< container.santiao.length; j++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards(container.santiao[j], retCardsArr[i])
                    if (flag == false)
                    {
                        temp.push(container.santiao[j])
                        temp.push(container.santiao[j])
                        len--
                    }
                }
                if (len == 0)
                {
                    retCardsArr[i] = retCardsArr[i].concat(temp)
                }
                else
                {//匹配失败备案;
                    exceptArr.push(retCardsArr[i])
                }
            }
            for(var i=0; i<exceptArr.length; i++)
            {
                for(var j=0; j<retCardsArr.length; j++)
                {
                    if (exceptArr[i].toString() == retCardsArr[j].toString())
                    {
                        retCardsArr.splice(j, 1)
                        break
                    }
                }
            }

            finalArr = finalArr.concat( retCardsArr )
        }
    }
    //2.飞机带单牌;
    {
        var topCount = Math.floor(mySize/4)
        var  retCardsArr= []
        for (var i=topCount; i>=2; i--)
        {//主值长度多到少的降序查找;
            var tempRetArr = []
            tempRetArr = global.GCardTool.getBiggerShunZiArr(container.santiao, -1, i, global.GConst.CardType.FEI_JI_BU_DAI)
            if (tempRetArr.length > 0)
                retCardsArr = retCardsArr.concat(tempRetArr)
        }
        if (retCardsArr.length > 0)
        {
            var exceptArr = []
            for (var i=0; i<retCardsArr.length; i++)
            {
                var len = retCardsArr[i].length / 3
                var temp = []
                //双王同时存在不能作为两张单牌;
                var danpai = global.GCardTool.splitShuangWang(container.danpai)
                for(var j=0; j< danpai.length; j++)
                {
                    if (len==0)
                    {
                        break
                    }
                    temp.push(danpai[j])
                    len--
                }
                for( var j=0; j< container.duizi.length; j++ )
                {
                    if (len==0)
                    {
                        break
                    }
                    for(var k=0; k<2; k++)
                    {
                        if (len==0)
                        {
                            break
                        }
                        temp.push(container.duizi[j])
                        len--
                    }
                }
                for( var j=0; j< container.santiao.length; j++)
                {//拆三条;
                    if (len==0)
                    {
                        break
                    }
                    var flag = global.GCardTool.isContainInCards( container.santiao[j], retCardsArr[i] )
                    if (flag == false)
                    {
                        for(var k=0; k<3; k++)
                        {
                            if (len==0)
                            {
                                break
                            }
                            temp.push(container.santiao[j])
                            len--
                        }
                    }
                }
                if (len == 0)
                {
                    retCardsArr[i] = retCardsArr[i].concat(temp)
                }
                else
                {//没有可匹配的辅值,标记为排除;
                    exceptArr.push(retCardsArr[i])
                }
            }
            for(var i=0; i<exceptArr.length; i++)
            {
                for(var j=0; j<retCardsArr.length; j++)
                {
                    if (exceptArr[i].toString() == retCardsArr[j].toString())
                    {
                        retCardsArr.splice(j, 1)
                        break
                    }
                }
            }

            finalArr = finalArr.concat( retCardsArr )
        }
    }
    //3.三顺
    {
        var topCount = Math.floor(mySize/3)
        var  retCardsArr= []
        for (var i=topCount; i>=2; i--)
        {//主值长度多到少的降序查找;
            var tempRetArr = []
            tempRetArr = global.GCardTool.getBiggerShunZiArr(container.santiao, -1, i, global.GConst.CardType.FEI_JI_BU_DAI)
            if (tempRetArr.length > 0)
                retCardsArr = retCardsArr.concat(tempRetArr)
        }
        finalArr = finalArr.concat( retCardsArr )
    }
    //4.连对子
    {
        var topCount = Math.floor(mySize/2)
        var retCardsArr = []
        for (var i=topCount; i>=3; i--)
        {
            var tempRetArr = []
            var des = []
            des = container.duizi.concat( container.santiao )
            tempRetArr = global.GCardTool.getBiggerShunZiArr(des, -1, i, global.GConst.CardType.LIAN_DUI)
            if (tempRetArr.length > 0)
                retCardsArr = retCardsArr.concat(tempRetArr)
        }
        finalArr = finalArr.concat( retCardsArr )
    }
    //5.顺子
    {
        var topCount = mySize > 12 ? 12:mySize
        var retCardsArr = []
        //优先单牌的顺子;
        for (var i=topCount; i>=5; i--)
        {
            var tempRetArr = []
            tempRetArr = global.GCardTool.getBiggerShunZiArr(container.danpai, -1, i, global.GConst.CardType.SHUN_ZI)
            if (tempRetArr.length > 0)
                retCardsArr = retCardsArr.concat(tempRetArr)
        }
        //单牌+对子+三条的顺子;
        var des = []
        des = container.danpai.concat(container.duizi)
        des = des.concat(container.santiao)
        for (var i=topCount; i>=5; i--)
        {
            var tempRetArr = []
            tempRetArr = global.GCardTool.getBiggerShunZiArr(des, -1, i, global.GConst.CardType.SHUN_ZI)
            if (tempRetArr.length > 0)
                retCardsArr = retCardsArr.concat(tempRetArr)
        }
        finalArr = finalArr.concat( retCardsArr )
    }
    //6.三带对子
    {
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, -1, 3, false)
        var exceptArr = []
        for (var i=0; i<retCardsArr.length; i++)
        {
            var sub_ret = global.GCardTool.getSubCards(container, 2, retCardsArr[i] )
            if (sub_ret.flag == true)
                retCardsArr[i] = retCardsArr[i].concat( sub_ret.cards )
            else
            {//没有可匹配的辅值,标记为排除;
                exceptArr.push(retCardsArr[i])
            }
        }
        for(var i=0; i<exceptArr.length; i++)
        {
            for(var j=0; j<retCardsArr.length; j++)
            {
                if (exceptArr[i].toString() == retCardsArr[j].toString())
                {
                    retCardsArr.splice(j, 1)
                    break
                }
            }
        }

        finalArr = finalArr.concat( retCardsArr )
    }
    //7.三带一
    {
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, -1, 3, false)
        var exceptArr = []
        for (var i=0; i<retCardsArr.length; i++)
        {
            var sub_ret = global.GCardTool.getSubCards(container, 1, retCardsArr[i] )
            if (sub_ret.flag == true)
                retCardsArr[i] = retCardsArr[i].concat( sub_ret.cards )
            else
            {//没有可匹配的辅值,标记为排除;
                exceptArr.push(retCardsArr[i])
            }
        }
        for(var i=0; i<exceptArr.length; i++)
        {
            for(var j=0; j<retCardsArr.length; j++)
            {
                if (exceptArr[i].toString() == retCardsArr[j].toString())
                {
                    retCardsArr.splice(j, 1)
                    break
                }
            }
        }
        finalArr = finalArr.concat( retCardsArr )
    }
    //8.三不带
    {
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, -1, 3, false)
        finalArr = finalArr.concat( retCardsArr )
    }
    //9.对子
    {
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, -1, 2, false)
        finalArr = finalArr.concat( retCardsArr )
    }
    //10.单牌
    {
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, -1, 1, false)
        finalArr = finalArr.concat( retCardsArr )
    }
    //11.炸弹;
    {
        var retCardsArr = global.GCardTool.getBiggerCardsArr(container, -1, 4, true)
        finalArr = finalArr.concat( retCardsArr )
    }

    //排重;
    for (var m=0; m<finalArr.length; m++)
    {
        finalArr[m].sort(global.GCardTool.compByPointAscending)
    }
    finalArr = global.GCardTool.unique(finalArr)
    //Arr_num降序;
    //finalArr.sort(global.GCardTool.compByArrLengthDescending)
    return finalArr
}

//剔除单牌组里同时存在的双王;
cardTool.splitShuangWang = function(danpai)
{
    var cards = []
    var len = danpai.length
    danpai.sort(global.GCardTool.compByPointAscending)
    cards = danpai.concat()
    if (len>=2 && cards[len-1] >= global.GConst.Joker.JokerA && cards[len-2] >= global.GConst.Joker.JokerA)
    {
        cards.splice( len-2, 2 )
    }
    return cards
}