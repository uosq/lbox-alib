local theme = require "ui.utils.theme"
local color = require "ui.utils.color"
local utils = require "ui.utils.utils"
---//
---@class button
---@field public parent window?
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public text string
---@field public theme theme
---@field public events {changed: function?, mousedown: function?, mouseup: function?, mousehover: function?, mouseclick: function?}
---@field public _last_clicked_tick number? Dont change this please
---@field public clickable boolean
local button = {
   text = "",
   parent = nil,
   x = 0, y = 0, width = 0, height = 0,
   theme = {font_name = "", font_size = 0, background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0},
   events = {changed = nil, mousedown = nil, mouseup = nil, mousehover = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   clickable = true,
}

---@param button button
local function render_button(button)
   if button.theme.background.opacity == 0 or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end

   if utils.is_mouse_inside(button) then
      color:change_color(button.theme.selected)
   else
      color:change_color(button.theme.background)
   end
   draw.FilledRect(button.x, button.y, button.x + button.width, button.y + button.height)

   draw.SetFont(button.theme.font)
   color:change_color(button.theme.text)
   local tx, ty = draw.GetTextSize(button.text)
   draw.Text( button.x + button.width/2 - math.floor(tx/2), button.y + button.height/2 - math.floor(ty/2), button.text )

   for i = 1, button.theme.outline_thickness do
       draw.OutlinedRect(button.x - 1 * i, button.y - 1 * i, button.x + button.width + 1 * i, button.y + button.height + 1 * i)
   end
end

---@param button button
local function button_mouse_inputs(button)
   -- handle mouse up, down, hover and click separately
   local coup, codown, coclick
   coup = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if button.theme.background.opacity > 0 and utils.is_mouse_inside(button) and state and tick ~= button._last_clicked_tick and button.events.mouseup and button.clickable then
            button.events.mouseup()
         end
         button._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coup)

   codown = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonDown(E_ButtonCode.MOUSE_LEFT)
         if button.theme.background.opacity > 0 and utils.is_mouse_inside(button) and state and tick ~= button._last_clicked_tick and button.events.mousedown and button.clickable then
            button.events.mousedown()
         end
         button._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(codown)

   coclick = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if button.theme.background.opacity > 0 and utils.is_mouse_inside(button) and state and tick ~= button._last_clicked_tick and button.events.mouseclick and button.clickable then
            button.events.mouseclick()
         end
         button._last_clicked_tick = tick
      end)
   end)
   coroutine.resume(coclick)
end

---@param parent window
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme theme
---@return button
function button:create(parent, x, y, width, height, theme)
   local mt = setmetatable({}, self)
   self.__index = self
   mt.parent = parent
   mt.x = parent.x + x
   mt.y = parent.y + y
   mt.width = width
   mt.height = height
   mt.theme = theme

   parent.children[#parent.children+1] = mt

   local render, mouse_inputs
   render = coroutine.create(render_button)
   mouse_inputs = coroutine.create(button_mouse_inputs)
   coroutine.resume(render, self)
   coroutine.resume(mouse_inputs, self)

   callbacks.Register("Unload", function ()
      coroutine.close(render)
      coroutine.close(mouse_inputs)
   end)

   return mt
end
return button