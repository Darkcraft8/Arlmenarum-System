require "/scripts/util.lua"
-- itemDescriptor

    --[[ Todo
        Done : make the wearables (head, chest, legs, back ect) use their player/npc entity sprite like in vanilla instead of the item icon
        Done : fix the object placement image not being used ,_,
        To Do : Make so that tile use their configurated preview image/frame
        To Do : Allow for usage of mannequin like vanilla
        To Do : Check if it could be used in vanilla with or without some change
    ]]
    local returnItemName = function(item)
        return item.item or item.name or item.itemName or item[1] or item
    end
    
    local rarityLabel = {
        common = "Common",
        uncommon = "Uncommon",
        rare = "Rare",
        legendary = "Legendary",
        essential = "Essential"
    }

    local itemDescriptorType = {}
    function populateCraftDescription(layoutWidget, itemDescriptor)
        widget.removeAllChildren(layoutWidget)
        if type(itemDescriptor) ~= "table" then itemDescriptor = root.createItem(itemDescriptor) end
        local itemCfg = itemDescriptor
        if not itemDescriptor.config then
            itemCfg = root.itemConfig(itemDescriptor)
            itemCfg.name = copy(itemDescriptor.name)
            itemCfg = sb.jsonMerge(itemCfg, itemDescriptor)
        end
        local configParameters = function(paramName)
            return (itemCfg.parameters or {})[paramName] or itemCfg.config[paramName]
        end

        local tooltipKind = configParameters("descriptorKind") or configParameters("tooltipKind")
        if not tooltipKind then tooltipKind = "base" end
        local path = ""
        if not (string.find(tooltipKind, "/") == 1) then
            path = string.format("/interface/itemdescriptions/%s.itemdescription", tooltipKind)
        else
            path = tooltipKind
        end
        local cfg = root.assetJson(path)
        local tooltipFields = configParameters("tooltipFields") or {}

        local widgetList = {}
        for widgetName, widgetCfg in pairs(cfg or {}) do
            if not widgetCfg.zlevel then
                if widgetCfg.type == "label" then
                    widgetCfg.zlevel = 2
                elseif widgetCfg.type == "image" then
                    widgetCfg.zlevel = 1
                else
                    widgetCfg.zlevel = 3
                end
                --sb.logInfo("name : %s, type : %s, zlevel : %s", widgetName, widgetCfg.type, widgetCfg.zlevel)
            end
            widgetCfg._name = widgetName
            table.insert(widgetList, widgetCfg)
        end
        table.sort(widgetList, function(a, b)
            return a.zlevel < b.zlevel
        end)
        for _, widgetCfg in ipairs(widgetList or {}) do
            local widgetName = widgetCfg._name

            widget.addChild(layoutWidget, widgetCfg, widgetName)
            local widgetPath = layoutWidget.."."..widgetName
            if itemDescriptorType[widgetName] then
                itemDescriptorType[widgetName](widgetPath, itemCfg, widgetCfg, layoutWidget, widgetName)
            end
            if string.find(widgetName, "Label") then
                if tooltipFields[widgetName] then
                    widget.setText(widgetPath, tooltipFields[widgetName])
                end
            elseif string.find(widgetName, "Image") then
                if tooltipFields[widgetName] then
                    local image = tooltipFields[widgetName]
                    if type(image) == "string" then
                        if not (string.find(image, "/") == 1) then
                            image = itemCfg.directory.. image
                        end
                        widget.setImage(widgetPath, image)
                    else
                        local position = widget.getPosition(widgetPath)
                        local newImage = copy(widgetCfg)
                        for imageIndex, imageCfg in pairs(image or {}) do
                            if not (string.find(imageCfg.image, "/") == 1) then
                                imageCfg.image = descriptor.directory.. imageCfg.image
                            end
                        end
                        newImage.drawables = image
                        widget.removeChild(layoutWidget, widgetName)
                        widget.addChild(layoutWidget, newImage, widgetName)
                    end
                end
            end
        end
    end

    -- widget
        function itemDescriptorType.statusList(widgetPath, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            local describe = function(statusEffect)
                local id = widget.addListItem(widgetPath)
                local path = widgetPath.."."..id 
                local level = configParameters("level")

                local image = "/interface/stats/" .. statusEffect.stat .. ".png"
                local input = statusEffect.baseMultiplier or statusEffect.amount
                local statusLabel = root.evalFunction(statusEffect.levelFunction, level)
                if statusEffect.baseMultiplier then statusLabel = tostring( ((statusEffect.baseMultiplier - 1) * 100) * level ) .. "%" end
                if statusEffect.effectiveMultiplier then statusLabel = tostring(((statusEffect.effectiveMultiplier)) * statusLabel) .. "%" end
                if statusEffect.amount then statusLabel = statusLabel * (statusEffect.amount or 1) end
                widget.setText(path..".statusLabel", tostring(statusLabel)) 
                widget.setImage(path..".statusImage", image)
            end
            for _, statusEffect in pairs(configParameters("leveledStatusEffects", {})) do 
                describe(statusEffect)
            end
            for _, statusEffect in pairs(configParameters("statusEffects", {})) do 
                describe(statusEffect)
            end
        end

        function itemDescriptorType.title(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            widget.setText(path, configParameters("shortdescription") or "")
        end

        function itemDescriptorType.subTitle(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            local category = root.assetJson("/items/categories.config")["labels"]
            local tooltipFields = configParameters("tooltipFields") or {}
            widget.setText(path, tooltipFields.subTitle or category[configParameters("category")] or configParameters("category") or "")
        end

        function itemDescriptorType.titleIcon(path, descriptor, widgetCfg, layoutWidget, widgetName)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            --local devAtWork = true
            if widgetCfg.iconMode and devAtWork then
                local widgetCfg = copy(widgetCfg)
                widgetCfg.type = "image"
                widgetCfg.position = vec2.add(widgetCfg.position, {11, 11})
                widgetCfg.centered = true
                widgetCfg.zlevel = -1
                widgetCfg.drawables = {
                    
                }
                local invIcon = configParameters("inventoryIcon", configParameters("codexIcon"))
                local rarity = rarityLabel[string.lower(configParameters("rarity"))]
                if widgetCfg.backingImage then
                    table.insert(widgetCfg.drawables, {image = widgetCfg.backingImage})
                end
                if layoutWidget and widgetName then
					widget.addChild(layoutWidget, widgetCfg, widgetName .. ".backing")
				elseif not layoutWidget then
					sb.logInfo("Error %s layoutWidget", layoutWidget)
				elseif not widgetName then
					sb.logInfo("Error %s widgetName", widgetName)
                end
                widgetCfg.drawables = {
                    
                }
                widgetCfg.zlevel = 0
                if widgetCfg.showRarity then
                    table.insert(widgetCfg.drawables, {image = string.gsub("/interface/inventory/itemborder<rarity>.png", "<rarity>", rarity)})
                end
                if type(invIcon) == "string" then
                    if not (string.find(invIcon, "/") == 1) then
                        invIcon = descriptor.directory.. invIcon
                    end
                    table.insert(widgetCfg.drawables, {image = invIcon})
                else
                    for _, drawable in pairs(invIcon or {}) do 
                        if not (string.find(drawable.image, "/") == 1) then
                            drawable.image = descriptor.directory.. drawable.image
                        end
                        table.insert(widgetCfg.drawables, drawable)
                    end
                end

                widget.removeChild(layoutWidget, widgetName)
				if layoutWidget and widgetName then
					widget.addChild(layoutWidget, widgetCfg, widgetName)
				elseif not layoutWidget then
					sb.logInfo("Error %s layoutWidget", layoutWidget)
				elseif not widgetName then
					sb.logInfo("Error %s widgetName", widgetName)
				end
            else
                widget.setItemSlotItem(path, descriptor)
            end
            
        end

        function itemDescriptorType.priceLabel(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            widget.setText(path, configParameters("price") or 0)
        end

        function itemDescriptorType.descriptionLabel(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            widget.setText(path, configParameters("description") or "")
        end

        function itemDescriptorType.rarityLabel(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            
            widget.setText(path, rarityLabel[string.lower(configParameters("rarity"))] or "")
        end

        function itemDescriptorType.objectImage(path, descriptor, widgetCfg, layoutWidget, widgetName)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            local isAWearable = function()
                if root.itemFile then
                    local itemFile = root.itemFile(returnItemName(descriptor))
                    
                    if string.find(itemFile, ".head") then
                        return "head"
                    end
                    if string.find(itemFile, ".chest") then
                        return "chest"
                    end
                    if string.find(itemFile, ".legs") then
                        return "legs"
                    end
                    if string.find(itemFile, ".back") then
                        return "back"
                    end
                    return false
                else
                    local category = configParameters("category")
                    local maleFrames = configParameters("maleFrames")
                    if type(maleFrames) == "table" then maleFrames = maleFrames.body end
                    if category == "headwear" or category == "headarmour" or string.find(maleFrames, "head") then
                        return "head"
                    end
                    if category == "chestwear" or category == "chestarmour" or string.find(maleFrames, "chest") then
                        return "chest"
                    end
                    if category == "legwear" or category == "legarmour" or string.find(maleFrames, "pants") then
                        return "legs"
                    end
                    if category == "backwear" or category == "backarmour" or string.find(maleFrames, "back") then
                        return "back"
                    end
                    return false
                end
            end
            local image = configParameters("inventoryIcon", configParameters("codexIcon"))
            local tooltipKind = configParameters("tooltipKind")
            
            if configParameters("objectName") then -- object image
                local placementImage = configParameters("placementImage")
                if placementImage then
                    if not (string.find(placementImage, "/") == 1) then
                        placementImage = descriptor.directory.. placementImage
                    end
                    widget.setImage(path, placementImage .. "?flipx")
                else
                    local color = configParameters("color")
                    local orientations = configParameters("orientations")
                    local image = orientations[1].dualImage or orientations[1].image or orientations[1].imageLayers
                    if type(image) == "string" then
                        if not (string.find(image, "/") == 1) then
                            image = descriptor.directory.. image
                        end
                        if (not orientations[1].image) or orientations[1].flipImages then
                            image = image .. "?flipx"
                        end
                        widget.setImage(path, string.gsub(string.gsub(string.gsub(image, "<color>", color or "default"), "<frame>", "default"), "<key>", "default"))
                    else
                        local position = widget.getPosition(path)
                        local newImage = copy(widgetCfg)
                        for imageIndex, imageCfg in pairs(image or {}) do
                            if not (string.find(imageCfg.image, "/") == 1) then
                                imageCfg.image = descriptor.directory.. imageCfg.image
                            end
                            --sb.logInfo("imageCfg.image %s", imageCfg.image)
                            imageCfg.image = string.gsub(string.gsub(string.gsub(imageCfg.image, "<color>", color or "default"), "<frame>", "default"), "<key>", "default") .. "?flipx"
                        end
                        newImage.drawables = image
                        widget.removeChild(layoutWidget, widgetName)
						if layoutWidget and newImage and widgetName then
							widget.addChild(layoutWidget, newImage, widgetName)
						elseif not layoutWidget then
							sb.logInfo("Error %s layoutWidget", layoutWidget)
						elseif not newImage then
							sb.logInfo("Error %s newImage", newImage)
						elseif not widgetName then
							sb.logInfo("Error %s widgetName", widgetName)
						end
                    end
                end
            elseif isAWearable() then
                local category = configParameters("category")
                local parameters = {
                    identity = {},
                    items = {
                        override = {
                        { 0, {
                            {
                            }
                            } 
                        }
                        }
                    }
                }
                if player.humanoidIdentity then
                    parameters.identity = player.humanoidIdentity()
                end
                local wearableType = isAWearable()
                parameters["items"]["override"][1][2][1][wearableType] = {descriptor}
                if not (root.assetJson("/interface.config:tooltip.previewArmorWith") == "dummy" or root.assetJson("/interface.config:tooltip.previewArmorWith") == nil) then
                    parameters.identity = {
                        bodyDirectives = "?multiply=fff0",
                        facialMaskDirectives = "?multiply=fff0",
                        facialHairDirectives = "?multiply=fff0",
                        emoteDirectives = "?multiply=fff0",
                        hairDirectives = "?multiply=fff0"
                    }
                end
                image = root.npcPortrait("fullneutral", player.species(), "nakedvillager", 1, player.id(), parameters)
                local position = widget.getPosition(path)
                local newImage = copy(widgetCfg)
                newImage.drawables = image
                if not (root.assetJson("/interface.config:tooltip.previewArmorWith") == "dummy" or root.assetJson("/interface.config:tooltip.previewArmorWith") == nil or config.getParameter("descriptorUseDummy")) then
                    for a, b in pairs(newImage.drawables) do
                        if string.find(b.image, "/humanoid") == 1 then
                            local mannequin = copy(b)
                            if string.find(b.image, "backarm") then
                                mannequin.image = "/humanoid/any/dummybackarm.png:idle.1"
                            elseif string.find(b.image, "frontarm") then
                                mannequin.image = "/humanoid/any/dummyfrontarm.png:idle.1"
                            elseif string.find(b.image, "head") then
                                mannequin.image = "/humanoid/any/dummyhead.png:normal"
                            elseif string.find(b.image, "body") then
                                mannequin.image = "/humanoid/any/dummybody.png:idle.1"
                            else
                                mannequin.image = "/assetmissing.png:?crop;0;0;1;1"
                            end
                            newImage.drawables[a] = mannequin
                        end
                    end
                end
                widget.removeChild(layoutWidget, widgetName)
                widget.addChild(layoutWidget, newImage, widgetName)
            else
                --sb.logInfo("tooltipKind %s", tooltipKind)
                if type(image) == "string" then
                    if not (string.find(image, "/") == 1) then
                        image = descriptor.directory.. image
                    end
                    widget.setImage(path, image)
                else
                    local position = widget.getPosition(path)
                    local newImage = {}
                    for a, b in pairs(widgetCfg) do 
                        if a ~= "file" then
                            newImage[a] = b
                        end
                    end
                    for imageIndex, imageCfg in pairs(image or {}) do
                        if not (string.find(imageCfg.image, "/") == 1) then
                            imageCfg.image = descriptor.directory.. imageCfg.image
                        end
                    end
                    newImage.drawables = image
                    widget.removeChild(layoutWidget, widgetName)
                    if not image then
                        sb.logInfo("no image found for descriptor!: %s", descriptor)
                    end
                    widget.addChild(layoutWidget, newImage, widgetName)
                end
            end
            return
        end

        function itemDescriptorType.largeImage(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            local image = configParameters("largeImage")
            if not (string.find(image, "/") == 1) then
                image = descriptor.directory.. image
            end
            widget.setImage(path, image)
        end

        function itemDescriptorType.handednessLabel(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            local twoHanded = configParameters("twoHanded")
            local tooltipText = "1-Handed"
            if twoHanded then
                tooltipText = "2-Handed"
            end
            widget.setText(path, tooltipText)
        end

        function itemDescriptorType.slotCountLabel(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            local slotCount = configParameters("slotCount")
            local isContainer = configParameters("objectType") == "container"
            if slotCount and isContainer then
                widget.setText(path, string.format("Holds %s Items", slotCount))
            end
        end
    --

--