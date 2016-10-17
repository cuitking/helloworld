local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "loginsvrhelper"
local base = require "base"
local msgproxy = require "msgproxy"
local configdao = require "configdao"
local filename = "loginsvrcmd.lua"
local LoginsvrCMD = {}

function LoginsvrCMD.process(session, source, event, ...)
	local f = LoginsvrCMD[event] 
	if f == nil then
		filelog.sys_error(filename.."Loginsvrd LoginsvrCMD.process invalid event:"..event)
		return nil
	end
	f(...)
end

function LoginsvrCMD.start(conf)
	local server = msghelper:get_server()
	server.tcpmng.init(server, "agent", conf.agentsize, conf.agentincr, conf.svr_netpack)
	base.skynet_retpack(true)

	skynet.fork(function()
		skynet.sleep(1000)
		skynet.call(server.gate_service, "lua", "open" , conf)
	end)
end

function LoginsvrCMD.close(...)
	local server = msghelper:get_server()
	server:exit_service()	
end

function LoginsvrCMD.agentexit(fd)
	local server = msghelper:get_server()
	server.tcpmng.agentexit(fd)
end

function LoginsvrCMD.reload(...)
	base.skynet_retpack(1)
	filelog.sys_error("LoginsvrCMD.reload start")

	configdao.reload()

	skynet.sleep(200)

	msgproxy.reload()
	
	filelog.sys_error("LoginsvrCMD.reload end")
end

return LoginsvrCMD