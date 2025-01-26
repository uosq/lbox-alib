local version = '0.44'
-- Bundled by luabundle {"version":"1.7.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings                  = require("src.settings")
local misc                      = require("src.misc")
local intro                     = require("src.intro")
local config                    = require("src.config")

local window                    = require("objects.window")
local windowfade                = require("objects.windowfade")
local button                    = require("objects.button")
local buttonfade                = require("objects.buttonfade")
local checkbox                  = require("objects.checkbox")
local slider                    = require("objects.slider")
local sliderfade                = require("objects.sliderfade")
local list                      = require("objects.list")
local verticalslider            = require("objects.verticalslider")
local verticalsliderfade        = require("objects.verticalsliderfade")

local Math                      = require("src.usefulmath")
local shapes                    = require("src.shapes")

local alib                      = {}
alib.settings                   = settings
alib.misc                       = misc
alib.math                       = Math

alib.objects                    = {}
alib.objects.window             = window
alib.objects.windowfade         = windowfade
alib.objects.button             = button
alib.objects.buttonfade         = buttonfade
alib.objects.checkbox           = checkbox
alib.objects.slider             = slider
alib.objects.sliderfade         = sliderfade
alib.objects.list               = list
alib.objects.verticalslider     = verticalslider
alib.objects.verticalsliderfade = verticalsliderfade

alib.shapes                     = shapes

--- create just in case we dont have it
config.create_default_config("default")

intro.init()

return alib

end)
__bundle_register("src.shapes", function(require, _LOADED, __bundle_register, __bundle_modules)
local shapes = {}

---@param x integer
---@param y integer
---@param origin {}
---@param angle any
local function rotate_point(x, y, origin, angle)
   local x = x - (origin[1] or 0)
   local y = y - (origin[2] or 0)

   local cos_angle = math.cos(math.rad(angle))
   local sin_angle = math.sin(math.rad(angle))

   --- i wish we had support for numbers instead of integers :sob:
   local rotated_x = math.floor((x * cos_angle) - (y * sin_angle))
   local rotated_y = math.floor((x * sin_angle) + (y * cos_angle))

   rotated_x = rotated_x + origin[1]
   rotated_y = rotated_y + origin[2]

   return rotated_x, rotated_y
end

---@param x integer
---@param y integer
---@param size integer
---@param origin {[1]: integer, [2]: integer}? The origin of rotation, think of it like the pivot (or fulcrum idk english is hard) of a lever
---@param angle integer degress (20, 30, 45, 60, etc)
function shapes.rotatable_line(x, y, size, origin, angle)
   ---@diagnostic disable-next-line: redefined-local
   local origin = origin or { 0, 0 }
   local x1, y1 = rotate_point(x, y + size, origin, angle)
   local x2, y2 = rotate_point(x + size, y, origin, angle)
   draw.Line(x1, y1, x2, y2)
end

---I love unoptimized stuff! Doesnt work right but im too lazy to delete it
--- @param width integer
---@param height integer
---@param x integer
---@param y integer
---@param angle integer degrees (20, 30, 45, 60, etc)
function shapes.rotatable_rectangle(width, height, x, y, angle)
   local origin = { x + math.floor(width / 2), y + math.floor(height / 2) } --- middle of the rectangle

   for i = 0, height do
      local start_x, start_y = rotate_point(x, y + i, origin, angle)
      local end_x, end_y = rotate_point(x + width, y + i, origin, angle)
      draw.Line(start_x, start_y, end_x, end_y)
   end
end

---@param filled boolean
---@param width integer
---@param height integer
---@param x integer
---@param y integer
function shapes.rectangle(width, height, x, y, filled)
   if filled then
      draw.FilledRect(x, y, width + x, y + height)
   else
      draw.OutlinedRect(x, y, width + x, y + height)
   end
   return true
end

---@param x integer
---@param y integer
---@param radius integer
---@param segments integer
function shapes.circle(x, y, radius, segments)
   draw.OutlinedCircle(x, y, radius, segments)
   return true
end

function shapes.filledcircle(x, y, radius)
   local circle = shapes.circle
   --- i wish there was a filled circle already :(
   --- would probably be faster if it was in C
   for i = 1, radius do
      circle(x, y, i, 63)
   end
   return true
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param alpha_start integer [0, 255]
---@param alpha_end integer [0, 255]
---@param horizontal boolean? default = true
function shapes.rectanglefade(width, height, x, y, alpha_start, alpha_end, horizontal)
   draw.FilledRectFade(x, y, x + width, y + height, alpha_start, alpha_end, horizontal)
   return true
end

--- tbh i dont know why someone would use this but ok?
function shapes.triangle(x, y, size)
   draw.Line(x, y, x + size, y)
   draw.Line(x + math.floor(size / 2), y - size, x + size, y)
   draw.Line(x + math.floor(size / 2), y - size, x, y)
   return true
end

return shapes

end)
__bundle_register("src.usefulmath", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("src.settings", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = {
	font = 0, --- useless doesnt work idk why
	window = {
		background = { 40, 40, 40, 255 },
		outline = { enabled = true, thickness = 1, color = { 255, 255, 255, 255 } },
		shadow = { enabled = true, offset = 3, color = { 0, 0, 0, 200 } },
		title = {
			height = 20,
			background = { 50, 131, 168, 255 },
			text_color = { 255, 255, 255, 255 },
			text_shadow = false,
			fade = { enabled = false, horizontal = true, alpha_start = 255, alpha_end = 20 }
		}
	},
	button = {
		background = { 102, 255, 255, 255 },
		selected = { 150, 255, 150, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		shadow = { text = true, offset = 2, color = { 0, 0, 0, 200 } },
		text_color = { 255, 255, 255, 255 },
		round = false,
	},
	checkbox = {
		background = { 20, 20, 20, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		checked_color = { 150, 255, 150, 255 },
		not_checked_color = { 255, 150, 150, 255 },
		shadow = { offset = 2, color = { 0, 0, 0, 200 } },
	},
	slider = {
		background = { 20, 20, 20, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		bar_color = { 102, 255, 255, 255 },
		bar_outlined = false,
		shadow = { offset = 2, color = { 0, 0, 0, 200 } },
	},
	list = {
		background = { 20, 20, 20, 255 },
		selected = { 102, 255, 255, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		shadow = { offset = 3, color = { 0, 0, 0, 200 } },
		item_height = 20,
		text_color = { 255, 255, 255, 255 },
	},
}

return settings

end)
__bundle_register("src.misc", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("objects.verticalsliderfade", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param min integer
---@param max integer
---@param value integer
---@param flipped boolean
---@param start_alpha integer
---@param end_alpha integer
---@param horizontal boolean
local function verticalsliderfade(width, height, x, y, min, max, value, flipped, start_alpha, end_alpha, horizontal)
   --- shadow
   misc.change_color(settings.slider.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.slider.shadow.offset)

   --- background
   misc.change_color(settings.slider.background)
   draw.FilledRect(x, y, x + width, y + height)

   --- slider bar
   local percentage = (value - min) / (max - min)
   local bar_height = math.floor(height * percentage)
   local bar_y = not flipped and y or y + (height - bar_height)

   misc.change_color(settings.slider.bar_color)
   -- the magic number 1 makes both the width and height not overlap with the outline as we are drawing it after them are drawed
   draw.FilledRectFade(x, bar_y, x + width - 1, y + bar_height, start_alpha, end_alpha, horizontal)

   --- outline
   misc.change_color(settings.slider.outline.color)
   misc.draw_outline(width, height, x, y, settings.slider.outline.thickness)
end

return verticalsliderfade

end)
__bundle_register("objects.verticalslider", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param min integer
---@param max integer
---@param value integer
---@param flipped boolean
local function verticalslider(width, height, x, y, min, max, value, flipped)
   --- shadow
   misc.change_color(settings.slider.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.slider.shadow.offset)

   --- background
   misc.change_color(settings.slider.background)
   draw.FilledRect(x, y, x + width, y + height)

   --- slider bar
   local percentage = (value - min) / (max - min)
   local bar_height = math.floor(height * percentage)
   local bar_y = not flipped and y or y + (height - bar_height)

   misc.change_color(settings.slider.bar_color)
   -- the magic number 1 makes both the width and height not overlap with the outline as we are drawing it after them are drawed
   draw.FilledRect(x, bar_y, x + width - 1, y + bar_height)

   --- outline
   misc.change_color(settings.slider.outline.color)
   misc.draw_outline(width, height, x, y, settings.slider.outline.thickness)
end

return verticalslider

end)
__bundle_register("objects.list", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

local function draw_container(width, height, x, y)
   -- Shadow
   misc.change_color(settings.list.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.list.shadow.offset)

   -- Outline
   misc.change_color(settings.list.outline.color)
   misc.draw_outline(width + 1, height + 1, x, y, settings.list.outline.thickness)

   -- Background
   misc.change_color(settings.list.background)
   draw.FilledRect(x, y, x + width, y + height)
end

local function draw_items(width, item_height, x, y, selected_item_index, items)
   draw.SetFont(settings.font) -- Set font once outside the loop
   local current_y = y

   for i, item in ipairs(items) do
      -- Draw selection highlight if needed
      if i == selected_item_index then
         misc.change_color(settings.list.selected)
         draw.FilledRect(x, current_y, x + width, y + item_height)
      end

      -- Calculate text position
      local textwidth, textheight = draw.GetTextSize(item)
      local text_x = x + math.floor(width / 2) - math.floor(textwidth / 2)
      local text_y = current_y + math.floor(textheight / 2)

      -- Draw text
      misc.change_color(settings.list.text_color)
      draw.Text(text_x, text_y, item)

      -- Move to next item position
      current_y = current_y + item_height
   end
end

---@param width integer
---@param x integer
---@param y integer
---@param selected_item_index integer
---@param items table<integer, string>
local function list(width, x, y, selected_item_index, items)
   local item_height = math.floor(settings.list.item_height)
   local height = math.floor(#items * item_height)

   draw_container(width, height, x, y)
   draw_items(width, item_height, x, y, selected_item_index, items)
end

return list

end)
__bundle_register("objects.sliderfade", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

local function sliderfade(width, height, x, y, min, max, value, start_alpha, end_alpha, horizontal)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)

   --- shadow
   misc.change_color(settings.slider.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.slider.shadow.offset)

   --- background
   misc.change_color(settings.slider.background)
   draw.FilledRect(x, y, x + width, y + height)

   --- outline
   misc.change_color(settings.slider.outline.color)
   misc.draw_outline(width, height, x, y, settings.slider.outline.thickness)

   --- slider bar
   misc.change_color(settings.slider.bar_color)
   local percentage = (value - min) / (max - min)
   draw.FilledRectFade(x, y, x + math.floor(width * percentage) - 1, height - 1, start_alpha, end_alpha, horizontal)
end

return sliderfade

end)
__bundle_register("objects.slider", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

local function slider(width, height, x, y, min, max, value)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)

   --- shadow
   misc.change_color(settings.slider.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.slider.shadow.offset)

   --- background
   misc.change_color(settings.slider.background)
   draw.FilledRect(x, y, x + width, y + height)

   --- outline
   misc.change_color(settings.slider.outline.color)
   misc.draw_outline(width, height, x, y, settings.slider.outline.thickness)

   --- slider bar
   misc.change_color(settings.slider.bar_color)
   local percentage = (value - min) / (max - min)
   -- the magic number 1 makes both the width and height not overlap with the outline as we are drawing it after them are drawed
   if settings.slider.bar_outlined then
      draw.OutlinedRect(x, y, x + math.floor(width * percentage) - 1, y + height - 1)
   else
      draw.FilledRect(x, y, x + math.floor(width * percentage) - 1, y + height - 1)
   end
end

return slider

end)
__bundle_register("objects.checkbox", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

local function checkbox(width, height, x, y, checked)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   misc.change_color(settings.button.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.checkbox.shadow.offset)

   --- outline
   misc.change_color(settings.checkbox.outline.color)
   misc.draw_outline(width, height, x, y, settings.checkbox.outline.thickness)

   -- checked
   if checked then
      misc.change_color(settings.checkbox.checked_color)
   else
      misc.change_color(settings.checkbox.not_checked_color)
   end
   draw.FilledRect(x, y, x + width - 1, y + height - 1)
end

return checkbox

end)
__bundle_register("objects.buttonfade", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local shapes = require("src.shapes")
local misc = require("src.misc")

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param text string?
---@param alpha_start integer
---@param alpha_end integer
---@param horizontal boolean
local function buttonfade(mouse_inside, width, height, x, y, alpha_start, alpha_end, horizontal, text)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   misc.change_color(settings.button.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.button.shadow.offset)

   --- background
   local color = mouse_inside and settings.button.selected or settings.button.background
   misc.change_color(color)
   shapes.rectanglefade(width, height, x, y, alpha_start, alpha_end, horizontal)

   --- outline
   misc.change_color(settings.button.outline.color)
   misc.draw_outline(width, height, x, y, settings.button.outline.thickness)

   --- text
   if text and #text > 0 then
      draw.SetFont(settings.font)
      local textwidth, textheight = draw.GetTextSize(text)
      misc.change_color(settings.button.text_color)
      if settings.button.shadow.text then
         draw.TextShadow(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight / 2), text)
      else
         draw.Text(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight / 2), text)
      end
   end
end

return buttonfade

end)
__bundle_register("objects.button", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

--- unfortunately if buttons are round we dont have outlines (im too lazy to make them :troll:)
---@param mouse_inside boolean
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param text string?
local function button(mouse_inside, width, height, x, y, text)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   if not settings.button.round then
      misc.change_color(settings.button.shadow.color)
      misc.draw_shadow(width, height, x, y, settings.button.shadow.offset)
   end

   local color = mouse_inside and settings.button.selected or settings.button.background

   if settings.button.round then
      local radius = math.floor(height / 2)

      if settings.button.shadow.offset > 0 then
         --- oh boy these shadows will be EXPENSIVE
         local offset = settings.button.shadow.offset
         misc.change_color(settings.button.shadow.color)
         misc.draw_shadow(width, height, x, y, offset)

         misc.change_color(settings.button.shadow.color)
         misc.filledcircle(x + offset, y + math.ceil(height / 2) + offset, radius)         -- left circle
         misc.filledcircle(x + width + offset, y + math.ceil(height / 2) + offset, radius) -- right circle
      end

      --- side circles
      misc.change_color(color)
      misc.filledcircle(x, y + math.ceil(height / 2), radius)         -- left circle
      misc.filledcircle(x + width, y + math.ceil(height / 2), radius) -- right circle
   else
      --- normal outline
      misc.change_color(settings.button.outline.color)
      misc.draw_outline(width + 1, height + 1, x, y, settings.button.outline.thickness)
   end

   --- background
   misc.change_color(color)
   draw.FilledRect(x, y, x + width, y + height)

   --- text
   if text and #text > 0 then
      draw.SetFont(settings.font)
      local textwidth, textheight = draw.GetTextSize(text)
      misc.change_color(settings.button.text_color)
      if settings.button.shadow.text then
         draw.TextShadow(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight /
               2), text)
      else
         draw.Text(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight / 2),
            text)
      end
   end
end

return button

end)
__bundle_register("objects.windowfade", function(require, _LOADED, __bundle_register, __bundle_modules)
---@alias Fade {start_alpha: integer, end_alpha: integer, horizontal: boolean}

local settings = require("src.settings")
local misc = require("src.misc")

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param start_alpha integer
---@param end_alpha integer
---@param horizontal boolean
local function draw_without_title(width, height, x, y, start_alpha, end_alpha, horizontal)
   if settings.window.shadow.enabled then
      misc.change_color(settings.window.shadow.color)
      misc.draw_shadow(width, height, x, y, settings.window.shadow.offset)
   end

   if settings.window.outline.enabled then
      misc.change_color(settings.window.outline.color)
      misc.draw_outline(width + 1, height + 1, x, y, settings.window.outline.thickness)
   end

   misc.change_color(settings.window.background)
   draw.FilledRectFade(x, y, x + width, y + height, start_alpha, end_alpha, horizontal)
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param title string
local function draw_with_title(width, height, x, y, start_alpha, end_alpha, horizontal, title)
   misc.change_color(settings.window.shadow.color)
   misc.draw_shadow(width, height + settings.window.title.height, x, y - settings.window.title.height,
      settings.window.shadow.offset)

   if settings.window.title.fade.enabled then
      draw.FilledRectFade(x, y, x + width, y - settings.window.title.height, settings.window.title.fade.alpha_start,
         settings.window.title.fade.alpha_end, settings.window.title.fade.horizontal)
   else
      draw.FilledRect(x, y, x + width, y - settings.window.title.height)
   end

   draw.SetFont(settings.font)
   local textwidth, textheight = draw.GetTextSize(title)
   misc.change_color(settings.window.title.text_color)
   if settings.window.title.text_shadow then
      draw.TextShadow(x + math.floor(width / 2) - math.floor(textwidth / 2),
         y - math.floor(settings.window.title.height / 2) - math.floor(textheight / 2), title)
   else
      draw.Text(x + math.floor(width / 2) - math.floor(textwidth / 2),
         y - math.floor(settings.window.title.height / 2) - math.floor(textheight / 2), title)
   end

   misc.change_color(settings.window.outline.color)
   misc.draw_outline(math.floor(width) + 1, height + settings.window.title.height + 1, x,
      y - settings.window.title.height,
      settings.window.outline.thickness)

   misc.change_color(settings.window.background)
   draw.FilledRectFade(x, y, x + width, y + height, start_alpha, end_alpha, horizontal)
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param title string?
local function windowfade(width, height, x, y, start_alpha, end_alpha, horizontal, title)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y); title = title and
       tostring(title) or nil

   if title and #title > 0 then
      draw_with_title(width, height, x, y, start_alpha, end_alpha, horizontal, title)
   else
      draw_without_title(width, height, x, y, start_alpha, end_alpha, horizontal)
   end
end

return windowfade

end)
__bundle_register("objects.window", function(require, _LOADED, __bundle_register, __bundle_modules)
local settings = require("src.settings")
local misc = require("src.misc")

---@param width integer
---@param height integer
---@param x integer
---@param y integer
local function draw_without_title(width, height, x, y)
	if settings.window.shadow.enabled then
		misc.change_color(settings.window.shadow.color)
		misc.draw_shadow(width, height, x, y, settings.window.shadow.offset)
	end

	if settings.window.outline.enabled then
		misc.change_color(settings.window.outline.color)
		misc.draw_outline(width + 1, height + 1, x, y, settings.window.outline.thickness)
	end

	misc.change_color(settings.window.background)
	draw.FilledRect(x, y, x + width, y + height)
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param title string
local function draw_with_title(width, height, x, y, title)
	misc.change_color(settings.window.shadow.color)
	misc.draw_shadow(width, height + settings.window.title.height, x, y - settings.window.title.height,
		settings.window.shadow.offset)

	if settings.window.title.fade.enabled then
		draw.FilledRectFade(x, y, x + width, y - settings.window.title.height, settings.window.title.fade.alpha_start,
			settings.window.title.fade.alpha_end, settings.window.title.fade.horizontal)
	else
		draw.FilledRect(x, y, x + width, y - settings.window.title.height)
	end

	draw.SetFont(settings.font)
	local textwidth, textheight = draw.GetTextSize(title)
	misc.change_color(settings.window.title.text_color)
	if settings.window.title.text_shadow then
		draw.TextShadow(x + math.floor(width / 2) - math.floor(textwidth / 2),
			y - math.floor(settings.window.title.height / 2) - math.floor(textheight / 2), title)
	else
		draw.Text(x + math.floor(width / 2) - math.floor(textwidth / 2),
			y - math.floor(settings.window.title.height / 2) - math.floor(textheight / 2), title)
	end

	misc.change_color(settings.window.outline.color)
	misc.draw_outline(math.floor(width) + 1, height + settings.window.title.height + 1, x,
		y - settings.window.title.height,
		settings.window.outline.thickness)

	misc.change_color(settings.window.background)
	draw.FilledRect(x, y, x + width, y + height)
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param title string?
local function window(width, height, x, y, title)
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y); title = title and
		 tostring(title) or nil

	if title and #title > 0 then
		draw_with_title(width, height, x, y, title)
	else
		draw_without_title(width, height, x, y)
	end
end

return window

end)
__bundle_register("src.config", function(require, _LOADED, __bundle_register, __bundle_modules)
local intro = require("src.intro")
local settings = require("src.settings")

local config = {}

---@return {(encode: fun(param: table):string), (decode: fun(json_string: string):table)}
local function load_json()
   ---Returns the file at version/tag
   ---@param link string
   ---@param version string
   local function get_file(link, version)
      local url = string.format(link, version)
      return http.Get(url)
   end

   local JSON_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/dependencies/json.lua"
   local json = get_file(JSON_LINK, version)
   local loaded = load(json)()
   return loaded
end

local function create_default_config(filename)
   local json = load_json()
   filesystem.CreateDirectory("alib")
   filesystem.CreateDirectory("alib/themes")
   local encoded = json.encode(settings)
   io.output("alib/themes/" .. filename .. ".json")
   io.write(encoded)
   io.flush()
   io.close()
end

--- create default config just in case its not made or outdated
if not _G["alib state"] == intro.states.FINISHED then
   create_default_config("default")
end

local function load_settings(filename)
   filesystem.CreateDirectory("alib")
   filesystem.CreateDirectory("alib/themes")
   local saved_settings = io.open("alib/themes/" .. filename)
   if saved_settings then
      local json = load_json()
      local data = json.decode(saved_settings:read("a"))
      for k, v in pairs(data) do
         settings[k] = v
      end
      printc(233, 245, 66, 255, "Settings loaded!")
   end
end

config.load_settings = load_settings
config.load_json = load_json
config.create_default_config = create_default_config

return config

end)
__bundle_register("src.intro", function(require, _LOADED, __bundle_register, __bundle_modules)
local misc = require("src.misc")
local settings = require("src.settings")
local shapes = require("src.shapes")
local config = require("src.config")

local Math = require("src.usefulmath")
local window = require("objects.window")
local buttonfade = require("objects.buttonfade")

local intro = {}

---@enum intro_states
local intro_states = {
   START = 0,
   LOGO = 1,
   LOGO_FINISHED = 2,
   THEME_SELECTOR = 3,
   FINISHED = 4,
}

intro.states = intro_states
_G["alib state"] = intro.states.START

function intro.init()
   local big_font, version_font
   local screenW, screenH
   local centerX, centerY

   local alibW, alibH
   local alibX, alibY

   local versionW

   --- logo variables
   local color = {}
   local color_variants = { { 255, 255, 255, 255 }, { 60, 60, 60, 255 } }
   local chosen_text_color = color_variants[math.random(1, #color_variants)]
   local degrees = 0
   ---	
   local last_tick = 0
   --- theme selector variables
   local files = {}
   local files_without_extension = {}
   local selected_file = -1
   local themeTEXT = "Themes were found, do you want to load one?"
   local themeTW, themeTH, themeTX, themeTY
   local theme_window = {}
   local load_button = {}
   local close_button = {}
   local list = {}
   ---

   local function intro_start()
      big_font = draw.CreateFont("TF2 BUILD", 128, 1000)
      version_font = draw.CreateFont("TF2 BUILD", 24, 1000)
      screenW, screenH = draw.GetScreenSize()
      centerX, centerY = math.floor(screenW / 2), math.floor(screenH / 2)

      draw.SetFont(big_font)
      alibW, alibH = draw.GetTextSize("ALIB")
      alibX, alibY = centerX - math.floor(alibW / 2), centerY - math.floor(alibH / 2)

      draw.SetFont(version_font)
      versionW = draw.GetTextSize(version)

      draw.SetFont(settings.font)
      themeTW, themeTH = draw.GetTextSize(themeTEXT)

      _G["alib state"] = intro.states.LOGO
      return true
   end

   local function intro_logo()
      local tick_count = globals.TickCount()
      if tick_count > last_tick then
         last_tick = tick_count + Math.Time2Ticks(0.01)

         degrees = degrees + 1
         if degrees >= 360 then
            _G["alib state"] = intro.states.LOGO_FINISHED
            return
         end

         local r, g, b = Math.Hsv_to_RGB(degrees, 1, 1)
         r, g, b = math.floor(r), math.floor(g), math.floor(b)
         color = { r, g, b, 255 }
      end

      misc.change_color(color)
      shapes.triangle(alibX + 64, alibY + math.floor(alibH / 2) + 64, 128)

      draw.SetFont(big_font)
      misc.change_color(color)
      draw.Text(alibX + 2, alibY + 2, "ALIB")

      misc.change_color(chosen_text_color)
      draw.Text(alibX, alibY, "ALIB")

      misc.change_color({ 255, 255, 255, 255 })
      draw.SetFont(version_font)
      draw.TextShadow(alibX - math.floor(versionW / 2) + math.floor(alibW / 2), alibY + math.floor(alibH), version)
   end

   local function intro_logo_finished()
      filesystem.EnumerateDirectory("alib/themes/*.json", function(filename, attributes)
         files[#files + 1] = filename
         files_without_extension[#files_without_extension + 1] = filename:sub(1, #filename - 5)
      end)

      if #files > 1 then
         theme_window.width = math.floor(themeTW) + 5
         theme_window.height = Math.GetListHeight(#files) + 85
         theme_window.x = centerX - math.floor(theme_window.width / 2)
         theme_window.y = centerY - math.floor(theme_window.height / 2)

         load_button.width = 100
         load_button.height = 30
         load_button.x = theme_window.x + math.floor(theme_window.width / 2) - load_button.width
         load_button.y = theme_window.y + theme_window.height - 33

         close_button.width = 100
         close_button.height = 30
         close_button.x = load_button.x + load_button.width + 4
         close_button.y = load_button.y

         themeTX = theme_window.x + math.floor(theme_window.width / 2) - math.floor(themeTW / 2)
         themeTY = theme_window.y + math.floor(themeTH) + 2

         list.width = theme_window.width
         list.x = theme_window.x + math.floor(theme_window.width / 2) - math.floor(list.width / 2)
         list.y = themeTY + math.floor(themeTH) + 10

         _G["alib settings"] = intro.states.THEME_SELECTOR
         return
      end

      _G["alib settings"] = intro.states.FINISHED
   end

   local function intro_theme_selector()
      input.SetMouseInputEnabled(true)
      local load_mouse_inside = Math.isMouseInside(nil, load_button)
      local close_mouse_inside = Math.isMouseInside(nil, close_button)

      local state, tick = input.IsButtonPressed(E_ButtonCode.MOUSE_LEFT)
      if state and tick ~= last_tick then
         last_tick = tick
         for i, v in ipairs(files) do
            local mouse_inside = Math.isMouseInside(nil, list, "ITEM", i)
            if mouse_inside and Math.IsButtonDown(E_ButtonCode.MOUSE_LEFT) then
               selected_file = i
            end
         end

         if load_mouse_inside then
            if files[selected_file] then
               config.load_settings(files[selected_file])
               _G["alib settings"] = settings
            end
         elseif close_mouse_inside then
            input.SetMouseInputEnabled(false)
            _G["alib state"] = intro.states.FINISHED
            return
         end
      end

      window(theme_window.width, theme_window.height, theme_window.x, theme_window.y, "theme selector")
      list(list.width, list.x, list.y, selected_file, files_without_extension)
      buttonfade(load_mouse_inside, load_button.width, load_button.height, load_button.x, load_button.y, 255, 50,
         false,
         "load")
      buttonfade(close_mouse_inside, close_button.width, close_button.height, close_button.x, close_button.y, 255,
         50, false, "close")

      draw.TextShadow(themeTX, themeTY, themeTEXT)
   end

   local function intro_finished()
      big_font, version_font = nil, nil
      screenW, screenH = nil, nil
      centerX, centerY = nil, nil
      alibW, alibH = nil, nil
      alibX, alibY = nil, nil
      versionW = nil
      color = nil
      color_variants = nil
      chosen_text_color = nil
      ---@diagnostic disable-next-line: cast-local-type
      degrees = nil
      ---@diagnostic disable-next-line: cast-local-type
      last_tick = nil
      files = nil
      files_without_extension = nil
      ---@diagnostic disable-next-line: cast-local-type
      selected_file = nil
      ---@diagnostic disable-next-line: cast-local-type
      themeTEXT = nil
      themeTW, themeTH = nil, nil
      theme_window = nil
      load_button = nil
      close_button = nil
      list = nil
      collectgarbage("collect")
      callbacks.Unregister("Draw", "alib intro draw")
   end

   callbacks.Register("Draw", "alib intro draw", function()
      if _G["alib state"] == intro.states.START then
         intro_start()
      elseif _G["alib state"] == intro.states.LOGO then
         intro_logo()
      elseif _G["alib state"] == intro.states.LOGO_FINISHED then
         intro_logo_finished()
      elseif _G["alib state"] == intro.states.THEME_SELECTOR then
         intro_theme_selector()
      elseif _G["alib state"] == intro.states.FINISHED then
         intro_finished()
      end
   end)
end

return intro

end)
return __bundle_require("__root")