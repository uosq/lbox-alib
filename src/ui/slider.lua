local utils = require "ui.utils.utils"
local color = require "ui.utils.color"
---//
---@class slider
---@field public parent window?
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public theme theme
---@field public events {changed: function?, mousedown: function?, mouseup: function?, mouseclick: function?}
---@field public _last_clicked_tick number? Dont change this please
---@field public max number
---@field public min number
---@field public percent number
---@field public current number
---@field public clickable boolean
local slider = {
   parent = nil,
   x = 0, y = 0, width = 0, height = 0, min = 0, max = 0, current = 0, percent = 0,
   theme = {font_name = "", font_size = 0, background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0},
   events = {changed = nil, mousedown = nil, mouseup = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   clickable = true,
}

---@param slider slider
local function render_slider(slider)
   if slider.theme.background.opacity == 0 or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end

   color:change_color(slider.theme.outline_color)
   for i = 1, slider.theme.outline_thickness do
       draw.OutlinedRect(slider.x - 1 * i, slider.y - 1 * i, slider.x + slider.width + 1 * i, slider.y + slider.height + 1 * i)
   end

   color:change_color(slider.theme.background)
   draw.FilledRect(slider.x, slider.y, slider.x + slider.width, slider.y + slider.height)

   color:change_color(slider.theme.selected)
   draw.FilledRect(slider.x, slider.y, slider.x + slider.width * slider.percent, slider.y + slider.height)
end

---@param slider slider
local function slider_mouse_inputs(slider)
   -- handle mouse up, down, hover and click separately
   local coup, codown, coclick
   coup = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if slider.theme.background.opacity > 0 and utils.is_mouse_inside(slider) and state and tick ~= slider._last_clicked_tick and slider.events.mouseup and slider.clickable then
            slider.events.mouseup()
         end
         slider._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coup)

   codown = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonDown(E_ButtonCode.MOUSE_LEFT)
         if slider.theme.background.opacity > 0 and utils.is_mouse_inside(slider) and state and tick ~= slider._last_clicked_tick and slider.events.mousedown and slider.clickable then
            slider.events.mousedown()
         end
         slider._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(codown)
   
   coclick = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if slider.theme.background.opacity > 0 and utils.is_mouse_inside(slider) and state and tick ~= slider._last_clicked_tick and slider.events.mouseclick and slider.clickable then
            slider.events.mouseclick()
         end
         slider._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coclick)
end

function slider:create(parent, x, y, width, height, theme, min, max, current)
   local mt = setmetatable({}, self)
   self.__index = self
   mt.x = parent.x + x
   mt.y = parent.y + y
   mt.width = width
   mt.height = height
   mt.theme = theme
   mt.max = max
   mt.min = min
   mt.current = current

   self.events.mousedown = function()
      local mx = input.GetMousePos()[1]
      local initial_mouse_pos = mx - self.x
      local new_value = utils.clamp(self.min + ((initial_mouse_pos/self.width) * (self.max - self.min)), self.min, self.max)
      self.value = new_value
      self.percent = (new_value - self.min) / self.max - self.min
   end

   parent.children[#parent.children+1] = mt

   local render, mouse_inputs
   render = coroutine.create(render_slider)
   mouse_inputs = coroutine.create(slider_mouse_inputs)
   coroutine.resume(render, self)
   coroutine.resume(mouse_inputs, self)

   callbacks.Register("Unload", function ()
      coroutine.close(render)
      coroutine.close(mouse_inputs)
   end)

   return mt
end

return slider