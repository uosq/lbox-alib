---//
---@class theme
---@field font_name string
---@field font_size number
---@field text color?
---@field background color?
---@field selected color?
---@field outline_color color?
---@field outline_thickness number
local theme = {
   font = 0,
   font_name = "",
   font_size = 0,
   background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, text = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0,
}
theme.__index = theme

function theme:new(font_name, font_size, background, selected, outline_color, text, outline_thickness)
   local mt = setmetatable({}, theme)
   mt.font_name = font_name
   mt.font_size = font_size
   mt.background = background
   mt.selected = selected
   mt.outline_color = outline_color
   mt.outline_thickness = outline_thickness
   mt.text = text
   return mt
end

return theme