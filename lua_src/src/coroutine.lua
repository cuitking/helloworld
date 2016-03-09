--[[
create a coroutine  -----coroutine.create()
You create a coroutine with a call to coroutine.create. 
Its sole argument is a function that is the main function of the coroutine. 
The create function only creates a new coroutine and returns a handle to it (an object of type thread); 
it does not start the coroutine execution.

When you first call coroutine.resume, passing as its first argument a thread returned by coroutine.create, 
the coroutine starts its execution, at the first line of its main function. Extra arguments passed to 
coroutine.resume are passed on to the coroutine main function. After the coroutine starts running, 
it runs until it terminates or yields



--]]