local skynet = require "skynet"
local configdao = require "configdao"

skynet.start(function()
	print("Server start")
	skynet.newservice("systemlog")
    local confcentersvr = skynet.newservice("confcenter")
    skynet.call(confcentersvr, "lua", "start")
    print("confcenter start success")    

    --skynet.newservice("marqueemsg")

    local gatesvrs = configdao.get_svrs("gatesvrs")
    if gatesvrs == nil then
        print("gatesvrd start failed gatesvrs == nil")
        skynet.exit()
    end
    local gatesvr = gatesvrs[skynet.getenv("svr_id")]
    if gatesvr == nil then
        print("gatesvrd start failed gatesvr == nil", skynet.getenv("svr_id"))
        skynet.exit()           
    end

    --加载pbcservice
    local pbcservice = skynet.uniqueservice("pbcservice")
    skynet.call(pbcservice, "lua", "init", {protofile=skynet.getenv("proto_config")}) 

    skynet.newservice("debug_console", gatesvr.debug_console_port)

    --local timersvr = skynet.newservice("timercenter")
    --skynet.call(timersvr, "lua", "init", gatesvr.timersize)

    --[[local mongologs = configdao.get_svrs("mongologs")
    if mongologs ~= nil then
        for id, conf in pairs(mongologs) do
            local svr = skynet.newservice("mongolog", id)
            skynet.call(svr, "lua", "init", conf)            
        end
    end]]

    local proxys = configdao.get_svrs("proxys")
    if proxys ~= nil then
        for id, conf in pairs(proxys) do
            local svr = skynet.newservice("proxy", id)
            conf.svr_id = skynet.getenv("svr_id")
            skynet.call(svr, "lua", "init", conf)            
        end 
    end
    
    local params = gatesvr.svr_ip..","..gatesvr.svr_port..","..gatesvr.svr_gate_type..","..gatesvr.svr_netpack..","..gatesvr.svr_tcpmng..","..skynet.getenv("svr_id")
	local watchdog = skynet.newservice("gatesvrd", params)
	skynet.call(watchdog, "lua", "cmd", "start", {
		port = gatesvr.svr_port,
		maxclient = gatesvr.maxclient,
		nodelay = true,
        agentsize = gatesvr.agentsize,
        agentincr = gatesvr.agentincr,
        svr_netpack = gatesvr.svr_netpack,
	})
	print("gatesvrd start success")
	skynet.exit()
end)
