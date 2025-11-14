-- *sigh*... implementation of a system to separate the normal universe space from modded ones, meant for either custom space sector or other world/universe like sub-space or thing like that... would have been cool to have a fully fledged cyberspace themed sub-universe/sector
sector = {}
sectorStorage = {
    call = {
        init = function()
            local stagehand = sector.stagehand()
            if stagehand then
                sb.logInfo("[Arlmenarum System] stagehand %s is your sector \"middleman\"", stagehand)
            end
        end,

        uninit = function()
            uninit()
        end
    }
}
function init()
    config = root.assetJson("/d8Arlmenarum/System/oSB/cockpit/sector/sector.config")
    for _, scriptPath in pairs(config.clientScripts) do require(scriptPath) end
    message.setHandler("sectorStagehand", function(messageName, isLocal, stagehandId)
        storage.stagehand = stagehandId
    end)
    message.setHandler("sectorCall", function(messageName, isLocal, type, ...)
        if not isLocal then return end
        if sectorStorage.call[type] then return sectorStorage.call[type](...) end
    end)
end

function postInit()
    if postInitDone then return end
    postInitDone = true
    --local stagehand = sector.stagehand()
    if stagehand then
        sb.logInfo("[Arlmenarum System] stagehand %s is your sector \"middleman\"", stagehand)
    end
end

local initTimer = 2
function update(dt)
    if initTimer > 0 then initTimer = initTimer - 1 else postInit() end
    if storage.stagehand then
        sb.setLogMap("[Arlmenarum System] stagehand", "%s is your sector \"middleman\"", storage.stagehand)
    end
end

function uninit()
    if storage.stagehand then
        if world.entityExists(storage.stagehand) then
            world.sendEntityMessage(storage.stagehand, "goodbye", player.id())
        end
        storage.stagehand = nil
    end
end

function sector.stagehand()
    local spawnStagehand = function()
        local stagehand = world.spawnStagehand(world.entityPosition(player.id()), "ArlmSys_sectorMiddleman", {
            playerId = player.id(),
            playerUuid = player.serverUuid()
        })
        return stagehand
    end
    if not storage.stagehand then
        storage.stagehand = spawnStagehand()
    else
        if not world.entityExists(storage.stagehand) then
            storage.stagehand = spawnStagehand()
        end
    end   
    
    return storage.stagehand
end

function sector.serverPlayerSave(sectorName)
    local stagehand = sector.stagehand()
    if stagehand then
        world.sendEntityMessage(stagehand, "playerSave", sectorName)
    end
end

function sector.curRegion(sectorName, position)
    local sectorCfg = config.sectors[sectorName]
    local chunkId = "X" .. math.floor(position[1] / sectorCfg.chunkSize) .. "Y" .. math.floor(position[2] / sectorCfg.chunkSize)
    --regionId = 
end

function sector.regionContent(sectorName, regionId)
    local stagehand = sector.stagehand()
    if stagehand then
        return world.sendEntityMessage(stagehand, "region", sectorName, regionName)
    end
end