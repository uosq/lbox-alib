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
---@field public events {changed: function?, mouseclick: function?}
---@field public _last_clicked_tick number? Dont change this please
---@field public clickable boolean
---@field public managed boolean If alib should manage mouse clicks for you
---@field public background color
---@field public selected color
---@field public outline_color color
---@field public outline_thickness integer
---@field public text_color color
---@field public font Font
local button = {
   text = "", text_color = color:new(255,255,255,255),
   parent = nil,
   x = 0, y = 0, width = 0, height = 0, outline_thickness = 0, font = 0,
   background = color:new(0,0,0,0), selected = color:new(0,0,0,0), outline_color = color:new(0,0,0,0),
   events = {changed = nil, mouseclick = nil},
   _last_clicked_tick = nil, -- pls dont change :3
   clickable = true,
   managed = true,
}
button.__index = button

---@param button button
function button:render(button)
   if button.background.opacity == 0 or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end

   if utils.is_mouse_inside(button) then
      color:change_color(button.selected)
   else
      color:change_color(button.background)
   end
   draw.FilledRect(button.x, button.y, button.x + button.width, button.y + button.height)

   draw.SetFont(button.font)
   color:change_color(button.text_color)
   local tx, ty = draw.GetTextSize(button.text)
   draw.Text( button.x + button.width/2 - math.floor(tx/2), button.y + button.height/2 - math.floor(ty/2), button.text )

   for i = 1, button.outline_thickness do
       draw.OutlinedRect(button.x - 1 * i, button.y - 1 * i, button.x + button.width + 1 * i, button.y + button.height + 1 * i)
   end
end

---@param parent window
---@param x number
---@param y number
---@param width number
---@param height number
---@return button
function button:create(parent, x, y, width, height)
   local mt = setmetatable({}, button)
   mt.parent = parent
   mt.x = parent.x + x
   mt.y = parent.y + y
   mt.width = width
   mt.height = height

   parent.children[#parent.children+1] = mt
   return mt
end

function button:__newindex(key, new_value)
   if key == "_last_clicked_tick" then error("Don't change _last_clicked_tick pls") end
   local old_value = rawget(self, key)
   rawset(self, key, new_value)
   if self.events.changed then
      self.events.changed(key, old_value, new_value)
   end
end
return button