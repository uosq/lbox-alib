local theme = require "ui.utils.theme"
local color = require "ui.utils.color"
local utils = require "ui.utils.utils"
---//
---@class window
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public theme theme
---@field public events {changed: function?, mousedown: function?, mouseup: function?, mousehover: function?, mouseclick: function?}
---@field public _last_clicked_tick number? Dont change this please
---@field public children table
---@field public clickable boolean
local window = {
   x = 0, y = 0, width = 0, height = 0, -- x,y and size
   theme = {font_name = "", font_size = 0, background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0}, -- the theme
   events = {changed = nil, mousedown = nil, mouseup = nil, mousehover = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   children = {},
   clickable = true,
}

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
   local coup, codown, cohover, coclick
   coup = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if window.theme.background.opacity > 0 and utils.is_mouse_inside(window) and state and tick ~= window._last_clicked_tick and window.events.mouseup and window.clickable then
            window.events.mouseup()
         end
         window._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coup)

   codown = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonDown(E_ButtonCode.MOUSE_LEFT)
         if window.theme.background.opacity > 0 and utils.is_mouse_inside(window) and state and tick ~= window._last_clicked_tick and window.events.mousedown and window.clickable then
            window.events.mousedown()
         end
         window._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(codown)

   coup = coroutine.create(function()
      callbacks.Register("Draw", function()
         if window.theme.background.opacity > 0 and utils.is_mouse_inside(window) and window.events.mousehover and window.clickable then
            window.events.mousehover()
         end
      end)
   end)
   coroutine.resume(cohover)

   coclick = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if window.theme.background.opacity > 0 and utils.is_mouse_inside(window) and state and tick ~= window._last_clicked_tick and window.events.mouseclick and window.clickable then
            window.events.mouseclick()
         end
         window._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coclick)
end

function window:create(x, y, width, height, theme)
   local mt = setmetatable({}, self)
   self.__index = self
   mt.x = x
   mt.y = y
   mt.width = width
   mt.height = height
   mt.theme = theme

   local render, mouse_inputs
   render = coroutine.create(render_window)
   mouse_inputs = coroutine.create(window_mouse_inputs)
   coroutine.resume(render, self)
   coroutine.resume(mouse_inputs, self)

   callbacks.Register("Unload", function ()
      coroutine.close(render)
      coroutine.close(mouse_inputs)
   end)

   return mt
end
return window