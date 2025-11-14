--[[
    A simple queueing system for sb.setLogMap
--]]
logMap = {
    data = {},
    func = {}
}

logMap.func.queue = function(self, duration, key, ...)
    if not (duration or key) then return end

    if not logMap.data[key] then logMap.data[key] = {} end
    
    for i = 1, 200 do 
        if not logMap.data[key][tostring(i)] then
            logMap.data[key][tostring(i)] = {
                duration = duration or 1,
                args = table.pack(...)
            }
            break
        end
    end
end

logMap.func.update = function(self, dt)
    --sb.setLogMap("0.0| logMap Queue", "data %s", logMap.data)
    for key, data in pairs(logMap.data or {}) do
        local num = #data
        for i = 1, 200 do
            local cfg = logMap.data[key][tostring(i)]
            if cfg then
                --sb.setLogMap("0.1| logMap Queue", "i = %s", i)
                if cfg.duration < 0 then
                    logMap.data[key][tostring(i)] = nil
                else
                    logMap.data[key][tostring(i)].duration = cfg.duration - dt
                    if type(cfg.args) ~= "string" then
                        sb.setLogMap(key, table.unpack(cfg.args))
                    else
                        sb.setLogMap(key, cfg.args)
                    end
                    break
                end
            end
        end
        for i = 1, 200 do
            if not logMap.data[key][tostring(i)] then
                --sb.setLogMap("0.2| logMap Queue", "clearing queue %s", i + 1)
                logMap.data[key][tostring(i)] = logMap.data[key][tostring(i + 1)]
                logMap.data[key][tostring(i + 1)] = nil
                --break
            end
        end
    end
end

