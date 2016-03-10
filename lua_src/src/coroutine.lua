--[[
coroutine.create()	创建coroutine，返回coroutine， 参数是一个函数，当和resume配合使用的时候就唤醒函数调用
coroutine.resume()	重启coroutine，和create配合使用
coroutine.yield()	挂起coroutine，将coroutine设置为挂起状态，这个和resume配合使用能有很多有用的效果
coroutine.status()	查看coroutine的状态
注：coroutine的状态有三种：dead，suspend，running，具体什么时候有这样的状态请参考下面的程序
coroutine.wrap（）	创建coroutine，返回一个函数，一旦你调用这个函数，就进入coroutine，和create功能重复
coroutine.running()	返回正在跑的coroutine，一个coroutine就是一个线程，当使用running的时候，就是返回一个corouting的线程号



--]]
local co1 = coroutine.create(
	function(i)
		print(i)
		end
)

coroutine.resume(co1,100) ---100
print(coroutine.status(co1)) ---dead
------example 2 -------------

local co2 = coroutine.wrap(
	function ( ... )
		print( ... )
	end)
co2("key")

print("-----------------------")
co3 = coroutine.create(
	function()
		for i=1, 10 do
			print(i)
			if i == 3 then
				print(coroutine.status(co3)) --- co3使用全局变量(局部变量会导致co3 为nil)
				print(coroutine.running())
			end
			coroutine.yield()
		end
	end
	)

coroutine.resume(co3)
coroutine.resume(co3)
coroutine.resume(co3)

print(coroutine.status(co3))
print(coroutine.running())

print("--------------------------")
--[[
coroutine.running就可以看出来,coroutine在底层实现就是一个线程。
当create一个coroutine的时候就是在新线程中注册了一个事件。
当使用resume触发事件的时候，create的coroutine函数就被执行了，当遇到yield的时候就代表挂起当前线程，等候再次resume触发事件。
--]]

----------------example3---------------

function foo(a)
	print("foo function print",a)
	return coroutine.yield(2 * a)
end

co4 = coroutine.create(function (a, b)
	print("first coroutine out", a, b)
	local r = foo(a+1)

	print("second  coroutine out", r)
	local r, s = coroutine.yield(a + b, a - b)

	print("third coroutine ,", r,s)

	return b, "coroutine over !!!"

end)

print("main  ", coroutine.resume(co4, 1, 10)) ----
print("--------xxx----------")

print("main ", coroutine.resume(co4, "r"))
print("--------xxxx--------------")

print("main ", coroutine.resume(co4, "x","y"))
print("--------xxxxxx-------------")

print("main ", coroutine.resume(co4, "x", "y"))
print("--------end---------")
--[[

first coroutine out	1	10
foo function print	2
main  	true	4
--------xxx----------
second  coroutine out	r
main 	true	11	-9
--------xxxx--------------
third coroutine ,	x	y
main 	true	10	coroutine over !!!
--------xxxxxx-------------
main 	false	cannot resume dead coroutine

以上实例接下如下：

    调用resume，将协同程序唤醒,resume操作成功返回true，否则返回false；
    协同程序运行；
    运行到yield语句；
    yield挂起协同程序，第一次resume返回；（注意：此处yield返回，参数是resume的参数）
    第二次resume，再次唤醒协同程序；（注意：此处resume的参数中，除了第一个参数，剩下的参数将作为yield的参数）
    yield返回；
    协同程序继续运行；
    如果使用的协同程序继续运行完成后继续调用 resume方法则输出：cannot resume dead coroutine

resume和yield的配合强大之处在于，resume处于主程中，它将外部状态（数据）传入到协同程序内部；
而yield则将内部的状态（数据）返回到主程中。


--]]
--------------------------------