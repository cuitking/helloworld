local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "logsvrmsghelper"
local filename = "logsvrcmd.lua"
local Logsvrcmd = {}

function Logsvrcmd.process(session, source, event, ...)
	local f = Logsvrcmd[event]
	if f == nil then
		filelog.sys_error(filename.."Logsvrcmd.process invalid event:"..event)
		return nil
	end
	f(...)	 
end

function Logsvrcmd.start(conf)
	local server = msghelper:get_server()
	msghelper:set_idle_logger_pool(conf)

	skynet.retpack(true)
end
return Logsvrcmd