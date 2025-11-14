require "/scripts/vec2.lua"

arlm_inputUtil = {
    mousePos = function(self)
        return vec2.mul(input.mousePosition(), 1 / interface.scale()) -- input.mousePosition return the mousePosition ON Screen without the interface scaling
    end
}
