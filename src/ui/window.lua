local color = require "ui.utils.color"
local utils = require "ui.utils.utils"
---//
---@class window
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public events {changed: function?, mouseclick: function?}
---@field public _last_clicked_tick number? Dont change this please
---@field public children table
---@field public clickable boolean
---@field public managed boolean If alib should manage mouse clicks for you
---@field public background color?
---@field public selected color?
---@field public outline_color color
---@field public outline_thickness integer
---@field public font Font
local window = {
   x = 0, y = 0, width = 0, height = 0, outline_thickness = 0, font = 0,
   background = color:new(0,0,0,0), selected = color:new(0,0,0,0), outline_color = color:new(0,0,0,0),
   events = {changed = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   children = {},
   clickable = true,
   managed = true,
}
window.__index = window

---@param window window
function window:render(window)
   if window.background.opacity == 0 or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end
   color:change_color(window.background)
   draw.FilledRect(window.x, window.y, window.x + window.width, window.y + window.height)
   color:change_color(window.outline_color)
   for i = 1, window.outline_thickness do
      draw.OutlinedRect(window.x - 1 * i, window.y - 1 * i, window.x + window.width + 1 * i, window.y + window.height + 1 * i)
   end
end

---@param x number
---@param y number
---@param width number
---@param height number
---@return window
function window:create(x, y, width, height)
   local new_window = setmetatable({}, window)
   new_window.x = x
   new_window.y = y
   new_window.width = width
   new_window.height = height

   local id = os.clock()
   callbacks.Register("Draw", "mouse_manager" .. id, function()
		for k,child in pairs(new_window.children) do
         if child.managed then
            local state, tick = input.IsButtonPressed(MOUSE_LEFT)
            if child.theme.background.opacity > 0 and utils.is_mouse_inside(child) and state and tick ~= child._last_clicked_tick and child.events.mouseclick and child.clickable then
               child.events.mouseclick()
            end
            rawset(child, "_last_clicked_tick", tick)
         end
		end
	end)

   callbacks.Register("Unload", function ()
      callbacks.Unregister("Draw", "mouse_manager" .. id)
   end)

   return new_window
end

-- track table accesses and changes
function window:__newindex(key, new_value)
   if key == "_last_clicked_tick" then error("Don't change _last_clicked_tick pls") end
   local old_value = rawget(self, key)
   rawset(self, key, new_value)
   if self.events.changed then
      self.events.changed(key, old_value, new_value)
   end
end
return window