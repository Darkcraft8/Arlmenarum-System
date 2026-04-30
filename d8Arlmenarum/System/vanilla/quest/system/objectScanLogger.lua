function init()
    message.setHandler("objectScanned", function(...) onObjectScanned(...) end)    
end

local initTimer = 2
function update(dt)
    if initTimer > 0 then initTimer = initTimer - 1 return end
    if player.save then
        if player.getProperty("fetchedVanillaScannedObjects") then return end
        if player.getProperty("arlmSys_fetchVanScanObjects") then return end
        local playerSave = player.save()
        for _, objectName in pairs(playerSave.log.scannedObjects or {}) do
            onObjectScanned(nil, nil, objectName)
        end
        player.setProperty("arlmSys_fetchVanScanObjects", true)
    end
end

function onObjectScanned(message, isLocal, objectName)
    world.sendEntityMessage(player.id(), "addScanned", objectName)
end