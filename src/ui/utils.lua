---//
utils = {}

utils.is_mouse_inside = function(object)
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
utils.clamp = function(number, min, max)
	number = (number < min and min or number)
	number = (number > max and max or number)
	return number
end

utils.unload = function()
	local mouse_success = pcall(callbacks.Unregister, "Draw","mouse_manager")
	local combbuttons_success = pcall(callbacks.Unregister, "Draw", "combbuttons_manager")
	assert(mouse_success, "error: couldn't unregister mouse_manager")
	assert(combbuttons_success, "error: couldn't unregister combbuttons_manager")
	package.loaded.alib = nil
	if package.loaded.console then
		package.loaded.console = nil
	else
		callbacks.Unregister("SendStringCmd", "console_lib")
	end
end

---@param red number
---@param green number
---@param blue number
---@param opacity number
---@return RGB
utils.rgb = function(red, green, blue, opacity)
	return {
		r = utils.clamp(red, 0, 255),
		g = utils.clamp(green, 0, 255),
		b = utils.clamp(blue, 0, 255),
		opacity = utils.clamp(opacity, 0, 255)
	}
end

return utils