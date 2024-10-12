local color = require "ui.utils.color"
local theme = require "ui.utils.theme"
local utils = require "ui.utils.utils"
---//
local combobox_button = {
   parent = nil,
   height = 0, width = 0, index = 0, item = 0, x = 0, y = 0,
   events = {mouseclick = nil}
}

local function render_combobox_button(combobox_button)
   if combobox_button.theme.background.opacity == 0 or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end
   if utils.is_mouse_inside(combobox_button) then
   color:change_color(combobox_button.parent.theme.selected_color)
  else
   color:change_color(combobox_button.parent.theme.background_color)
  end
  draw.FilledRect(combobox_button.x, combobox_button.y, combobox_button.x + combobox_button.parent.width, combobox_button.y + combobox_button.height)

  color:change_color(combobox_button.parent.theme.outline_color)
  for i = 1, combobox_button.parent.theme.outline_thickness do
   draw.OutlinedRect(combobox_button.x - 1 * i, combobox_button.y - 1 * i, combobox_button.x + combobox_button.width + 1 * i, combobox_button.y + combobox_button.height + 1 * i)
  end

  draw.SetFont(combobox_button.parent.theme.font)
  color:change_color(combobox_button.parent.theme.text_color)
  local tx, ty = draw.GetTextSize(combobox_button.item)
  draw.Text(combobox_button.x + combobox_button.parent.width / 2 - math.floor(tx / 2), combobox_button.y + combobox_button.height / 2 - math.floor(ty / 2), combobox_button.item)
end

local function combobox_button_mouse_inputs(combobox_button)
   local state = input.IsButtonPressed(MOUSE_LEFT)
   for k,v in pairs(combobox_button.parent.combbuttons) do
      if utils.is_mouse_inside(v) and state and v.click and v.parent.displaying_items then
         v.click(v)
      end
   end
end

function combobox_button:create(parent, index, item)
   local mt = setmetatable({}, self)
   self.__index = self
   mt.x = parent.x
   mt.index = index
   mt.y = parent.y + (self.index * parent.height)
   mt.item = item
   mt.width = parent.width
   mt.height = parent.height

   self.events.mouseclick = function ()
      parent.selected_item = self.index
   end

   local render, mouse_inputs
   render = coroutine.create(render_combobox_button)
   mouse_inputs = coroutine.create(combobox_button_mouse_inputs)
   coroutine.resume(render, self)
   coroutine.resume(mouse_inputs, self)

   callbacks.Register("Unload", function ()
      coroutine.close(render)
      coroutine.close(mouse_inputs)
   end)

   return mt
end

---@class combobox
---@field parent window?
---@field items table?
---@field x number
---@field y number
---@field width number
---@field height number
---@field theme theme
---@field events {mouseclick: function?}
---@field _last_clicked_tick number?
---@field combbuttons table?
---@field selected_item number
---@field displaying_items boolean
---@field clickable boolean
local combobox = {
   parent = nil,
   items = nil,
   x = 0, y = 0, width = 0, height = 0,
   theme = {font_name = "", font_size = 0, background = {red = 0, green = 0, blue = 0, opacity = 0}, selected = {red = 0, green = 0, blue = 0, opacity = 0}, outline_color = {red = 0, green = 0, blue = 0, opacity = 0}, outline_thickness = 0},
   events = {mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   combbuttons = nil,
   selected_item = 1,
   displaying_items = false,
   clickable = true,
}

---@param combobox combobox
local function render_combobox(combobox)
   if utils.is_mouse_inside(combobox) then
      color:change_color(combobox.theme.selected)
  else
      color:change_color(combobox.theme.background)
  end

  draw.FilledRect(combobox.x, combobox.y, combobox.x + combobox.width, combobox.y + combobox.height)

  draw.SetFont(combobox.theme.font)
  color:change_color(combobox.theme.text)
  local tx, ty = draw.GetTextSize(combobox.items[combobox.selected_item])
  draw.Text(combobox.x + combobox.width / 2 - math.floor(tx / 2), combobox.y + combobox.height / 2 - math.floor(ty / 2), tostring(combobox.items[combobox.selected_item]))

  for i = 1, combobox.theme.outline_thickness do
      draw.OutlinedRect(combobox.x - 1 * i, combobox.y - 1 * i, combobox.x + combobox.width + 1 * i, combobox.y + combobox.height + 1 * i)
  end

  if combobox.displaying_items then
      for k, comboboxbutton in ipairs(combobox.combbuttons) do
          if comboboxbutton then
              render_combobox_button(comboboxbutton)
          end
      end
  end
end

---@param combobox combobox
local function combobox_mouse_inputs(combobox)
   -- handle mouse up, down, hover and click separately
   local coclick = coroutine.create(function()
      callbacks.Register("Draw", function()
         local state, tick = input.IsButtonReleased(E_ButtonCode.MOUSE_LEFT)
         if combobox.theme.background.opacity > 0 and utils.is_mouse_inside(combobox) and state and tick ~= combobox._last_clicked_tick and combobox.events.mouseclick and combobox.clickable then
            combobox.events.mouseclick()
         end
         combobox._last_clicked_tick = tick
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
---@param items table<string>
function combobox:create(parent, x, y, width, height, theme, items)
   local mt = setmetatable({}, self)
   self.__index = self
   mt.x = parent.x + x
   mt.y = parent.y + y
   mt.width = width
   mt.height = height
   mt.theme = theme
   mt.items = items

   self.combbuttons = {}
   for k,v in ipairs (self.items) do
      self.combbuttons[k] = combobox_button:create(self, k, v)
   end

   self.events.mouseclick = function ()
      self.displaying_items = not self.displaying_items
      for k,v in pairs (self.parent.children) do
         if v ~= self then
            v.clickable = not self.displaying_items
         end
      end
   end

   parent.children[#parent.children+1] = mt

   local render, mouse_inputs
   render = coroutine.create(render_combobox)
   mouse_inputs = coroutine.create(combobox_mouse_inputs)
   coroutine.resume(render, self)
   coroutine.resume(mouse_inputs, self)

   callbacks.Register("Unload", function ()
      coroutine.close(render)
      coroutine.close(mouse_inputs)
   end)

   return mt
end

return combobox