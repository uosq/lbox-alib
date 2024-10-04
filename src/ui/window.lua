local theme = require "ui.theme"
---//
---@class window
---@field public theme theme
---@field public name string
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field private type string
---@field private __index window
local window = {
   name = "",
   x = 0, y = 0, width = 0, height = 0,
   theme = {},
   enabled = true,
   children = {},
   type = "window"
}
window.__index = window

function window.new(name, x, y, width, height, theme)
   local mt = setmetatable({}, window)
   mt.name = name
   mt.x = x
   mt.y = y
   mt.width = width
   mt.height = height
   mt.theme = theme
   return mt
end

function window:render()
   if not self.enabled or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end
   theme:change_color(self.theme.background_color)
   draw.FilledRect(self.x, self.y, self.x + self.width, self.y + self.height)
   theme:change_color(self.theme.outline_color)
   for i = 1, self.theme.outline_thickness do
      draw.OutlinedRect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
   end
end

---@param is_mouse_inside function
function window:init(is_mouse_inside)
   callbacks.Unregister("Draw", "mouse_manager")
	callbacks.Register("Draw", "mouse_manager", function()
		for k,v in pairs(self.children) do
			local state, tick = input.IsButtonPressed(MOUSE_LEFT)
			if v.enabled and v.selectable and is_mouse_inside(v) and state and tick ~= v.last_clicked_tick and v.click then
				assert(pcall(v.click, v), string.format("error: couldn't call .click() on %s.init()", tostring(v.parent.name)))
			end
			v.last_clicked_tick = tick
		end
	end)
end

return window