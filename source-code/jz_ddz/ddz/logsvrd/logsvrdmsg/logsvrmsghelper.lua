local skynet = require "skynet"
local helperbase = require "helperbase"
local servicepoolmng = require "incrservicepoolmng"

local LogsvrmsgHelper = helperbase:new({})

function LogsvrmsgHelper:set_idle_logger_pool(conf)
    ----self.server.idle_table_mng = servicepoolmng:new({}, {service_name="loggerobj", service_size=conf.loggersize, incr=conf.loggerinrc})
    while (#self.logger_pool < conf.loggersize) do
        self.logger_pool[#self.logger_pool+1] = skynet.newservice(conf.service_name)

    end
end
return	LogsvrmsgHelper