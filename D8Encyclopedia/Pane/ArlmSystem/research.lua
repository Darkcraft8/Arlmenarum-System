require("/d8Arlmenarum/System/vanilla/util/recipe.lua")
local _update = update
local resetTimer = 0
function update(dt)
    if resetTimer > 0 then resetTimer = resetTimer - dt else 
        resetTimer = 2
        arlm_recipeFunc.resetPreviousItemCount()
        researchsList = player.getProperty("researchList")
    end
    if _update then _update(dt) end
end

function hasResearchs(researchs, level)
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

function canCrafts(recipes)
    if not recipe then return false end
    if type(recipes) == "string" then 
        return arlm_recipeFunc.canCraft(recipes)
    elseif type(recipes) == "table" then
        local canCraft = arlm_recipeFunc.canCraftRecipes(recipes)
        for _, b in pairs(canCraft) do 
            if not b then return false end
        end
        return true
    end
end

function hasScanned(objectName) -- where askin on the same side / asking on the client so it should be fast enough to work
    local rpcDrawable = world.sendEntityMessage(player.id(), "hasScanned", objectName)
    local rpcResult = false
    if rpcDrawable then
        if rpcDrawable:finished() then
            rpcResult = rpcDrawable:result()
        end
    end
    return rpcResult
end