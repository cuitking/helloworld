
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
--w.wangbin = "55"  

--[[
程序陷入了死循环。因为w.wangbin这个元素本来就不存在表中，然后这里不断执行进入__newindex，陷入了死循环。

--]]




------------------------------------------------------------------------
--[[
rawget 和 rawset
有时需要get 和set表的索引，不想使用metatable.你可能回猜想, rawget 允许你得到索引无需__index,

 rawset允许你设置索引的值无需__newindex (不，相对传统元表的方式，这些不会提高速度)。为了避免陷

在无限循环里，你才需要使用它们。 在上面的例子里, t[key] = value * value将再次调用__newindex

函数，这让你的代码陷入死循环。使用rawset(t, key, value * value) 可以避免。

你可能看到，使用这些函数, 我们必须传递参数目标table, key, 当你使用rawset时还有value。


下面我们来封装一个2D 向量类(感谢 hump.vector 的大量代码)。代码太长你可以查看gist #1055480，

代码里有大量的metatable概念，(注意，如果你之前没接触面向对象可能会有点难)。

Vector = {}
Vector.__index = Vector
首先声明了一个Vector class, 设置了__index 索引指向自身。 这在干啥呢？你会发现我们把所有的元表

放到Vector类里了。你将看到在Lua里实现OOP (Object-Oriented Programming)的最简单方式。Vector

表代表类, 它包含了所有方法，类的实例可以通过Vector.new (如下) 创建了。

function Vector.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, Vector)
end
它创建了一个新的带有x、y 属性的表, 然后把metatable设置到Vector 类。我们知道Vector 包含了所有的

元方法，特别是 __index。这意味着我们通过新表可以使用所有Vector里方法。

另外重要的一行是:

setmetatable(Vector, { __call = function(_, ...) return Vector.new(...) end })
这意味着我们可以创建一个新的Vector 实例通过 Vector.new或者仅Vector。

最后重要的事,你可能没注意冒号语法。当我们定义一个带有冒号的函数时，如下：

function t:method(a, b, c)
  -- ...
end
我们真正定义的是这个函数:

function t.method(self, a, b, c)
  -- ...
end
这是一个语法糖，帮助我们使用OOP。当调用函数时，我们可以这样使用冒号语法:

-- these are the same
t:method(1, 2, 3)
t.method(t, 1, 2, 3)
我们如何使用 Vector 类? 示例如下:

a = Vector.new(10, 10)
b = Vector(20, 11)
c = a + b
print(a:len()) -- 14.142135623731
print(a) -- (10, 10)
print(c) -- (30, 21)
print(a < c) -- true
print(a == b) -- false
因为Vector里有__index，我们可以在实例里使用它的所有方法。

--]]

