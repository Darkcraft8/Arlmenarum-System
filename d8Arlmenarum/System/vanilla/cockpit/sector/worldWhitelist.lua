--[[
    dev note : reimplementing the sector system by hidding specific star type should be the easiest path and allow
     for universe/planet save types, would just need to check how the objects are handled to see if it possible to specifie
     where celestial object spawn (station, ship and such) or if it already does that by default.
]]
local _init = init
local _celestial
function init()
    _celestial = copy(celestial)
    sector.init(config.getParameter("allowedSectors", {universe = true}))
    celestial.scanSystems = function(region)
        local allowedSystemsList = sector.allowedSystems
        local systems = _celestial.scanSystems(region)
        local newList = {}
        for _, system in pairs(systems or {}) do 
            local starType = celestial.planetParameters(system).typeName or "default"
            if allowedSystemsList[starType] then
                table.insert(newList, system)
            end
        end
        return newList, true
    end
    celestial.scanConstellationLines = function(region)
        local scanConstellationLines = _celestial.scanConstellationLines(region)
        local _systems, isCustom = celestial.scanSystems(region)
        local constellationLines = {}
        --if isCustom then sb.logInfo("custom systems list received") end
        for _, lines in pairs(scanConstellationLines or {}) do 
            local pointAFound = false
            local pointBFound = false
            for _, system in pairs(_systems) do 
                local vec2Loc = {system.location[1], system.location[2]}
                if not pointAFound then pointAFound = compare(lines[1], vec2Loc) end
                if not pointBFound then pointBFound = compare(lines[2], vec2Loc) end
                if pointAFound and pointBFound then
                    table.insert(constellationLines, lines)
                    break
                end
            end
        end
        --sb.logInfo("test scanConstellationLines : %s", scanConstellationLines)
        return constellationLines
    end
    if _init then _init() end
end

sector = {
    allowedSystems = {},
    init = function(whitelistedSystem)
        local list = {}
        local sectorConfig = root.assetJson("/d8Arlmenarum/System/vanilla/cockpit/sector/sector.config") or {}
        local cockpitConfig = root.assetJson("/interface/cockpit/cockpit.config") or {}
        local whitelistedSystem = whitelistedSystem or config.getParameter("allowedSectors", {universe = true})
        local loadVanillaUniverse = function(sectorConfig, cockpitConfig)
            for starType, _ in pairs(cockpitConfig.starTypeNames or {}) do 
                if sectorConfig.universe[starType] == nil then
                    sectorConfig.universe[starType] = true
                end
            end
            return sectorConfig
        end
        sectorConfig = loadVanillaUniverse(sectorConfig, cockpitConfig) -- add star type that are meant for the vanilla sector if there not already configured
        for system, starList in pairs(sectorConfig or {}) do 
            if whitelistedSystem[system] then
                for starType, bool in pairs(starList) do 
                    if bool then
                        list[starType] = true
                    end
                end
            end
        end
        sector.allowedSystems = list
    end
}