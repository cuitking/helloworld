--
-- Created by IntelliJ IDEA.
-- User: juzhong
-- Date: 2016/10/11
-- Time: 17:38
-- To change this template use File | Settings | File Templates.
--

local filelog = require "filelog"
local msghelper = require "loggerobjhelper"
local base = require "base"
require "enum"

local LoggerobjNotice = {}
function LoggerobjNotice.process(session, source, event, ...)
    local f = LoggerobjNotice[event]
    if f == nil then
        filelog.sys_error(filename.." TableNotice.process invalid event:"..event)
        return nil
    end
    f(...)
end

function LoggerobjNotice.testlogserver(logglevel)
    filelog.sys_error("-------------test--------",logglevel)
end


return LoggerobjNotice


