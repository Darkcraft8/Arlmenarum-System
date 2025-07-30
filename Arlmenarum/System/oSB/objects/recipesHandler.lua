local recipeHandler = {}
function buildRecipesList(interactData) -- we only need to give recipes that are from the vanilla database and/or unlocked through the research system or other
    local recipes = {}
    recipeHandler:paneRecipes(recipes, interactData)
    recipeHandler:researchRecipes(recipes, interactData)
    recipeHandler:vanillaRecipes(recipes, interactData)
    return recipes
end

function recipeHandler:paneRecipes(recipes, interactData)
    local configJson = interactData.config
    if type(configJson) == "string" then
        configJson = root.assetJson(interactData.config)
    end
    recipes = interactData.recipes or configJson.recipes or {}
end

function recipeHandler:researchRecipes(recipes) -- currently this doesn't serve a purpose because the research/mastery system isn't built yet
    local testRecipes = {
        input = {
            { item = "darkwoodmaterial", count = 1 }
        },
        output = {
            item = "darkwoodmaterial",
            count = 1
        },
        duration = 1,
        groups = { "d8Weaponry_gunsmithing_lv1", "d8Weaponry_gunsmithing" }
    }
    table.insert(recipes, testRecipes)
end

function recipeHandler:vanillaRecipes(recipes, interactData)
    if not root.allRecipes then return nil, sb.logInfo("[recipeHandler] : server doesn't support root.allRecipes, install openStarbound or a fork for full recipeHandler support") end
    local getAllRecipes = root.allRecipes
    for _, recipe in ipairs(getAllRecipes("recipe")) do 
        local add = false
        for _, filter in ipairs(interactData.filter or {}) do
            if string.find(sb.printJson(recipe.groups), filter) then add = true break end
        end
        if add then table.insert(recipes, recipe) end
    end
end

function recipeHandler:allRecipes(filter, recipeList, recipes)
    local recipeList = recipeList or root.allRecipes()
    if recipes and recipeList then return end
    for _, recipe in ipairs(recipeList) do 
        if type(recipe) == "string" then recipe = root.assetJson(recipe) end
        local add = false
        for _, filter in ipairs(interactData.filter or {}) do
            if string.find(sb.printJson(recipe.groups), filter) then add = true break end
        end
        if add then table.insert(recipes, recipe) end
    end
end
--[[
    exemple of usage of result
        local newRecipesList = buildRecipesList(interactData)
        if type(newRecipesList) == "table" then
            interactData.recipes = newRecipesList
        end
]]
--[[
    Todo :
        Find why the filters get messed up or manually check recipes for the filters : Done
        how vanilla check for filter : if there one filter that is the same add the recipe...
]]