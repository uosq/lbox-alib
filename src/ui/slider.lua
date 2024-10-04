local utils = require "ui.utils"
---//
---@class slider
---@field name string
---@field x number
---@field y number
---@field width number
---@field height number
---@field theme theme|table<nil>
---@feld parent window
---@field min number
---@field max number
---@field value number
---@field percent number
---@field private last_clicked_tick number?
---@field private type string
---@field private click function?
---@field private __index slider
local slider = {
   name = "",
   x = 0, y = 0, width = 0, height = 0,
   theme = {}, parent = {},
   min = 0, max = 0, value = 0, percent = 0,
   last_clicked_tick = nil,
   selectable = true, enabled = true,
   type = "slider",
   click = nil,
}
slider.__index = slider

---
function slider.new(name, x, y, width, height, theme, parent, min, max, value)
   local slider_mt = setmetatable({}, slider)
   slider_mt.name = name
   slider_mt.x = parent.x + x
   slider_mt.y = parent.y + y
   slider_mt.width = width
   slider_mt.height = height
   slider_mt.theme = theme
   slider_mt.parent = parent
   slider_mt.min = min
   slider_mt.max = max
   slider_mt.value = value
   slider_mt.percent = (value - min) / max - min
   slider_mt.last_clicked_tick = nil
   
   slider_mt.click = function()
      callbacks.Register("Draw", "sliderclicks", function()
			if input.IsButtonDown(MOUSE_LEFT) and utils.is_mouse_inside(slider_mt) and slider_mt.selectable and slider_mt.enabled then
				local mx = input.GetMousePos()[1]
				local initial_mouse_pos = mx - slider_mt.x
				local new_value = utils.clamp(slider_mt.min + ((initial_mouse_pos/slider_mt.width) * (slider_mt.max - slider_mt.min)), slider_mt.min, slider_mt.max)
				slider_mt.value = new_value
				slider_mt.percent = (new_value - slider_mt.min) / slider_mt.max - slider_mt.min
			else
				callbacks.Unregister( "Draw", "sliderclicks" )
			end
		end)
   end
   parent.children[#parent.children+1] = slider_mt
   return slider_mt
end

function slider:render()
   if slider.enabled == false or (gui.GetValue("clean screenshots") == 1
	and engine.IsTakingScreenshot()) then return end

	theme.change_color(slider.theme.outline_color)
	for i = 1, slider.theme.outline_thickness do
		draw.OutlinedRect(slider.x - 1 * i, slider.y - 1 * i, slider.x + slider.width + 1 * i, slider.y + slider.height + 1 * i)
	end

	theme.change_color(slider.theme.background_color)
	draw.FilledRect(slider.x, slider.y, slider.x + slider.width, slider.y + slider.height)

	theme.change_color(slider.theme.selected_color)
	draw.FilledRect(slider.x, slider.y, slider.x + slider.width * slider.percent, slider.y + slider.height)
end

return slider