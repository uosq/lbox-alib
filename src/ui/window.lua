local color = require "ui.utils.color"
local utils = require "ui.utils.utils"
---//
---@class window
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public theme theme
---@field public events {changed: function?, mousedown: function?, mouseup: function?, mouseclick: function?}
---@field public _last_clicked_tick number? Dont change this please
---@field public children table
---@field public clickable boolean
local window = {
   x = 0, y = 0, width = 0, height = 0, -- x,y and size
   theme = {font_name = "", font_size = 0, background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0}, -- the theme
   events = {changed = nil, mousedown = nil, mouseup = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   children = {},
   clickable = true,
}
window.__index = window

---@param window window
local function render_window(window)
   if window.theme.background.opacity == 0 or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end
   color:change_color(window.theme.background)
   draw.FilledRect(window.x, window.y, window.x + window.width, window.y + window.height)
   color:change_color(window.theme.outline_color)
   for i = 1, window.theme.outline_thickness do
      draw.OutlinedRect(window.x - 1 * i, window.y - 1 * i, window.x + window.width + 1 * i, window.y + window.height + 1 * i)
   end
end

---@param window window
local function window_mouse_inputs(window)
   -- handle mouse up, down, hover and click separately
   callbacks.Register("Draw", function()
      local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
      if window.theme.background.opacity > 0 and utils.is_mouse_inside(window) and state and tick ~= window._last_clicked_tick and window.events.mouseup and window.clickable then
         window.events.mouseup()
      end
      rawset(window, "_last_clicked_tick", tick)
   end)

   callbacks.Register("Draw", function()
      local state, tick = input.IsButtonDown(E_ButtonCode.MOUSE_LEFT)
      if window.theme.background.opacity > 0 and utils.is_mouse_inside(window) and state and tick ~= window._last_clicked_tick and window.events.mousedown and window.clickable then
         window.events.mousedown()
      end
      rawset(window, "_last_clicked_tick", tick)
   end)

   callbacks.Register("Draw", function()
      local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
      if window.theme.background.opacity > 0 and utils.is_mouse_inside(window) and state and tick ~= window._last_clicked_tick and window.events.mouseclick and window.clickable then
         window.events.mouseclick()
      end
      rawset(window, "_last_clicked_tick", tick)
   end)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param theme theme
---@return {x: number, y: number, width: number, height: number, theme: theme, events: table, children: table}
function window:create(x, y, width, height, theme)
   local new_window = setmetatable({}, window)
   new_window.x = x
   new_window.y = y
   new_window.width = width
   new_window.height = height
   new_window.theme = theme

   callbacks.Register("Draw", function ()
      window_mouse_inputs(new_window)
      render_window(new_window)
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