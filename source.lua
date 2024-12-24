local version = "0.42"

local settings = {
	font = draw.CreateFont("Arial", 12, 1000),
	window = {
		background = { 40, 40, 40, 255 },
		outline = { thickness = 1, color = { 255, 255, 255, 255 } },
		shadow = { offset = 3, color = { 0, 0, 0, 200 } },
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

--- cache functions so its faster

--- lua
local load = load
local pairs = pairs
local ipairs = ipairs
local next = next
local collectgarbage = collectgarbage

--- draw stuff
local Text = draw.Text
local TextShadow = draw.TextShadow
local Color = draw.Color
local FilledRect = draw.FilledRect
local FilledRectFade = draw.FilledRectFade
local FilledRectFastFade = draw.FilledRectFastFade
local OutlinedRect = draw.OutlinedRect
local OutlinedCircle = draw.OutlinedCircle
local ColoredCircle = draw.ColoredCircle
local SetFont = draw.SetFont
local CreateFont = draw.CreateFont
local GetTextSize = draw.GetTextSize
local GetScreenSize = draw.GetScreenSize
local Line = draw.Line

--- input stuff
local GetMousePos = input.GetMousePos
local SetMouseInputEnabled = input.SetMouseInputEnabled
local IsButtonDown = input.IsButtonDown
local IsButtonPressed = input.IsButtonPressed
local IsButtonReleased = input.IsButtonReleased

--- math stuff
local floor = math.floor
local ceil = math.ceil
local random = math.random
local abs = math.abs
local randomseed = math.randomseed

--- callback stuff
local Register = callbacks.Register
local Unregister = callbacks.Unregister

--- http stuff
local Get = http.Get

--- output stuff
local CreateDirectory = filesystem.CreateDirectory
local EnumerateDirectory = filesystem.EnumerateDirectory
local printc = printc
local output = io.output
local write = io.write
local flush = io.flush
local close = io.close
local open = io.open

local defaultsettings = settings
defaultsettings.font = nil

if _G["alib settings"] then
	settings = _G["alib settings"]
end

local jsonlib = Get("https://raw.githubusercontent.com/rxi/json.lua/refs/heads/master/json.lua")
---@type {(encode: fun(param: table):string), (decode: fun(json_string: string):table)}
local json = load(jsonlib)()

local function create_default_config(filename)
	CreateDirectory("alib/themes")
	local encoded = json.encode(defaultsettings)
	output("alib/themes/" .. filename .. ".json")
	write(encoded)
	flush()
	close()
end

--- create default config just in case its not made or outdated
create_default_config("default")

local function load_settings(filename)
	local saved_settings = open("alib/themes/" .. filename)
	if saved_settings then
		local json_lib = Get("https://raw.githubusercontent.com/rxi/json.lua/refs/heads/master/json.lua")
		---@type {(encode: fun(param: table):string), (decode: fun(json_string: string):table)}
		local json = load(json_lib)()
		local data = json.decode(saved_settings:read("a"))
		for k, v in pairs(data) do
			settings[k] = v
		end
		---@diagnostic disable-next-line: cast-local-type
		json = nil
		---@diagnostic disable-next-line: cast-local-type
		json_lib = nil
		printc(233, 245, 66, 255, "Settings loaded!")
	end
end

--- create directory just in case
CreateDirectory("alib")

local function change_color(color)
	Color(color[1], color[2], color[3], color[4])
end

local shapes = {}

---@param filled boolean
---@param width integer
---@param height integer
---@param x integer
---@param y integer
function shapes.rectangle(width, height, x, y, filled)
	if filled then
		FilledRect(x, y, width + x, y + height)
	else
		OutlinedRect(x, y, width + x, y + height)
	end
	return true
end

---@param x integer
---@param y integer
---@param radius integer
---@param segments integer
function shapes.circle(x, y, radius, segments)
	OutlinedCircle(x, y, radius, segments)
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
	FilledRectFade(x, y, x + width, y + height, alpha_start, alpha_end, horizontal)
	return true
end

--- tbh i dont know why someone would use this but ok?
function shapes.triangle(x, y, size)
	Line(x, y, x + size, y)
	Line(x + floor(size / 2), y - size, x + size, y)
	Line(x + floor(size / 2), y - size, x, y)
	return true
end

local objects = {}

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param thickness integer
local function draw_outline(width, height, x, y, thickness)
	if thickness == 0 then return true end
	local rectangle = shapes.rectangle
	for i = 1, thickness do
		rectangle(width + (1 * i), height + (1 * i), x - (1 * i), y - (1 * i), false)
	end
	return true
end

local function draw_shadow(width, height, x, y, offset)
	if offset == 0 then return true end
	local rectangle = shapes.rectangle
	rectangle(width, height, x + offset, y + offset, true)
	return true
end

---This renders a window
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param title string?
function objects.window(width, height, x, y, title)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	if title then
		--- shadow
		change_color(settings.window.shadow.color)
		draw_shadow(width, height + settings.window.title.height, x, y - settings.window.title.height,
			settings.window.shadow.offset)

		change_color(settings.window.title.background)
		if settings.window.title.fade.enabled then
			shapes.rectanglefade(width, settings.window.title.height, x, y - settings.window.title.height,
				settings.window.title.fade.alpha_start, settings.window.title.fade.alpha_end,
				settings.window.title.fade.horizontal)
		else
			shapes.rectangle(width, settings.window.title.height, x, y - settings.window.title.height, true)
		end

		SetFont(settings.font)
		local textwidth, textheight = GetTextSize(title)
		change_color(settings.window.title.text_color)
		if settings.window.title.text_shadow then
			TextShadow(x + floor(width / 2) - floor(textwidth / 2),
				y - floor(settings.window.title.height / 2) - floor(textheight / 2), title)
		else
			Text(x + floor(width / 2) - floor(textwidth / 2),
				y - floor(settings.window.title.height / 2) - floor(textheight / 2), title)
		end

		change_color(settings.window.outline.color)
		draw_outline(floor(width) + 1, height + settings.window.title.height + 1, x, y - settings.window.title.height,
			settings.window.outline.thickness)
	else
		--- shadow
		change_color(settings.window.shadow.color)
		draw_shadow(width, height, x, y, settings.window.shadow.offset)

		--- outline
		change_color(settings.window.outline.color)
		draw_outline(width + 1, height + 1, x, y, settings.window.outline.thickness)
	end

	--- background
	change_color(settings.window.background)
	shapes.rectangle(width, height, x, y, true)
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param alpha_start integer [0, 255]
---@param alpha_end integer [0, 255]
---@param horizontal boolean? default = true
function objects.windowfade(width, height, x, y, alpha_start, alpha_end, horizontal, title)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	if title then
		--- shadow
		change_color(settings.window.shadow.color)
		draw_shadow(width, height + settings.window.title.height, x, y - settings.window.title.height,
			settings.window.shadow.offset)

		change_color(settings.window.title.background)
		if settings.window.title.fade.enabled then
			shapes.rectanglefade(width, settings.window.title.height, x, y - settings.window.title.height,
				settings.window.title.fade.alpha_start, settings.window.title.fade.alpha_end,
				settings.window.title.fade.horizontal)
		else
			shapes.rectangle(width, settings.window.title.height, x, y - settings.window.title.height, true)
		end

		SetFont(settings.font)
		local textwidth, textheight = GetTextSize(title)
		change_color(settings.window.title.text_color)
		if settings.window.title.text_shadow then
			TextShadow(x + floor(width / 2) - floor(textwidth / 2),
				y - floor(settings.window.title.height / 2) - floor(textheight / 2), title)
		else
			Text(x + floor(width / 2) - floor(textwidth / 2),
				y - floor(settings.window.title.height / 2) - floor(textheight / 2), title)
		end

		change_color(settings.window.outline.color)
		draw_outline(width + 1, height + settings.window.title.height + 1, x, y - settings.window.title.height,
			settings.window.outline.thickness)
	else
		--- shadow
		change_color(settings.window.shadow.color)
		draw_shadow(width, height, x, y, settings.window.shadow.offset)

		--- outline
		change_color(settings.window.outline.color)
		draw_outline(width + 1, height + 1, x, y, settings.window.outline.thickness)
	end

	--- background
	change_color(settings.window.background)
	shapes.rectanglefade(width, height, x, y, alpha_start, alpha_end, horizontal)
end

--- unfortunately if buttons are round we dont have outlines (im too lazy to make them :troll:)
---@param mouse_inside boolean
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param text string?
function objects.button(mouse_inside, width, height, x, y, text)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	--- shadow
	if not settings.button.round then
		change_color(settings.button.shadow.color)
		draw_shadow(width, height, x, y, settings.button.shadow.offset)
	end

	local color = mouse_inside and settings.button.selected or settings.button.background

	if settings.button.round then
		local radius = floor(height / 2)

		if settings.button.shadow.offset > 0 then
			--- oh boy these shadows will be EXPENSIVE
			local offset = settings.button.shadow.offset
			change_color(settings.button.shadow.color)
			draw_shadow(width, height, x, y, offset)

			change_color(settings.button.shadow.color)
			shapes.filledcircle(x + offset, y + ceil(height / 2) + offset, radius)   -- left circle
			shapes.filledcircle(x + width + offset, y + ceil(height / 2) + offset, radius) -- right circle
		end

		--- side circles
		change_color(color)
		shapes.filledcircle(x, y + ceil(height / 2), radius)     -- left circle
		shapes.filledcircle(x + width, y + ceil(height / 2), radius) -- right circle
	else
		--- normal outline
		change_color(settings.button.outline.color)
		draw_outline(width + 1, height + 1, x, y, settings.button.outline.thickness)
	end

	--- background
	change_color(color)
	shapes.rectangle(width, height, x, y, true)

	--- text
	if text and #text > 0 then
		SetFont(settings.font)
		local textwidth, textheight = GetTextSize(text)
		change_color(settings.button.text_color)
		if settings.button.shadow.text then
			TextShadow(x + floor(width / 2) - floor(textwidth / 2),
				y + floor(height / 2) - floor(textheight /
					2), text)
		else
			Text(x + floor(width / 2) - floor(textwidth / 2),
				y + floor(height / 2) - floor(textheight / 2),
				text)
		end
	end
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param text string?
---@param alpha_start integer
---@param alpha_end integer
---@param horizontal boolean
function objects.buttonfade(mouse_inside, width, height, x, y, alpha_start, alpha_end, horizontal, text)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	--- shadow
	change_color(settings.button.shadow.color)
	draw_shadow(width, height, x, y, settings.button.shadow.offset)

	--- background
	local color = mouse_inside and settings.button.selected or settings.button.background
	change_color(color)
	shapes.rectanglefade(width, height, x, y, alpha_start, alpha_end, horizontal)

	--- outline
	change_color(settings.button.outline.color)
	draw_outline(width, height, x, y, settings.button.outline.thickness)

	--- text
	if text and #text > 0 then
		SetFont(settings.font)
		local textwidth, textheight = GetTextSize(text)
		change_color(settings.button.text_color)
		if settings.button.shadow.text then
			TextShadow(x + floor(width / 2) - floor(textwidth / 2),
				y + floor(height / 2) - floor(textheight / 2), text)
		else
			Text(x + floor(width / 2) - floor(textwidth / 2),
				y + floor(height / 2) - floor(textheight / 2), text)
		end
	end
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param checked boolean
function objects.checkbox(width, height, x, y, checked)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	--- shadow
	change_color(settings.button.shadow.color)
	draw_shadow(width, height, x, y, settings.checkbox.shadow.offset)

	--- outline
	change_color(settings.checkbox.outline.color)
	draw_outline(width, height, x, y, settings.checkbox.outline.thickness)

	-- checked
	if checked then
		change_color(settings.checkbox.checked_color)
	else
		change_color(settings.checkbox.not_checked_color)
	end
	shapes.rectangle(width - 1, height - 1, x, y, true)
end

---renders a slider
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param min integer
---@param max integer
---@param value integer
function objects.slider(width, height, x, y, min, max, value)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	--- shadow
	change_color(settings.slider.shadow.color)
	draw_shadow(width, height, x, y, settings.slider.shadow.offset)

	--- background
	change_color(settings.slider.background)
	shapes.rectangle(width, height, x, y, true)

	--- outline
	change_color(settings.slider.outline.color)
	draw_outline(width, height, x, y, settings.slider.outline.thickness)

	--- slider bar
	change_color(settings.slider.bar_color)
	local percentage = (value - min) / (max - min)
	-- the magic number 1 makes both the width and height not overlap with the outline as we are drawing it after them are drawed
	if settings.slider.bar_outlined then
		shapes.rectangle(floor(width * percentage) - 1, height - 1, x, y, false)
	else
		shapes.rectangle(floor(width * percentage) - 1, height - 1, x, y, true)
	end
end

---renders a slider
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param min integer
---@param max integer
---@param value integer
---@param alpha_start integer
---@param alpha_end integer
---@param horizontal boolean
function objects.sliderfade(width, height, x, y, min, max, value, alpha_start, alpha_end, horizontal)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	--- shadow
	change_color(settings.slider.shadow.color)
	draw_shadow(width, height, x, y, settings.slider.shadow.offset)

	--- background
	change_color(settings.slider.background)
	shapes.rectangle(width, height, x, y, true)

	--- outline
	change_color(settings.slider.outline.color)
	draw_outline(width, height, x, y, settings.slider.outline.thickness)

	--- slider bar
	change_color(settings.slider.bar_color)
	local percentage = (value - min) / (max - min)
	shapes.rectanglefade(floor(width * percentage) - 1, height - 1, x, y, alpha_start, alpha_end, horizontal)
end

---@param width integer
---@param x integer
---@param y integer
---@param selected_item_index integer starts at 0
---@param items table<integer, string>
function objects.list(width, x, y, selected_item_index, items)
	width = floor(width); x = floor(x); y = floor(y)
	local height = #items * floor(settings.list.item_height)

	--- shadow
	change_color(settings.list.shadow.color)
	draw_shadow(width, height, x, y, settings.list.shadow.offset)

	--- outline
	change_color(settings.list.outline.color)
	draw_outline(width + 1, height + 1, x, y, settings.list.outline.thickness)

	--- background
	change_color(settings.list.background)
	shapes.rectangle(width, height, x, y, true)

	--- draw items
	local y = y
	for i, item in ipairs(items) do
		if i == selected_item_index then
			change_color(settings.list.selected)
			shapes.rectangle(width, settings.list.item_height, x, y, true)
		end

		SetFont(settings.font)
		local textwidth, textheight = GetTextSize(item)
		change_color(settings.list.text_color)
		Text(x + width / 2 - floor(textwidth / 2), y + floor(textheight / 2), item)
		y = y + settings.list.item_height
	end
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param min integer
---@param max integer
---@param value integer
---@param flipped boolean
function objects.verticalslider(width, height, x, y, min, max, value, flipped)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	--- shadow
	change_color(settings.slider.shadow.color)
	draw_shadow(width, height, x, y, settings.slider.shadow.offset)

	--- background
	change_color(settings.slider.background)
	shapes.rectangle(width, height, x, y, true)

	--- slider bar
	local percentage = (value - min) / (max - min)
	local bar_height = floor(height * percentage)
	local bar_y = not flipped and y or y + (height - bar_height)

	change_color(settings.slider.bar_color)
	-- the magic number 1 makes both the width and height not overlap with the outline as we are drawing it after them are drawed
	shapes.rectangle(width - 1, bar_height, x, bar_y, true)

	--- outline
	change_color(settings.slider.outline.color)
	draw_outline(width, height, x, y, settings.slider.outline.thickness)
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param min integer
---@param max integer
---@param value integer
---@param flipped boolean
---@param alphastart integer
---@param alphaend integer
---@param horizontal boolean
function objects.verticalsliderfade(width, height, x, y, min, max, value, flipped, alphastart, alphaend, horizontal)
	width = floor(width); height = floor(height); x = floor(x); y = floor(y)
	--- shadow
	change_color(settings.slider.shadow.color)
	draw_shadow(width, height, x, y, settings.slider.shadow.offset)

	--- background
	change_color(settings.slider.background)
	shapes.rectangle(width, height, x, y, true)

	--- slider bar
	change_color(settings.slider.bar_color)
	local percentage = (value - min) / (max - min)
	local bar_height = floor(height * percentage)

	local bar_y = not flipped and y or y + (height - bar_height)

	-- the magic number 1 makes both the width and height not overlap with the outline as we are drawing it after them are drawed
	shapes.rectanglefade(width - 1, bar_height, x, bar_y, alphastart, alphaend, horizontal)

	--- outline
	change_color(settings.slider.outline.color)
	draw_outline(width, height, x, y, settings.slider.outline.thickness)
end

--- math is hard
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

--- checks if mouse is inside or not the object \
--- use isMouseInsideRoundButton if alib.settings.button.round is true
---@param parent table<string, any>?
---@param object table<string, any>
---@nodiscard
---@return boolean
function Math.isMouseInside(parent, object)
	local mousePos = GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= object.x + (parent and parent.x or 0) and mx <= object.x + object.width + (parent and parent.x or 0) and
		 my >= object.y + (parent and parent.y or 0) and my <= object.y + object.height + (parent and parent.y or 0)
end

--- special isMouseInside for round buttons as we dont know if the object is round or not
---@param parent table<string, any>
---@param round_button table<string, any>
---@nodiscard
---@return boolean
function Math.isMouseInsideRoundButton(parent, round_button)
	local mousePos = GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= round_button.x + parent.x - floor(round_button.height / 2) and
		 mx <= round_button.x + round_button.width + parent.x + floor(round_button.height / 2) and
		 my >= round_button.y + parent.y and my <= round_button.y + round_button.height + parent.y
end

--- calculates the new slider value so you dont have to do math
---@param slider table<string, any>
---@param min integer
---@param max integer
---@nodiscard
---@return integer
function Math.GetNewSliderValue(window, slider, min, max)
	local mx = GetMousePos()[1]
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
	local my = GetMousePos()[2]
	local initial_mouse_pos = my - (slider.y + window.y)
	local normalized_pos = initial_mouse_pos / slider.height

	if flipped then
		normalized_pos = 1 - normalized_pos
	end

	local new_value = Math.clamp(min + (normalized_pos * (max - min)), min, max)
	return new_value
end

---@param parent table<string, any>?
---@param list table
---@param index integer
---@nodiscard
---@return boolean
function Math.isMouseInsideItem(parent, list, index)
	parent = parent or { x = 0, y = 0 }
	local height = settings.list.item_height
	local y = parent.y + list.y + ((index - 1) * settings.list.item_height)

	local mousePos = GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= list.x + parent.x and mx <= list.x + list.width + parent.x and my >= y and my <= y + height
end

---@param parent table?
---@param list table
---@nodiscard
---@return boolean
function Math.isMouseInsideList(parent, list)
	local mousePos = GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	local height = #list.items * settings.list.item_height
	return mx >= list.x + (parent and parent.x or 0) and mx <= list.x + list.width + (parent and parent.x or 0) and
		 my >= list.y + (parent and parent.y or 0) and my <= list.y + height + (parent and parent.y or 0)
end

---@nodiscard
---@return integer
function Math.GetSliderPercentage(slider)
	return (slider.value - slider.min) / (slider.max - slider.min)
end

---@return integer
---@nodiscard
function Math.GetListHeight(number_of_items)
	return number_of_items * floor(settings.list.item_height)
end

function Math.HSV_TO_RGB(hue, saturation, value)
	local chroma = value * saturation
	local hue_segment = hue / 60
	local x = chroma * (1 - abs((hue_segment % 2) - 1))

	local r1, g1, b1 = 0, 0, 0
	local segment_map = {
		[0] = function() return chroma, x, 0 end,
		[1] = function() return x, chroma, 0 end,
		[2] = function() return 0, chroma, x end,
		[3] = function() return 0, x, chroma end,
		[4] = function() return x, 0, chroma end,
		[5] = function() return chroma, 0, x end
	}

	local segment = floor(hue_segment)
	if segment_map[segment] then
		r1, g1, b1 = segment_map[segment]()
	end

	local m = value - chroma
	return (r1 + m) * 255, (g1 + m) * 255, (b1 + m) * 255
end

function Math.Time2Ticks(seconds)
	return seconds * 66.67
end

local clicked_tick = 0

local files = {}
local files_without_ext = {}
local selected_file = -1

local function draw_ask_window()
	SetMouseInputEnabled(true)
	local screenW, screenH = GetScreenSize()
	local centerX, centerY = floor(screenW / 2), floor(screenH / 2)

	local text = "Themes were found, do you want to load one?"
	SetFont(settings.font)
	local tw, th = GetTextSize(text)

	local window = {
		width = floor(tw) + 5,
		height = Math.GetListHeight(#files) + 85,
		x = 0,
		y = 0
	}
	window.x = centerX - floor(window.width / 2)
	window.y = centerY - floor(window.height / 2)
	objects.window(window.width, window.height, window.x, window.y, "theme selector")

	local load_button = {
		width = 100,
		height = 30,
		x = 0,
		y = 0
	}
	load_button.x = window.x + floor(window.width / 2) - load_button.width
	load_button.y = window.y + window.height - 33

	local no_button = {
		width = 100,
		height = 30,
		x = load_button.x + load_button.width + 4,
		y = load_button.y,
	}

	local load_mouse = Math.isMouseInside(nil, load_button)
	local no_mouse = Math.isMouseInside(nil, no_button)

	--- Themes were found text render
	local x = floor(window.width / 2) + window.x - floor(tw / 2)
	local y = window.y + floor(th) + 2
	change_color({ 255, 255, 255, 255 })
	TextShadow(x, y, text)

	local list = {
		width = 300,
		x = window.x + floor(window.width / 2) - 150,
		y = y + floor(th) + 10
	}

	objects.list(list.width, list.x, list.y, selected_file, files_without_ext)

	objects.buttonfade(load_mouse, load_button.width, load_button.height, load_button.x, load_button.y, 255, 50, false,
		"load")
	objects.buttonfade(no_mouse, no_button.width, no_button.height, no_button.x, no_button.y, 255, 50, false, "close")

	local state, tick = IsButtonPressed(E_ButtonCode.MOUSE_LEFT)
	if state and tick ~= clicked_tick then
		for i, v in ipairs(files) do
			local is_mouse_inside = Math.isMouseInsideItem(nil, list, i)
			if is_mouse_inside and IsButtonDown(E_ButtonCode.MOUSE_LEFT) then
				selected_file = i
			end
		end

		clicked_tick = tick
		if load_mouse then
			load_settings(files[selected_file])
			SetMouseInputEnabled(false)
			_G["alib settings"] = settings
		elseif no_mouse then
			SetMouseInputEnabled(false)
			Unregister("Draw", "alib ask load")
		end
	end
end

local snow_font = CreateFont("Arial", 20, 1000)
local function snow(alpha)
	local num_balls = 1000
	local balls = {}
	local vertical_wind = 3
	local width, height = GetScreenSize()
	SetFont(snow_font)
	local tw, th = GetTextSize("*")

	local function create_ball()
		local x = random(0, width)
		local y = random(-height, 0)
		local color = { random(0, 255), random(0, 255), random(0, 255), alpha }
		return floor(x), floor(y), color
	end

	--- create the balls
	for i = 1, num_balls do
		balls[i] = { create_ball() }
	end

	Unregister("CreateMove", "alib snow createmove")
	Register("CreateMove", "alib snow createmove", function(param)
		randomseed(param.tick_count)
		for i = 1, num_balls do
			-- Reset if snowflake goes off screen
			if balls[i][1] > width or balls[i][1] < 0 or balls[i][2] > height then
				balls[i] = { create_ball() }
			end

			balls[i][2] = balls[i][2] + vertical_wind + random(0, 3)

			-- Random horizontal movement
			if random(1, 32) == 1 then
				balls[i][1] = balls[i][1] + random(-2, 2)
			end
		end
	end)

	Unregister("Draw", "alib snow draw")
	-- Draw snowflakes
	Register("Draw", "alib snow draw", function()
		SetFont(snow_font)
		for k, ball in ipairs(balls) do
			local x, y, color = ball[1], ball[2], ball[3]
			if y > 0 and y < height and x > 0 and x < width then
				Color(color[1], color[2], color[3], color[4])
				Text(x, y, "*")
			end
		end
	end)
end

local function unload_snow(font)
	Unregister("CreateMove", "alib snow createmove")
	Unregister("Draw", "alib snow draw")
	if font and snow_font then
		snow_font = nil
	end
end

local function RunIntro()
	Unregister("CreateMove", "alib alpha")
	Unregister("Draw", "alib intro")
	unload_snow(false)

	snow(200)

	local big_font = CreateFont("TF2 BUILD", 128, 1000)
	local version_font = CreateFont("TF2 BUILD", 24, 1000)
	local screenW, screenH = GetScreenSize()
	local centerX, centerY = floor(screenW / 2), floor(screenH / 2)

	SetFont(big_font)
	local tw, th = GetTextSize("ALIB")

	local x, y = centerX - floor(tw / 2), centerY - floor(th / 2)

	SetFont(version_font)
	local version_tw, version_th = GetTextSize(version)

	local degrees = 0
	local color = { 255, 255, 255, 0 }
	local last_tick = 0
	local finished = false

	local color_variants = { { 255, 255, 255, 255 }, { 60, 60, 60, 255 } }
	local chosen_alib_text_color = color_variants[random(1, #color_variants)]

	Unregister("CreateMove", "alib alpha")
	---@param param UserCmd
	Register("CreateMove", "alib alpha", function(param)
		local tick_count = param.tick_count
		if tick_count > last_tick then
			last_tick = tick_count + Math.Time2Ticks(0.01)

			degrees = degrees + 1
			if degrees >= 360 then
				finished = true
				Unregister("CreateMove", "alib alpha")
			end

			local r, g, b = Math.HSV_TO_RGB(degrees, 1, 1)
			r, g, b = floor(r), floor(g), floor(b)
			color = { r, g, b, 255 }
		end
	end)

	Unregister("Draw", "alib intro")
	Register("Draw", "alib intro", function()
		if finished then
			EnumerateDirectory("alib/themes/*.json", function(filename, attributes)
				files[#files + 1] = filename
				files_without_ext[#files_without_ext + 1] = filename:sub(1, #filename - 5)
			end)

			if #files > 1 then --- if its 1 it means there is only default.json as we create one already in the start
				Unregister("Draw", "alib ask load")
				Register("Draw", "alib ask load", draw_ask_window)
			end

			unload_snow(true)
			Unregister("Draw", "alib intro")
		end

		change_color(color)
		shapes.triangle(x + 64, y + floor(th / 2) + 64, 128)

		SetFont(big_font)
		change_color(color)
		Text(x + 2, y + 2, "ALIB")

		change_color(chosen_alib_text_color)
		Text(x, y, "ALIB")

		change_color({ 255, 255, 255, 255 })
		SetFont(version_font)
		TextShadow(x - floor(version_tw / 2) + floor(tw / 2), y + floor(th), version)
	end)
end

local function unload()
	local mem_before = collectgarbage("count")

	Unregister("CreateMove", "alib alpha")
	Unregister("Draw", "alib intro")
	Unregister("Draw", "alib ask load")
	Unregister("CreateMove", "alib createmove theme selector button")
	Unregister("Draw", "alib theme selector button")
	unload_snow(true)

	-- Clean up package cache
	package.loaded["alib"] = nil
	package.loaded["source"] = nil
	_G["alib settings"] = nil

	-- Force garbage collection
	collectgarbage("collect")
	local mem_after = collectgarbage("count")

	local cleaned = tostring(mem_before - mem_after)
	local cleaned_in_MB = string.sub(cleaned, 1, 2)

	json = nil
	jsonlib = nil
	settings.font = nil

	print("Unloaded alib")
	print("Collected " .. cleaned_in_MB .. " MB of used memory")
end

local alib = {
	settings = settings,
	objects = objects,
	shapes = shapes,
	math = Math,
	unload = unload,
}

Unregister("CreateMove", "alib alpha")
Unregister("Draw", "alib intro")
Unregister("Draw", "alib ask load")
Unregister("CreateMove", "alib createmove theme selector button")
Unregister("Draw", "alib theme selector button")
RunIntro()

printc(50, 255, 150, 255, "Alib " .. version .. " has loaded!")
return alib
