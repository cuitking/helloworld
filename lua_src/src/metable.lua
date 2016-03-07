
Window = {}

Window.prototype = {x = 0, y = 0, width = 100, height = 100 }

Window.mt = {}

function Window.new(o)
	setmetatable(o, Window.mt)
	return o
end

Window.mt.__index = Window.prototype

Window.mt.__newindex = function (table, key, value )
	if  key == "xxxx" then
		rawset(table,"xxxx", "fucker")
	end
end

local w = Window.new{x = 10, y = 20}
w.xxxx = 555
print(w.xxxx)

--[[
一、__index的理解
__index是:当我们访问一个表中的元素不存在时，则会触发去寻找__index元方法，如果不存在，则返回nil，如果存在，则返回结果。
--]]

Window = {}

Window.prototype = { x = 0, y = 0, width = 100, height = 100}
Window.mt = {}

function Window.new(o)
	-- body
	setmetatable(o, Window.mt)
	return o
end
Window.mt.__index = function(t,value)
	return 1000
end

local c = Window.new{x = 300, y = 300}

print(c.x,c.y,c.xxxx)
--[[
打印结果是:1000。这里可以看出，我们在new的时候，w这个表里其实没有wangbin这个元素的，我们重写了元表中的__index，
使其返回1000，意思是:如果你要寻找的元素，该表中没有，那么默认返回1000。
备注:__index也可以是一个表，我们这里也可以写__index = {xxxx = 1000},打印的值仍然可以是1000。
--]]

--[[
二、__newindex的理解
__newindex：当给你的表中不存在的值进行赋值时，lua解释器则会寻找__newindex元方法，发现存在该方法，则执行该方法进行赋值，
注意，是使用rawset来进行赋值，至于原因，后面会讲到。
--]]

Window.mt = {}

function Window.new(o)
	setmetatable(o, Window.mt)
	return o
end

Window.mt.__index = function(t,value)
	return 500
end

Window.mt.__newindex = function(t, key, value)
	if key == "yyy" then
		rawset(t, "yyy", "zzz")
	end
end

w = Window.new{x = 60, y = 60}
w.yyy = "66"
print(w.yyy)

--[[
	ok，这里的打印结果是:zzz。w这个表里本来没有yyy这个元素的，我们重写了元表中__newindex，并在__newindex方法中重新进行赋值操作，
	然后，我们对这个本不存在的原色w.yyy进行赋值时，执行__newindex方法的赋值操作，最后，打印结果便是:zzz
--]]

--[[
	rawget是为了绕过__index而出现的，直接点，就是让__index方法的重写无效。
	rawget是只访问当前table而不继续访问__index元方法
--]]

Window = {}  
  
Window.prototype = {x = 0 ,y = 0 ,width = 100 ,height = 100,}  
Window.mt = {}  
function Window.new(o)  
    setmetatable(o ,Window.mt)  
    return o  
end  
Window.mt.__index = function (t ,key)  
    return 1000  
end  
Window.mt.__newindex = function (table ,key ,value)  
    if key == "wangbin" then  
        rawset(table ,"wangbin" ,"yes,i am")  
    end  
end  
w = Window.new{x = 10 ,y = 20}  
print(w.wangbin)
print(rawget(w ,w.wangbin))  



Window = {}  
Window.prototype = {x = 0 ,y = 0 ,width = 100 ,height = 100,}  
Window.mt = {}  
function Window.new(o)  
    setmetatable(o ,Window.mt)  
    return o  
end  
Window.mt.__index = function (t ,key)  
    return 1000  
end  
Window.mt.__newindex = function (table ,key ,value)  
    table.key = "yes,i am"  
end  
w = Window.new{x = 10 ,y = 20}  
w.wangbin = "55"  

--[[
程序陷入了死循环。因为w.wangbin这个元素本来就不存在表中，然后这里不断执行进入__newindex，陷入了死循环。

--]]



