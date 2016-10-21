local skynet = require "skynet"
local helperbase = require "helperbase"
local filelog = require "filelog"
local servicepoolmng = require "incrservicepoolmng"

local LogsvrmsgHelper = helperbase:new({})

function LogsvrmsgHelper:set_idle_logger_pool(conf)
    filelog.sys_error("----------set_idle_logger_pool-----",conf)
    for k, v in pairs(conf) do
    	self.server.logger_pool[tostring(k)] = skynet.newservice("loggerobj")
    end

end


function LogsvrmsgHelper:loadloggercfg(conf)
	-- body
	for key, value in pairs(self.server.logger_pool) do
		local result = skynet.call(value, "lua", "cmd", "start", conf[key], skynet.getenv("svr_id"))
	end
end
return	LogsvrmsgHelper