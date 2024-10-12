---//
---@class color
---@field red number
---@field green number
---@field blue number
---@field opacity number
local color = {
   red = 0,
   green = 0,
   blue = 0,
   opacity = 0,
}
color.__index = color

function color:new(r, g, b, opacity)
   local mt = setmetatable({}, color)
   mt.red = r
   mt.green = g
   mt.blue = b
   mt.opacity = opacity
   return mt
end

---@param color {r: number, g: number, b: number, opacity: number}
function color:change_color(color)
   draw.Color(color.r, color.g, color.b, color.opacity)
end

return color