
local listPath = "/Arlmenarum/System/oSB/mission/list.config"
local list = assets.json(listPath)
local count = 0
local registered = {}
for kind, missionList in pairs(list) do
    sb.logInfo("[Arlmenarum System] Mission Postload: Registering %s mission", kind)
    registered[kind] = missionList or {}

    local fileList = assets.byExtension(kind .. "mission")
    local kindCount = 0
    for i = 1, #fileList do -- fetch vanilla mission's
        local jsonFile = fileList[i]
        local missionName = assets.json(jsonFile)["missionName"]
        local alreadyExist = false
        for i = 1, #list do
            if list[i] == missionName then alreadyExist = true end
        end
        if not alreadyExist then
            table.insert(registered[kind], missionName)
            count = count + 1
            kindCount = kindCount + 1
        end
    end

    if kindCount > 0 then    
        sb.logInfo("[Arlmenarum System] Mission Postload: Registered %s mission", kindCount)
    end
end

if count > 0 then
    local path = listPath .. ".patch"
    assets.add(path, registered)
    assets.patch(listPath, path)

    sb.logInfo("[Arlmenarum System] Mission Postload: Registered %s mission in total", count)
end