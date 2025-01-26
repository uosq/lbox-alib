local settings = require("src.settings")
local misc = {}

function misc.change_color(color)
   draw.Color(color[1], color[2], color[3], color[4])
end

local function rectangle(width, height, x, y, filled)
   if filled then
      draw.FilledRect(x, y, width + x, y + height)
   else
      draw.OutlinedRect(x, y, width + x, y + height)
   end
end

function misc.draw_shadow(width, height, x, y, offset)
   rectangle(width, height, x + offset, y + offset, true)
end

function misc.draw_outline(width, height, x, y, thickness)
   for i = 1, thickness do
      rectangle(width + (1 * i), height + (1 * i), x - (1 * i), y - (1 * i), false)
   end
end

function misc.filledcircle(x, y, radius)
   for i = radius, 1, -1 do
      draw.OutlinedCircle(x, y, i, 63)
   end
end

---@enum (key) MSMode
misc.MouseInsideMode = {
   NORMAL = function(parent, object)
      local mousePos = input.GetMousePos()
      local mx, my = mousePos[1], mousePos[2]
      return mx >= object.x + (parent and parent.x or 0) and mx <= object.x + object.width + (parent and parent.x or 0) and
          my >= object.y + (parent and parent.y or 0) and my <= object.y + object.height + (parent and parent.y or 0)
   end,

   WINDOW_TITLE = function(parent, object)
      local mousePos = input.GetMousePos()
      local mx, my = mousePos[1], mousePos[2]
      return mx >= object.x + (parent and parent.x or 0) and
          mx <= object.x + object.width + (parent and parent.x or 0) and
          my >= object.y + (parent and parent.y or 0) - settings.window.title.height and
          my <= object.y + object.height + (parent and parent.y or 0)
   end,

   ROUND_BUTTON = function(parent, round_button)
      local mousePos = input.GetMousePos()
      local mx, my = mousePos[1], mousePos[2]
      return mx >= round_button.x + parent.x - math.floor(round_button.height / 2) and
          mx <= round_button.x + round_button.width + parent.x + math.floor(round_button.height / 2) and
          my >= round_button.y + parent.y and my <= round_button.y + round_button.height + parent.y
   end,

   ITEM = function(parent, list, index)
      parent = parent or { x = 0, y = 0 }
      local height = settings.list.item_height
      local y = parent.y + list.y + ((index - 1) * settings.list.item_height)

      local mousePos = input.GetMousePos()
      local mx, my = mousePos[1], mousePos[2]
      return mx >= list.x + parent.x and mx <= list.x + list.width + parent.x and my >= y and my <= y + height
   end,

   LIST = function(parent, list)
      local mousePos = input.GetMousePos()
      local mx, my = mousePos[1], mousePos[2]
      local height = #list.items * settings.list.item_height
      return mx >= list.x + (parent and parent.x or 0) and mx <= list.x + list.width + (parent and parent.x or 0) and
          my >= list.y + (parent and parent.y or 0) and my <= list.y + height + (parent and parent.y or 0)
   end,
}

return misc
