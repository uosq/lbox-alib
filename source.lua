local version = "0.44"

--[[
// dont change stuff below unless you know what you're doing
// or just ignore me
--]]

local settings = {
	font = 0, --- useless doesnt work idk why
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
local collectgarbage = collectgarbage

--- draw stuff
local Text = draw.Text
local TextShadow = draw.TextShadow
local Color = draw.Color
local FilledRect = draw.FilledRect
local FilledRectFade = draw.FilledRectFade
local OutlinedRect = draw.OutlinedRect
local OutlinedCircle = draw.OutlinedCircle
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

--- math stuff
local floor = math.floor
local ceil = math.ceil
local random = math.random
local abs = math.abs
local randomseed = math.randomseed
local cos = math.cos
local sin = math.sin
local rad = math.rad

--- callback stuff
local Register = callbacks.Register
local Unregister = callbacks.Unregister

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

---@enum intro_states
local intro_states = {
	START = 1 << 0,
	LOGO = 1 << 1,
	LOGO_FINISHED = 1 << 2,
	THEME_SELECTOR = 1 << 3,
	FINISHED = 1 << 4,
}

---@type intro_states
local intro = intro_states.START

local latest_version = http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/latest_version")
if version > latest_version then
	--- we'll assume its a non stable version
	--intro = intro_states.FINISHED
	warn("Alib is running a unstable version", "Intro, JSON and other version-dependent stuff wont be loaded")

	local background = { x = 20, y = 50, width = 50, height = 20 }

	callbacks.Register("Draw", "alib unstable version", function(param)
		FilledRect(background.x, background.y, background.x + background.width, background.y + background.height)
		SetFont(settings.font)
		TextShadow(background.x, background.y, "ALIB UNSTABLE")
	end)
end

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
	CreateDirectory("alib")
	CreateDirectory("alib/themes")
	local encoded = json.encode(defaultsettings)
	output("alib/themes/" .. filename .. ".json")
	write(encoded)
	flush()
	close()
end

--[[
--- create default config just in case its not made or outdated
if not intro == intro_states.FINISHED then
	create_default_config("default")
end]]

local function load_settings(filename)
	CreateDirectory("alib")
	CreateDirectory("alib/themes")
	local saved_settings = open("alib/themes/" .. filename)
	if saved_settings then
		local json = load_json()
		local data = json.decode(saved_settings:read("a"))
		for k, v in pairs(data) do
			settings[k] = v
		end
		printc(233, 245, 66, 255, "Settings loaded!")
	end
end

local function change_color(color)
	Color(color[1], color[2], color[3], color[4])
end

local shapes = {}

---@param x integer
---@param y integer
---@param origin {}
---@param angle any
local function rotate_point(x, y, origin, angle)
	local x = x - (origin[1] or 0)
	local y = y - (origin[2] or 0)

	local cos_angle = cos(rad(angle))
	local sin_angle = sin(rad(angle))

	--- i wish we had support for numbers instead of integers :sob:
	local rotated_x = floor((x * cos_angle) - (y * sin_angle))
	local rotated_y = floor((x * sin_angle) + (y * cos_angle))

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
	Line(x1, y1, x2, y2)
end

---I love unoptimized stuff! Doesnt work right but im too lazy to delete it
--- @param width integer
---@param height integer
---@param x integer
---@param y integer
---@param angle integer degrees (20, 30, 45, 60, etc)
function shapes.rotatable_rectangle(width, height, x, y, angle)
	local origin = { x + floor(width / 2), y + floor(height / 2) } --- middle of the rectangle

	for i = 0, height do
		local start_x, start_y = rotate_point(x, y + i, origin, angle)
		local end_x, end_y = rotate_point(x + width, y + i, origin, angle)
		Line(start_x, start_y, end_x, end_y)
	end
end

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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
	width, x, y = floor(width), floor(x), floor(y)
	local item_height = floor(settings.list.item_height)
	local height = floor(#items * item_height)

	local half_width = floor(width / 2)

	-- Draw container elements
	local function draw_container()
		-- Shadow
		change_color(settings.list.shadow.color)
		draw_shadow(width, height, x, y, settings.list.shadow.offset)

		-- Outline
		change_color(settings.list.outline.color)
		draw_outline(width + 1, height + 1, x, y, settings.list.outline.thickness)

		-- Background
		change_color(settings.list.background)
		shapes.rectangle(width, height, x, y, true)
	end

	-- Draw item elements
	local function draw_items()
		SetFont(settings.font) -- Set font once outside the loop
		local current_y = y

		for i, item in ipairs(items) do
			-- Draw selection highlight if needed
			if i == selected_item_index then
				change_color(settings.list.selected)
				shapes.rectangle(width, item_height, x, current_y, true)
			end

			-- Calculate text position
			local textwidth, textheight = GetTextSize(item)
			local text_x = x + half_width - floor(textwidth / 2)
			local text_y = current_y + floor(textheight / 2)

			-- Draw text
			change_color(settings.list.text_color)
			Text(text_x, text_y, item)

			-- Move to next item position
			current_y = current_y + item_height
		end
	end

	draw_container()
	draw_items()
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
	if not intro == intro_states.FINISHED then return end
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
	if not intro == intro_states.FINISHED then return end
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

local misc = {}

--- default NORMAL
---@enum (key) MSMode
misc.MouseInsideMode = {
	NORMAL = function(parent, object)
		local mousePos = GetMousePos()
		local mx, my = mousePos[1], mousePos[2]
		return mx >= object.x + (parent and parent.x or 0) and mx <= object.x + object.width + (parent and parent.x or 0) and
			 my >= object.y + (parent and parent.y or 0) and my <= object.y + object.height + (parent and parent.y or 0)
	end,

	WINDOW_TITLE = function(parent, object)
		local mousePos = GetMousePos()
		local mx, my = mousePos[1], mousePos[2]
		return mx >= object.x + (parent and parent.x or 0) and
			 mx <= object.x + object.width + (parent and parent.x or 0) and
			 my >= object.y + (parent and parent.y or 0) - settings.window.title.height and
			 my <= object.y + object.height + (parent and parent.y or 0)
	end,

	ROUND_BUTTON = function(parent, round_button)
		local mousePos = GetMousePos()
		local mx, my = mousePos[1], mousePos[2]
		return mx >= round_button.x + parent.x - floor(round_button.height / 2) and
			 mx <= round_button.x + round_button.width + parent.x + floor(round_button.height / 2) and
			 my >= round_button.y + parent.y and my <= round_button.y + round_button.height + parent.y
	end,

	ITEM = function(parent, list, index)
		parent = parent or { x = 0, y = 0 }
		local height = settings.list.item_height
		local y = parent.y + list.y + ((index - 1) * settings.list.item_height)

		local mousePos = GetMousePos()
		local mx, my = mousePos[1], mousePos[2]
		return mx >= list.x + parent.x and mx <= list.x + list.width + parent.x and my >= y and my <= y + height
	end,

	LIST = function(parent, list)
		local mousePos = GetMousePos()
		local mx, my = mousePos[1], mousePos[2]
		local height = #list.items * settings.list.item_height
		return mx >= list.x + (parent and parent.x or 0) and mx <= list.x + list.width + (parent and parent.x or 0) and
			 my >= list.y + (parent and parent.y or 0) and my <= list.y + height + (parent and parent.y or 0)
	end,
}

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
	return number_of_items * floor(settings.list.item_height)
end

---@param hue integer [0, 360]
---@param saturation number [0, 1]
---@param value number [0, 1]
function Math.Hsv_to_RGB(hue, saturation, value)
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
	return floor((r1 + m) * 255), floor((g1 + m) * 255), floor((b1 + m) * 255)
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
	return misc.MouseInsideModes.ROUND_BUTTON(parent, round_button)
end

--- use isMouseInside! This is deprecated and can stop working or be removed at any time
---@deprecated
---@param parent table<string, any>?
---@param list table
---@param index integer
---@nodiscard
---@return boolean
function Math.isMouseInsideItem(parent, list, index)
	return misc.MouseInsideModes.ITEM(parent, list, index)
end

--- use isMouseInside! This is deprecated and can stop working or be removed at any time
---@deprecated
---@param parent table?
---@param list table
---@nodiscard
---@return boolean
function Math.isMouseInsideList(parent, list)
	return Math.isMouseInside(parent, list, "LIST")
	--return misc.MouseInsideModes.LIST(parent, list)
end

--- \\ END OF DEPRECATED STUFF

function Math.Time2Ticks(seconds)
	return seconds * 66.67
end

do
	local big_font, version_font
	local screenW, screenH
	local centerX, centerY

	local alibW, alibH
	local alibX, alibY

	local versionW

	--- logo variables
	local color = {}
	local color_variants = { { 255, 255, 255, 255 }, { 60, 60, 60, 255 } }
	local chosen_text_color = color_variants[random(1, #color_variants)]
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
		big_font = CreateFont("TF2 BUILD", 128, 1000)
		version_font = CreateFont("TF2 BUILD", 24, 1000)
		screenW, screenH = GetScreenSize()
		centerX, centerY = floor(screenW / 2), floor(screenH / 2)

		SetFont(big_font)
		alibW, alibH = GetTextSize("ALIB")
		alibX, alibY = centerX - floor(alibW / 2), centerY - floor(alibH / 2)

		SetFont(version_font)
		versionW = GetTextSize(version)

		SetFont(settings.font)
		themeTW, themeTH = GetTextSize(themeTEXT)

		intro = intro_states.LOGO
		return true
	end

	local function intro_logo()
		local tick_count = globals.TickCount()
		if tick_count > last_tick then
			last_tick = tick_count + Math.Time2Ticks(0.01)

			degrees = degrees + 1
			if degrees >= 360 then
				intro = intro_states.LOGO_FINISHED
				return true
			end

			local r, g, b = Math.Hsv_to_RGB(degrees, 1, 1)
			r, g, b = floor(r), floor(g), floor(b)
			color = { r, g, b, 255 }
		end

		change_color(color)
		shapes.triangle(alibX + 64, alibY + floor(alibH / 2) + 64, 128)

		SetFont(big_font)
		change_color(color)
		Text(alibX + 2, alibY + 2, "ALIB")

		change_color(chosen_text_color)
		Text(alibX, alibY, "ALIB")

		change_color({ 255, 255, 255, 255 })
		SetFont(version_font)
		TextShadow(alibX - floor(versionW / 2) + floor(alibW / 2), alibY + floor(alibH), version)
	end

	local function intro_logo_finished()
		EnumerateDirectory("alib/themes/*.json", function(filename, attributes)
			files[#files + 1] = filename
			files_without_extension[#files_without_extension + 1] = filename:sub(1, #filename - 5)
		end)

		if #files > 1 then
			theme_window.width = floor(themeTW) + 5
			theme_window.height = Math.GetListHeight(#files) + 85
			theme_window.x = centerX - floor(theme_window.width / 2)
			theme_window.y = centerY - floor(theme_window.height / 2)

			load_button.width = 100
			load_button.height = 30
			load_button.x = theme_window.x + floor(theme_window.width / 2) - load_button.width
			load_button.y = theme_window.y + theme_window.height - 33

			close_button.width = 100
			close_button.height = 30
			close_button.x = load_button.x + load_button.width + 4
			close_button.y = load_button.y

			themeTX = theme_window.x + floor(theme_window.width / 2) - floor(themeTW / 2)
			themeTY = theme_window.y + floor(themeTH) + 2

			list.width = theme_window.width
			list.x = theme_window.x + floor(theme_window.width / 2) - floor(list.width / 2)
			list.y = themeTY + floor(themeTH) + 10

			intro = intro_states.THEME_SELECTOR
			return true
		end

		intro = intro_states.FINISHED
	end

	local function intro_theme_selector()
		SetMouseInputEnabled(true)
		local load_mouse_inside = Math.isMouseInside(nil, load_button)
		local close_mouse_inside = Math.isMouseInside(nil, close_button)

		local state, tick = input.IsButtonPressed(E_ButtonCode.MOUSE_LEFT)
		if state and tick ~= last_tick then
			last_tick = tick
			for i, v in ipairs(files) do
				local mouse_inside = Math.isMouseInside(nil, list, "ITEM", i)
				if mouse_inside and IsButtonDown(E_ButtonCode.MOUSE_LEFT) then
					selected_file = i
				end
			end

			if load_mouse_inside then
				if files[selected_file] then
					load_settings(files[selected_file])
					_G["alib settings"] = settings
				end
			elseif close_mouse_inside then
				SetMouseInputEnabled(false)
				intro = intro_states.FINISHED
				return
			end
		end

		objects.window(theme_window.width, theme_window.height, theme_window.x, theme_window.y, "theme selector")
		objects.list(list.width, list.x, list.y, selected_file, files_without_extension)
		objects.buttonfade(load_mouse_inside, load_button.width, load_button.height, load_button.x, load_button.y, 255, 50,
			false,
			"load")
		objects.buttonfade(close_mouse_inside, close_button.width, close_button.height, close_button.x, close_button.y, 255,
			50, false, "close")

		TextShadow(themeTX, themeTY, themeTEXT)
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
		Unregister("Draw", "alib intro draw")
	end

	Register("Draw", "alib intro draw", function()
		if intro == intro_states.START then
			intro_start()
		elseif intro == intro_states.LOGO then
			intro_logo()
		elseif intro == intro_states.LOGO_FINISHED then
			intro_logo_finished()
		elseif intro == intro_states.THEME_SELECTOR then
			intro_theme_selector()
		elseif intro == intro_states.FINISHED then
			intro_finished()
		end
	end)
end

local function unload()
	local mem_before = collectgarbage("count")

	Unregister("Draw", "alib unstable version")
	Unregister("Draw", "alib intro draw")

	-- Clean up package cache
	package.loaded["alib"] = nil
	package.loaded["source"] = nil
	_G["alib settings"] = nil
	settings = nil

	-- Force garbage collection
	collectgarbage("collect")
	local mem_after = collectgarbage("count")

	local cleaned = tostring(mem_before - mem_after)
	local cleaned_in_MB = string.sub(cleaned, 1, 2)

	print("Unloaded alib")
	print("Collected " .. cleaned_in_MB .. " MB of used memory")
end

local alib = {
	settings = settings,
	objects = objects,
	shapes = shapes,
	math = Math,
	misc = misc,
	unload = unload,
}
package.loaded.alib = alib

printc(50, 255, 150, 255, "Alib " .. version .. " has loaded!")
return alib
