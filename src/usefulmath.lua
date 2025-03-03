local misc = require("src.misc")
local settings = require("src.settings")

local Math = {}

--- clamps the number between min and max
---@param number number
---@param min number
---@param max number
---@nodiscard
---@return number
function Math.clamp(number, min, max)
   number = (number < min and min or number)
   number = (number > max and max or number)
   return number
end

--- checks if mouse is inside or not the object
---@param parent table<string, any>?
---@param object table<string, any>
---@param mode MSMode?
---@nodiscard
---@return boolean
---@overload fun(parent: table<string, any>?, list: table<string, any>)
---@overload fun(parent: table<string, any>?, object: table<string, any>)
---@overload fun(parent: table<string, any>?, object: table<string, any>, mode: MSMode, ...)
---@overload fun(parent: table<string, any>?, object: table<string, any>, index: integer)
function Math.isMouseInside(parent, object, mode, ...)
   if mode then
      local chosen_mode = misc.MouseInsideMode[mode]
      return chosen_mode(parent, object, ...)
   else --- default to NORMAL if mode is nil or they didnt pass it at all, doesnt need the variable arg "..."
      return misc.MouseInsideMode.NORMAL(parent, object)
   end
end

--- calculates the new slider value so you dont have to do math
---@param slider table<string, any>
---@param min integer
---@param max integer
---@nodiscard
---@return integer
function Math.GetNewSliderValue(window, slider, min, max)
   local mx = input.GetMousePos()[1]
   local initial_mouse_pos = mx - (slider.x + window.x)
   local new_value = Math.clamp(min + ((initial_mouse_pos / slider.width) * (max - min)), min, max)
   return new_value
end

--- calculates the new vertical slider value so you dont have to do math :)
---@param window table<string, any>
---@param slider table<string, any>
---@param min integer
---@param max integer
---@param flipped boolean
---@nodiscard
---@return integer
function Math.GetNewVerticalSliderValue(window, slider, min, max, flipped)
   local my = input.GetMousePos()[2]
   local initial_mouse_pos = my - (slider.y + window.y)
   local normalized_pos = initial_mouse_pos / slider.height

   if flipped then
      normalized_pos = 1 - normalized_pos
   end

   local new_value = Math.clamp(min + (normalized_pos * (max - min)), min, max)
   return new_value
end

---@param slider table<string, any>
---@param steps number? Can be anything like 0.5, 1, 0.7, 2, 10, etc
---@nodiscard
---@return integer
function Math.GetSliderPercentage(slider, steps)
   return (slider.value - slider.min) / (slider.max - slider.min)
end

---@return integer
---@nodiscard
function Math.GetListHeight(number_of_items)
   return number_of_items * math.floor(settings.list.item_height)
end

---@param hue integer [0, 360]
---@param saturation number [0, 1]
---@param value number [0, 1]
function Math.Hsv_to_RGB(hue, saturation, value)
   local chroma = value * saturation
   local hue_segment = hue / 60
   local x = chroma * (1 - math.abs((hue_segment % 2) - 1))

   local r1, g1, b1 = 0, 0, 0
   local segment_map = {
      [0] = function() return chroma, x, 0 end,
      [1] = function() return x, chroma, 0 end,
      [2] = function() return 0, chroma, x end,
      [3] = function() return 0, x, chroma end,
      [4] = function() return x, 0, chroma end,
      [5] = function() return chroma, 0, x end
   }

   local segment = math.floor(hue_segment)
   if segment_map[segment] then
      r1, g1, b1 = segment_map[segment]()
   end

   local m = value - chroma
   return math.floor((r1 + m) * 255), math.floor((g1 + m) * 255), math.floor((b1 + m) * 255)
end

function Math.Hex_to_RGBA(number)
   if number < 0 then
      number = number + 0x100000000
   end

   local a = math.floor(number / 0x1000000) % 0x100
   local r = math.floor(number / 0x10000) % 0x100
   local g = math.floor(number / 0x100) % 0x100
   local b = number % 0x100

   return math.floor(r), math.floor(g), math.floor(b), math.floor(a)
end

--- // DEPRECATED STUFF

--- use isMouseInside! This is deprecated and can stop working or be removed at any time
---@deprecated
---@param parent table<string, any>
---@param round_button table<string, any>
---@nodiscard
---@return boolean
function Math.isMouseInsideRoundButton(parent, round_button)
   return Math.isMouseInside(parent, round_button, "ROUND_BUTTON")
end

--- use isMouseInside! This is deprecated and can stop working or be removed at any time
---@deprecated
---@param parent table<string, any>?
---@param list table
---@param index integer
---@nodiscard
---@return boolean
function Math.isMouseInsideItem(parent, list, index)
   return Math.isMouseInside(parent, list, "LIST", index)
end

--- use isMouseInside! This is deprecated and can stop working or be removed at any time
---@deprecated
---@param parent table?
---@param list table
---@nodiscard
---@return boolean
function Math.isMouseInsideList(parent, list)
   return Math.isMouseInside(parent, list, "LIST")
end

--- \\ END OF DEPRECATED STUFF

function Math.Time2Ticks(seconds)
   return seconds * 66.67
end

return Math
