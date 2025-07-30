require "/scripts/util.lua"
-- itemDescriptor

    --[[ Todo
        make the wearables (head, chest, legs, back ect) use their player/npc entity sprite like in vanilla instead of the item icon
    ]]
    local returnItemName = function(item)
        return item.item or item.name or item.itemName or item[1] or item
    end

    local itemDescriptorType = {}
    function populateCraftDescription(layoutWidget, itemDescriptor)
        widget.removeAllChildren(layoutWidget, widgetName)
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
        if not string.find(tooltipKind, "/") then
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
                        if not string.find(image, "/") then
                            image = itemCfg.directory.. image
                        end
                        widget.setImage(widgetPath, image)
                    else
                        local position = widget.getPosition(widgetPath)
                        local newImage = copy(widgetCfg)
                        for imageIndex, imageCfg in pairs(image or {}) do
                            if not string.find(imageCfg.image, "/") then
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
            local leveledStatusEffects = configParameters("leveledStatusEffects")
            for _, statusEffect in pairs(leveledStatusEffects or {}) do 
                local id = widget.addListItem(widgetPath)
                local path = widgetPath.."."..id 
                local level = configParameters("level")

                local image = "/interface/stats/" .. statusEffect.stat .. ".png"
                local input = statusEffect.baseMultiplier or statusEffect.amount
                local statusLabel = root.evalFunction(statusEffect.levelFunction, level)
                if statusEffect.baseMultiplier then statusLabel = tostring( (statusEffect.baseMultiplier) * 100) .. "%" end
                if statusEffect.effectiveMultiplier then statusLabel = tostring(((statusEffect.effectiveMultiplier)) * statusLabel) .. "%" end
                if statusEffect.amount then statusLabel = statusLabel * (statusEffect.amount or 1) end
                widget.setText(path..".statusLabel", tostring(statusLabel)) 
                widget.setImage(path..".statusImage", image)
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

        function itemDescriptorType.titleIcon(path, descriptor)
            widget.setItemSlotItem(path, descriptor)
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

        local rarityLabel = {
            common = "Common",
            uncommon = "Uncommon",
            rare = "Rare",
            legendary = "Legendary",
            essential = "Essential"
        }
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
                    if category == "headwear" or category == "headarmour" then
                        return "head"
                    end
                    if category == "chestwear" or category == "chestarmour" then
                        return "chest"
                    end
                    if category == "legwear" or category == "legarmour" then
                        return "legs"
                    end
                    if category == "backwear" or category == "backarmour" then
                        return "back"
                    end
                    return false
                end
            end
            local image = configParameters("inventoryIcon") or configParameters("codexIcon")

            if configParameters("objectName") then -- object image
                local placementImage = configParameters("placementImage")
                if placementImage then
                    if not string.find(placementImage, "/") then
                        placementImage = descriptor.directory.. placementImage
                    end
                    widget.setImage(path, placementImage .. "?flipx")
                else
                    local color = configParameters("color")
                    local orientations = configParameters("orientations")
                    local image = orientations[1].dualImage or orientations[1].image or orientations[1].imageLayers
                    if type(image) == "string" then
                        if not string.find(image, "/") then
                            image = descriptor.directory.. image
                        end
                        widget.setImage(path, string.gsub(string.gsub(string.gsub(image, "<color>", color or "default"), "<frame>", "default"), "<key>", "default") .. "?flipx")
                    else
                        local position = widget.getPosition(path)
                        local newImage = copy(widgetCfg)
                        for imageIndex, imageCfg in pairs(image or {}) do
                            if not string.find(imageCfg.image, "/") then
                                imageCfg.image = descriptor.directory.. imageCfg.image
                            end
                            --sb.logInfo("imageCfg.image %s", imageCfg.image)
                            imageCfg.image = string.gsub(string.gsub(string.gsub(imageCfg.image, "<color>", color or "default"), "<frame>", "default"), "<key>", "default") .. "?flipx"
                        end
                        newImage.drawables = image
                        widget.removeChild(layoutWidget, widgetName)
                        widget.addChild(layoutWidget, newImage, widgetName)
                    end
                end
            end
            if isAWearable() then
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

                image = root.npcPortrait("fullneutral", player.species(), "nakedvillager", 1, player.id(), parameters)
                local position = widget.getPosition(path)
                local newImage = copy(widgetCfg)
                newImage.drawables = image
                widget.removeChild(layoutWidget, widgetName)
                widget.addChild(layoutWidget, newImage, widgetName)
                return
            end
        
            if type(image) == "string" then
                if not string.find(image, "/") then
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
                    if not string.find(imageCfg.image, "/") then
                        imageCfg.image = descriptor.directory.. imageCfg.image
                    end
                end
                newImage.drawables = image
                widget.removeChild(layoutWidget, widgetName)
                if not image then
                    sb.logInfo("descriptor %s", descriptor)
                end
                widget.addChild(layoutWidget, newImage, widgetName)
            end
            return
        end

        function itemDescriptorType.largeImage(path, descriptor)
            local configParameters = function(paramName)
                return (descriptor.parameters or {})[paramName] or descriptor.config[paramName]
            end
            local image = configParameters("largeImage")
            if not string.find(image, "/") then
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