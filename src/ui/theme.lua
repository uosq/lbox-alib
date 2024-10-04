---@class theme
local theme = {
   background_color = {},
   selected_color = {},
   text_color = {},
   outline_color = {},
   outline_thickness = 0,
   font = 0,
   font_size = 0,
}
theme.__index = theme

---@param font string
function theme:create_font(font, font_size)
	local success, result = pcall(draw.CreateFont, font, font_size, 1000)
	assert(success, string.format("error: couldn't create font %s\n%s", font, tostring(result)))
	return result
end

---@param font string
---@param background_color RGB
---@param text_color RGB
---@param outline_color RGB
---@param outline_thickness number
---@param font_size number
---@return theme
function theme:new(font, font_size, background_color, selected_color, text_color, outline_color, outline_thickness)
   local mt = setmetatable({}, theme)
	mt.background_color = background_color
	mt.selected_color = selected_color
	mt.text_color = text_color
	mt.outline_color = outline_color
	mt.outline_thickness = outline_thickness
	mt.font = self:create_font(font, font_size)
	mt.font_size = font_size
	return mt
end

---@param color RGB
function theme:change_color(color)
	draw.Color(color.r, color.g, color.b, color.opacity)
end

return theme