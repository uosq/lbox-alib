local utils = require "ui.utils"
---//
---@class button
---@field public theme theme
---@field public name string
---@field public text string
---@field public x number
---@field public y number
---@field public height number
---@field public parent table?
---@field private click function?
---@field private last_clicked_tick number?
---@field private type string
local button = {
   name = "", text = "",
   x = 0, y = 0, width = 0, height = 0,
   theme = {},
   parent = {},
   enabled = true, selectable = true,
   click = nil,
   last_clicked_tick = nil,
   type = "button",
}
button.__index = button

function button:new(name, text, parent, x, y, width, height, theme, click)
   local mt = setmetatable({}, button)
   mt.name = name
   mt.text = text
	mt.x = parent.x + x
   mt.y = parent.y + y
   mt.width = width
   mt.height = height
	mt.theme = theme
	mt.parent = parent
	mt.enabled = true
   mt.selectable = true
	mt.click = click
	mt.last_clicked_tick = nil
	mt.type = "button"
	parent.children[#parent.children+1] = mt
   return mt
end

function button:render()
   if not self.enabled or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end

	if utils.is_mouse_inside(self) then
		theme.change_color(self.theme.selected_color)
	else
		theme.change_color(self.theme.background_color)
	end
	draw.FilledRect(self.x, self.y, self.x + self.width, self.y + self.height)

	draw.SetFont(self.theme.font)
	theme.change_color(self.theme.text_color)
	local tx, ty = draw.GetTextSize(self.text)
	draw.Text( self.x + self.width/2 - math.floor(tx/2), self.y + self.height/2 - math.floor(ty/2), self.text )

	for i = 1, self.theme.outline_thickness do
		draw.OutlinedRect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
	end
end

return button