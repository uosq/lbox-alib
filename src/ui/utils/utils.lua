---//
local utils = {}

---@param object any
---@return boolean
utils.is_mouse_inside = function(object)
	local mousePos = input.GetMousePos()
   local mx, my = mousePos[1], mousePos[2]
   if (mx < object.x or my < object.y) or (mx > object.x + object.width or my > object.y + object.height) then
      return false
   end
   return true
end

utils.clamp = function(number, min, max)
   number = (number < min and min or number)
   number = (number > max and max or number)
   return number
end

return utils