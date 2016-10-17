local filelog = require "filelog"
local filename = "logsvrnoticemsg.lua"
local msghelper = require "logsvrmsghelper"

local LogsvrNoticeMsg = {}

function LogsvrNoticeMsg.process(session, source, event, ...)
	local f = LogsvrNoticeMsg[event]
	if f == nil then
		filelog.sys_error(filename.." LogsvrNoticeMsg.process invalid event:"..event)
		return nil
	end
	f(...)
end


return LogsvrNoticeMsg