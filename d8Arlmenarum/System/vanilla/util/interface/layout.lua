-- bunch of util for layouts
require "/scripts/vec2.lua"
require "/scripts/util.lua"

local layoutData = {}
layout = {}
layout.reset = function(self, layoutPath)
    layoutData[layoutPath] = {
        widgetPosition = {},
        widgetSize = {},
        areaSize = widget.getSize(layoutPath)
    }
end

--[[
    downSize and move the children based on the difference between the childrens min positions and default size of the layout
    work extremely well for optimizing itemList has it doesn't require the itemSlots to be reloaded/recreated
]]
layout.resize = function(self, layoutPath, hiddenList, widgetList, isList)
    if not layoutData[layoutPath] then layout:reset(layoutPath) end
    local listSize = copy(layoutData[layoutPath]["areaSize"])
    local usedSpace = {100000, 100000, 0, 0}
    local hO = 0
    for i, n in pairs(widgetList) do
        local stringifiedIndex = tostring(i)
        local hI = tostring(i - hO)
        if not layoutData[layoutPath]["widgetPosition"][stringifiedIndex] then
            layoutData[layoutPath]["widgetPosition"][stringifiedIndex] = widget.getPosition(n)
        end
        if not layoutData[layoutPath]["widgetSize"][stringifiedIndex] then
            layoutData[layoutPath]["widgetSize"][stringifiedIndex] = widget.getSize(n)
        end
        
        if hiddenList[n] then
            widget.setVisible(n, false)
            if isList then widget.setPosition(n, layoutData[layoutPath]["widgetPosition"][stringifiedIndex]) end
            hO = hO + 1
        else
            widget.setVisible(n, true)
            if isList then widget.setPosition(n, layoutData[layoutPath]["widgetPosition"][hI]) end
            usedSpace = {
                math.min(usedSpace[1], widget.getPosition(n)[1] - listSize[1]),
                math.min(usedSpace[2], widget.getPosition(n)[2] - listSize[2])
            }
        end
    end
    local sizeModiff = {
        listSize[1] + usedSpace[1],
        listSize[2] + usedSpace[2]
    }
    widget.setSize(layoutPath, vec2.sub(listSize, sizeModiff))
    for i, n in pairs(widgetList) do
        if not hiddenList[n] then
            widget.setPosition(n, vec2.sub(widget.getPosition(n), sizeModiff))
        end
    end
    --sb.setLogMap("1| layout Resizer " .. layoutPath, "size : %s -> %s, diff = %s", sb.printJson(layoutData[layoutPath]["areaSize"]), sb.printJson(vec2.sub(listSize, sizeModiff)), sb.printJson(sizeModiff))
end