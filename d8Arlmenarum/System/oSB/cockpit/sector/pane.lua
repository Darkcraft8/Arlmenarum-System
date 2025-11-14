sector = {}

sector.init = function()
    world.sendEntityMessage(player.id(), "sectorCall", "init")
end

sector.uninit = function()
    world.sendEntityMessage(player.id(), "sectorCall", "uninit")
end