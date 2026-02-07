persistance = {}
--[[
    More testing need to be done, Instable

]]
function persistance.loadAndClean(path)
    local loaded = persistance.load(path)
    --sb.logInfo("arlm.persist.%s : %s", path, loaded)
    persistance.clean(path)

    return loaded
end

function persistance.save(path, ...)
    if not root.getConfiguration("arlm") then root.setConfiguration("arlm", {}) end
    if not root.getConfigurationPath("arlm.persist") then root.setConfigurationPath("arlm.persist", {}) end

    root.setConfigurationPath("arlm.persist."..path, table.pack(...))
end

function persistance.load(path)
    if not root.getConfiguration("arlm") then root.setConfiguration("arlm", {}) return {} end
    if not root.getConfigurationPath("arlm.persist") then root.setConfigurationPath("arlm.persist", {}) return {} end
    local loaded = root.getConfigurationPath("arlm.persist."..path)

    if loaded then
        return table.unpack(loaded) or {}
    else
        return {}
    end
end

function persistance.clean(path) -- should be called in the dismissed func or similar
    if not root.getConfiguration("arlm") then root.setConfiguration("arlm", {}) return {} end
    if not root.getConfigurationPath("arlm.persist") then root.setConfigurationPath("arlm.persist", {}) return {} end
    if root.getConfigurationPath("arlm.persist."..path) then root.setConfigurationPath("arlm.persist."..path, nil) end
end