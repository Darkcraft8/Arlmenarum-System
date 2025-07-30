local prepareStorage = function()
    local generatedStorage = false
    if not root.getConfigurationPath("Arlmenarum") then root.setConfigurationPath("Arlmenarum", {}) generatedStorage = true end
    if not root.getConfigurationPath("Arlmenarum.System") then root.setConfigurationPath("Arlmenarum.System", {}) generatedStorage = true end
    if not root.getConfigurationPath("Arlmenarum.System.Sector") then root.setConfigurationPath("Arlmenarum.System.Sector", {}) generatedStorage = true end

    if generatedStorage then sb.logInfo("[Arlmenarum] : Storage For The Sector System Has Been Prepared. Path -> \"Arlmenarum.System.Sector\" ") end
end
playerId, playerUuid = nil, nil
function init()
    prepareStorage()
    
    playerId, playerUuid = config.getParameter("playerId"), config.getParameter("playerUuid")
    if (not playerUuid) or (not playerId) then stagehand.die() return end
    if not world.entityExists(playerId) then stagehand.die() end
    sb.logInfo("[Arlmenarum System] stagehand %s has been spawned to act as sector \"middleman\" for player %s:%s", stagehand.id(), playerId, world.entityName(playerId))
    world.sendEntityMessage(playerId, "sectorStagehand", stagehand.id())
    
    message.setHandler("goodbye", function(messageName, isLocal, _playerId)
        if playerId == _playerId then
            stagehand.die()
        end
    end)

    message.setHandler("region", function(messageName, isLocal, sectorName, regionName)
        
    end)
end

local repositionTimer = 0
function update()
    if (not playerUuid) or (not playerId) then stagehand.die() return end
    if not world.entityExists(playerId) then
        stagehand.die()
    elseif repositionTimer > 0 then
        repositionTimer = repositionTimer - script.updateDt()
    else
        repositionTimer = 1
        stagehand.setPosition(world.entityPosition(playerId))
    end
end

function uninit()
    sb.logInfo("[Arlmenarum System] stagehand %s has finished his tasks", stagehand.id())
    stagehand.die()
end