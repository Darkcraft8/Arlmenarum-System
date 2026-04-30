
local listPath = "/d8Arlmenarum/System/oSB/mission/list.config"
local list = assets.json(listPath)
local count = 0
local registered = {}
for missionType, missionList in pairs(list) do
    sb.logInfo("[Arlmenarum System] Mission Postload: Registering %s mission", missionType)
    registered[missionType] = missionList or {}

    local fileList = assets.byExtension(missionType .. "mission")
    local missionTypeCount = 0
    for i = 1, #fileList do -- fetch vanilla mission's
        local jsonFile = fileList[i]
        local missionName = assets.json(jsonFile)["missionName"]
        local alreadyExist = false
        for i = 1, #list do
            if list[i] == missionName then alreadyExist = true end
        end
        if not alreadyExist then
            table.insert(registered[missionType], missionName)
            count = count + 1
            missionTypeCount = missionTypeCount + 1
        end
    end

    if missionTypeCount > 0 then    
        sb.logInfo("[Arlmenarum System] Mission Postload: Registered %s mission", missionTypeCount)
    end
end

if count > 0 then
    local path = listPath .. ".patch"
    assets.add(path, registered)
    assets.patch(listPath, path)

    sb.logInfo("[Arlmenarum System] Mission Postload: Registered %s mission in total", count)
end