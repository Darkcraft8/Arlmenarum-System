--[[
    A bunch of check that can be reused
]]
function isOwner() -- return if the player uuid is the same as the object owner
    if pane.sourceEntity() then
        local sourceEntity = pane.sourceEntity()
        local owner = config.getParameter("owner")
        if world.entityType(sourceEntity) == "object" then
            local objectParam = world.getObjectParameter(sourceEntity, "")
            
            if objectParam.owner then
                owner = objectParam.owner
            end
        end
        --sb.logInfo("%s, %s, %s", player.uniqueId(), owner, player.uniqueId() == owner)
        return player.uniqueId() == owner
    end
    sb.logInfo("Pane doesn't have a source... expecting it to be opener by player")
    return true
end

local isUsingArlmUIMemory = nil -- only here so that we don't reopen interface.config after already checking
function isUsingArlmUI() -- only here in case someone want to integrate support for arlm-ui to the object
    if isUsingArlmUIMemory == nil then
        isUsingArlmUIMemory = (root.assetJson("/interface.config") or {}).arlmUI_Installed or false
    end
    return isUsingArlmUIMemory
end