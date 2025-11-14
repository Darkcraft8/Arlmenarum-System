require "/scripts/util.lua"
--[[
    Utility function(s) for dealing with recipes
]]

arlm_recipeFunc = {} -- putting arlm in case there already a table or variable named recipeFunc
local itemConfigs = {} -- so that we don't have to do root.itemConfig each time the function is called inside the current script/thread
arlm_recipeFunc_previousItemCount = {}

function arlm_recipeFunc.itemConfig(itemName)
    if itemConfigs[itemName] then return itemConfigs[itemName] end
    itemConfigs[itemName] = root.itemConfig(itemName)
    return itemConfigs[itemName]
end

function arlm_recipeFunc.configParameter(itemDescriptor, parameter)
    local _config = arlm_recipeFunc.itemConfig(arlm_recipeFunc.itemName(itemDescriptor))
    if type(itemDescriptor) == "string" then itemDescriptor = {name = itemDescriptor, count = 1, parameters = {}} end

    return (itemDescriptor.parameters or {})[parameter] or _config.config[parameter]
end

function arlm_recipeFunc.itemName(itemDescriptor) -- yes starbound recipes ins't really that consistant when it come to recipe item input list
    if type(itemDescriptor) == "string" then return itemDescriptor end
    return itemDescriptor.item or itemDescriptor.name or itemDescriptor.itemName or itemDescriptor[1]
end

function arlm_recipeFunc.inputDescriptor(input, currencyInput) -- generalise the input list and move any currency item to the currencyInput
    local _input, _currencyInput = {}, copy(currencyInput) or {}
    
    for index, itemDescriptor in pairs(input or {}) do
        local currency = arlm_recipeFunc.configParameter(itemDescriptor, "currency")
        local itemName = arlm_recipeFunc.itemName(itemDescriptor)
        if currency then
            local addedCurrency = false
            for cIndex, cAmount in pairs(_currencyInput) do
                if cIndex == itemName then
                    if type(itemDescriptor) == "table" then
                        _currencyInput[cIndex] = _currencyInput[cIndex] + (itemDescriptor.count or itemDescriptor[2] or 0)
                    else
                        _currencyInput[cIndex] = _currencyInput[cIndex] + 1
                    end
                    addedCurrency = true
                    break
                end
            end
            if not addedCurrency then
                if type(itemDescriptor) == "table" then
                    _currencyInput[currency] = (itemDescriptor.count or itemDescriptor[2] or 0)
                else
                    _currencyInput[currency] = 1
                end
            end
        else
            if type(itemDescriptor) == "table" then
                table.insert(_input, {
                    name = itemName,
                    count = (itemDescriptor.count or itemDescriptor[2] or 0),
                    parameters = (itemDescriptor.parameters or itemDescriptor[3])
                })
            else
                table.insert(_input, {
                    name = itemName,
                    count = 1
                })
            end
        end
    end

    for cIndex, cAmount in pairs(_currencyInput) do
        if type(cIndex) ~= "string" then
            local amount = _currencyInput[cAmount[1]] or 0
            amount = amount + cAmount[2]
            _currencyInput[cAmount[1]] = amount
        end
    end

    return _input, _currencyInput
end

function arlm_recipeFunc.canCraft(recipe, keepPreviousItemCount)
    if not keepPreviousItemCount then arlm_recipeFunc.resetPreviousItemCount() end
    if player.isAdmin() then
        return 9999
    else
        local maxAmount = 9999
        local _input, _currencyInput = arlm_recipeFunc.inputDescriptor(recipe.input, recipe.currencyInput)
        --sb.logInfo("recipe.input %s, %s", _input, _currencyInput)
        for _, input in pairs(_input) do
            local ref = copy(input)
            ref.count = 1
            if (input.count or 0) > 0 then
                local id = sb.printJson({arlm_recipeFunc.itemName(ref), ref.parameters})
                if not arlm_recipeFunc_previousItemCount[id] then
                    arlm_recipeFunc_previousItemCount[id] = player.hasCountOfItem(ref, recipe.matchInputParameters)
                end
                local itemAmount = arlm_recipeFunc_previousItemCount[id]
                maxAmount = math.min(maxAmount, math.floor(itemAmount / input.count))
            end
        end
        for cName, cAmount in pairs(_currencyInput) do 
            local currencyAmount = player.currency(cName)
            maxAmount = math.min(maxAmount, math.floor(currencyAmount / cAmount))
        end
        return maxAmount
    end
end

function arlm_recipeFunc.resetPreviousItemCount() arlm_recipeFunc_previousItemCount = {} end
function arlm_recipeFunc.printPreviousItemCount(pretty)
    if pretty then
        return sb.printJson(arlm_recipeFunc_previousItemCount, 1) 
    else
        return sb.printJson(arlm_recipeFunc_previousItemCount)
    end
end
function arlm_recipeFunc.canCraftRecipes(recipeList, resetPreviousItemCount) -- not tested
    if resetPreviousItemCount then arlm_recipeFunc.resetPreviousItemCount() end
    local resultList = {}
    for index, recipe in pairs(recipeList) do
        resultList[index] = arlm_recipeFunc.canCraft(recipe, not resetPreviousItemCount)
    end
    return resultList
end