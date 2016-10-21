local function generate_uuid()

    local template ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    local status, urand = pcall(io.open,"/dev/urandom", "r")
    local d = urandd:read(4)
    math.randomseed(os.time() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296))
    local uuid = string.gsub(template, "x", 
                    function (c)
                    local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
                    return string.format("%x", v)
                    end)

    io.close(urand)
    return uuid
end

local function get_random()
    local status, urand = pcall(io.open, '/dev/urandom', 'rb')
    if not status then
        return nil
    end
    local b = 4
    local m = 256
    local n, s = 0, urand:read (b)

    for i = 1, s:len () do
        n = m * n + s:byte (i)
    end
    io.close(urand)
    return n
end

