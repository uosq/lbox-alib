local theme = require "ui.theme"
local window = require "ui.window"
local Math = require "ui.math"
---//
local function is_mouse_inside(object)
   local mousePos = input.GetMousePos()
   local mx, my = mousePos[1], mousePos[2]
   if (mx < object.x or my < object.y) or (mx > object.x + object.width or my > object.y + object.height) then
      return false
   end
   return true
end

---@param number number
---@param min number
---@param max number
local function clamp(number, min, max)
	number = (number < min and min or number)
	number = (number > max and max or number)
	return number
end