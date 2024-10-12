local color = require "ui.utils.color"
local theme = require "ui.utils.theme"
local utils = require "ui.utils.utils"
---//
---@class checkbox
local checkbox = {
   x = 0, y = 0, width = 0, height = 0, size = 0,
   parent = nil,
   checked = false,
   theme = {font_name = "", font_size = 0, background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0},
   events = {changed = nil, mousedown = nil, mouseup = nil, mousehover = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   clickable = true,
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

---@param checkbox checkbox
local function checkbox_mouse_inputs(checkbox)
   -- handle mouse up, down, hover and click separately
   local coup, codown, cohover, coclick
   coup = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if checkbox.theme.background.opacity > 0 and utils.is_mouse_inside(checkbox) and state and tick ~= checkbox._last_clicked_tick and checkbox.events.mouseup and checkbox.clickable then
            checkbox.events.mouseup()
         end
         checkbox._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coup)

   codown = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonDown(E_ButtonCode.MOUSE_LEFT)
         if checkbox.theme.background.opacity > 0 and utils.is_mouse_inside(checkbox) and state and tick ~= checkbox._last_clicked_tick and checkbox.events.mousedown and checkbox.clickable then
            checkbox.events.mousedown()
         end
         checkbox._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(codown)

   coup = coroutine.create(function()
      callbacks.Register("Draw", function()
         if checkbox.theme.background.opacity > 0 and utils.is_mouse_inside(checkbox) and checkbox.events.mousehover and checkbox.clickable then
            checkbox.events.mousehover()
         end
      end)
   end)
   coroutine.resume(cohover)
   
   coclick = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if checkbox.theme.background.opacity > 0 and utils.is_mouse_inside(checkbox) and state and tick ~= checkbox._last_clicked_tick and checkbox.events.mouseclick and checkbox.clickable then
            checkbox.events.mouseclick()
         end
         checkbox._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coclick)
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

   local render, mouse_inputs
   render = coroutine.create(render_checkbox)
   mouse_inputs = coroutine.create(checkbox_mouse_inputs)
   coroutine.resume(render, self)
   coroutine.resume(mouse_inputs, self)

   callbacks.Register("Unload", function ()
      coroutine.close(render)
      coroutine.close(mouse_inputs)
   end)
end
return checkbox