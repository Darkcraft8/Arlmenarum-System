function init()
    local shouldRestartQuest = (not player.hasQuest("objectScanLogger")) or player.hasCompletedQuest("objectScanLogger")
    if shouldRestartQuest then
        player.startQuest("objectScanLogger")
    end
    
    message.setHandler("addScanned", function(...) addScanned(...) end)
    message.setHandler("removeScanned", function(...) removeScanned(...) end)
    message.setHandler("hasScanned", function(...) hasScanned(...) end)
end

function addScanned(message, isLocal, objectName)
    local result = player.getProperty("scannedObjects") or {} -- can't access scannedObjects in vanilla so we use a quest to make a scanlist that get stored in the player save
    for _, _objectName in pairs(result) do 
        if objectName == _objectName then
            return
        end
    end
    table.insert(result, objectName)
    player.setProperty("scannedObjects", _temp)
end

function removeScanned(message, isLocal, objectName)
    local result = player.getProperty("scannedObjects") or {}
    local _temp = {}
    for _, _objectName in pairs(result) do 
        if not objectName == _objectName then
            table.insert(result, _objectName)
        end
    end
    player.setProperty("scannedObjects", _temp)
end

function hasScanned(message, isLocal, objectName)
    local result = player.getProperty("scannedObjects") or {}
    return result[objectName]
end

