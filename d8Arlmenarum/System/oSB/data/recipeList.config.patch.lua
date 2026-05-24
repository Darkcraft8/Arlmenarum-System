function patch(data)
  --sb.logInfo("Fetching Recipes After The Postloaded Script")
  fetchRecipe(data)
  return data
end
--[[ 
    Recipe List Fetcher, fetch and insert recipes path in groups that they are present inside of... 
    Also, getting recipes this way seem to cause less stutter/shorter freeze than root.assetsByExtension("recipe") :D
--]]
function fetchRecipe(data)
    local fileList = assets.byExtension("recipe")
    local count = 0
    data.list = {}
    data.byGroup = {}
    for i = 1, #fileList do
        local recipe = fileList[i]
        local alreadyExist = false
        for _, group in pairs(assets.json(recipe).groups) do 
            if not data.byGroup[group] then data.byGroup[group] = {} end
            table.insert(data.byGroup[group], recipe)
        end
        table.insert(data.list, recipe)
        count = count + 1
        --sb.logInfo("Added Recipe n.%s : %s", count, recipe)
    end
end