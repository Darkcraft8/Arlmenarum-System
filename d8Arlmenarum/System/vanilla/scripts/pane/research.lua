function updateResearchsList()
    researchsList = player.getProperty("researchList") or {}
end

function hasResearchs(researchs, level)
    if not researchsList then updateResearchsList() return end
    if type(researchs) == "string" then
        if level then
            return researchsList[researchs] == level
        else
            return researchsList[researchs]
        end
    elseif type(researchs) == "table" then
        local result = true
        for a, b in pairs(researchs) do 
            if type(a) == "string" then -- table
                result = hasResearchs(b)
            elseif type(a) == "table" then -- array
                result = hasResearchs(a, b)
            end
            if not result then return result end
        end
        return result
    end
end