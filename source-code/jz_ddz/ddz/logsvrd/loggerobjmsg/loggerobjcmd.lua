--
-- Created by IntelliJ IDEA.
-- User: juzhong
-- Date: 2016/10/11
-- Time: 17:54
-- To change this template use File | Settings | File Templates.
--
local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "loggerobjhelper"
local filename = "loggerobjcmd.lua"
local LoggerobjCmd = {}

function LoggerobjCmd.process(session, source, event, ...)
    local f = LoggerobjCmd[event]
    if f == nil then
        filelog.sys_error(filename.." AgentCMD.process invalid event:"..event)
        return nil
    end
    f(...)
end


return LoggerobjCmd


