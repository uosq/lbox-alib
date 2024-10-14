local color = require "ui.utils.color"
local theme = require "ui.utils.theme"
local utils = require "ui.utils.utils"
---//
---@class checkbox
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public parent window?
---@field public checked boolean
---@field public theme theme
---@field public events {changed: function?, mousedown: function?, mouseup: function?, mouseclick: function?}
---@field _last_clicked_tick number?
---@field public clickable boolean
---@field public managed boolean If alib should manage mouse clicks for you
local checkbox = {
   x = 0, y = 0, width = 0, height = 0, size = 0,
   parent = nil,
   checked = false,
   theme = {font_name = "", font_size = 0, background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0},
   events = {changed = nil, mousedown = nil, mouseup = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   clickable = true,
   managed = true
}

---@param checkbox checkbox
local function render_checkbox(checkbox)
   if checkbox.theme.background.opacity == 0 or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end

   color:change_color(checkbox.theme.background)
   for i = 1, checkbox.theme.outline_thickness do
       draw.OutlinedRect(checkbox.x - 1 * i, checkbox.y - 1 * i, checkbox.x + checkbox.width + 1 * i, checkbox.y + checkbox.height + 1 * i)
   end

   if checkbox.checked then
      color:change_color(checkbox.theme.selected)
   else
      color:change_color(checkbox.theme.text)
   end
   draw.FilledRect(checkbox.x, checkbox.y, checkbox.x + checkbox.width, checkbox.y + checkbox.height)
end

---@param parent window
---@param x number
---@param y number
---@param size number
---@param theme theme
function checkbox:create(parent, x, y, size, theme)
   local mt = setmetatable({}, self)
   self.__index = self
   mt.parent = parent
   mt.x = parent.x + x
   mt.y = parent.y + y
   mt.width = 1 * size
   mt.height = 1 * size
   mt.theme = theme
   
   mt.events.mouseclick = function()
      self.checked = not self.checked
   end

   parent.children[#parent.children+1] = mt

   callbacks.Register("Draw", function ()
      render_checkbox(mt)
   end)
end

function checkbox:__newindex(key, new_value)
   if key == "_last_clicked_tick" then error("Don't change _last_clicked_tick pls") end
   local old_value = rawget(self, key)
   rawset(self, key, new_value)
   if self.events.changed then
      self.events.changed(key, old_value, new_value)
   end
end
return checkbox