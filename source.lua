local version = "0.38.3"

local settings = {
	font = 0,
	window = {
		background = {40, 40, 40, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		shadow = {offset = 3, color = {0, 0 , 0, 200}}
	},
	button = {
		background = {102, 255, 255, 255},
		selected = {150, 255, 150, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		shadow = {offset = 2, color = {0, 0 , 0, 200}},
		text_color = {255, 255, 255, 255},
		round = true,
	},
	checkbox = {
		background = {20, 20, 20, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		checked_color = {150, 255, 150, 255},
		not_checked_color = {255, 150, 150, 255},
		shadow = {offset = 2, color = {0, 0 , 0, 200}},
	},
	slider = {
		background = {20, 20, 29, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		bar_color = {102, 255, 255, 255},
		shadow = {offset = 2, color = {0, 0 , 0, 200}},
	},
}

local function change_color(color)
	draw.Color(color[1], color[2], color[3], color[4])
end

local shapes = {}

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
	--- i wish there was a filled circle already :(
	--- would probably be faster if it was in C
	for i = 1, radius do
		draw.OutlinedCircle(x, y, i, 63)
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
function shapes.faderectangle(width, height, x, y, alpha_start, alpha_end, horizontal)
	draw.FilledRectFade(x, y, x + width, y + height, alpha_start, alpha_end, horizontal)
	return true
end

--- tbh i dont know why someone would use this but ok?
function shapes.triangle(x, y, size)
	draw.Line(x, y, x + size, y)
	draw.Line(x + math.floor(size/2), y - size, x + size, y)
	draw.Line(x + math.floor(size/2), y - size, x, y)
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
	for i = 1, thickness do
		shapes.rectangle(width + (1 * i), height + (1 * i), x - (1 * i), y - (1 * i), false)
	end
	return true
end

local function draw_shadow(width, height, x, y, offset)
	if offset == 0 then return true end
	shapes.rectangle(width, height, x + offset, y + offset, true)
	return true
end

---This renders a window
---@param width integer
---@param height integer
---@param x integer
---@param y integer
function objects.window(width, height, x, y)
	--- shadow
	change_color(settings.window.shadow.color)
	draw_shadow(width, height, x, y, settings.window.shadow.offset)

	--- background
	change_color(settings.window.background)
	shapes.rectangle(width, height, x, y, true)

	--- outline
	change_color(settings.window.outline.color)
	draw_outline(width, height, x, y, settings.window.outline.thickness)
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param alpha_start integer [0, 255]
---@param alpha_end integer [0, 255]
---@param horizontal boolean? default = true
function objects.windowfade(width, height, x, y, alpha_start, alpha_end, horizontal)
	--- shadow
	change_color(settings.window.shadow.color)
	draw_shadow(width, height, x, y, settings.window.shadow.offset)

	--- background
	change_color(settings.window.background)
	shapes.faderectangle(width, height, x, y, alpha_start, alpha_end, horizontal)

	--- outline
	change_color(settings.window.outline.color)
	draw_outline(width, height, x, y, settings.window.outline.thickness)
end

--- unfortunately if buttons are round we dont have outlines (im too lazy to make them :troll:)
---@param mouse_inside boolean
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param text string?
function objects.button(mouse_inside, width, height, x, y, text)
	--- shadow
	if not settings.button.round then
		change_color(settings.button.shadow.color)
		draw_shadow(width, height, x, y, settings.button.shadow.offset)
	end

	local color = mouse_inside and settings.button.selected or settings.button.background
	
	if settings.button.round then
		local radius = math.floor(height/2)

		if settings.button.shadow.offset > 0 then
			--- oh boy these shadows will be EXPENSIVE
			local offset = settings.button.shadow.offset
			change_color(settings.button.shadow.color)
			draw_shadow(width, height, x, y, offset)
			
			change_color(settings.button.shadow.color)
			shapes.filledcircle(x + offset, y + math.ceil(height/2) + offset, radius) -- left circle
			shapes.filledcircle(x + width + offset, y + math.ceil(height/2) + offset, radius) -- right circle
		end

		--- side circles
		change_color(color)
		shapes.filledcircle(x, y + math.ceil(height/2), radius) -- left circle
		shapes.filledcircle(x + width, y + math.ceil(height/2), radius) -- right circle
	else
		--- normal outline
		change_color(settings.button.outline.color)
		draw_outline(width, height, x, y, settings.button.outline.thickness)
	end

	--- background
	change_color(color)
	shapes.rectangle(width, height, x, y, true)


	--- text
	if text and #text > 0 then
		draw.SetFont(settings.font)
		local textwidth, textheight = draw.GetTextSize(text)
		change_color(settings.button.text_color)
		draw.Text(x + width/2 - math.floor(textwidth/2), y + height/2 - math.floor(textheight/2), text)
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
	--- shadow
	change_color(settings.button.shadow.color)
	draw_shadow(width, height, x, y, settings.button.shadow.offset)

	--- background
	local color = mouse_inside and settings.button.selected or settings.button.background

	--- background
	change_color(color)
	shapes.faderectangle(width, height, x, y, alpha_start, alpha_end, horizontal)
	
	--- outline
	change_color(settings.button.outline.color)
	draw_outline(width, height, x, y, settings.button.outline.thickness)

	--- text
	if text and #text > 0 then
		draw.SetFont(settings.font)
		local textwidth, textheight = draw.GetTextSize(text)
		change_color(settings.button.text_color)
		draw.Text(x + width/2 - math.floor(textwidth/2), y + height/2 - math.floor(textheight/2), text)
	end
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param checked boolean
function objects.checkbox(width, height, x, y, checked)
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
	shapes.rectangle(math.floor(width * percentage) - 1, height - 1, x, y, true)
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
	shapes.faderectangle(math.floor(width * percentage) - 1, height - 1, x, y, alpha_start, alpha_end, horizontal)
end

--- math is hard
local Math = {}

--- clamps the number between min and max
---@param number number
---@param min number
---@param max number
function Math.clamp(number, min, max)
	number = (number < min and min or number)
	number = (number > max and max or number)
	return number
end

--- checks if mouse is inside or not the object \
--- use isMouseInsideRoundButton if alib.settings.button.round is true
---@param parent table<string, any>?
---@param object table<string, any>
function Math.isMouseInside(parent, object)
	local mousePos = input.GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= object.x + (parent and parent.x or 0) and mx <= object.x + object.width + (parent and parent.x or 0) and my >= object.y + (parent and parent.y or 0) and my <= object.y + object.height + (parent and parent.y or 0)
end

--- special isMouseInside for round buttons as we dont know if the object is round or not
function Math.isMouseInsideRoundButton(parent, round_button)
	local mousePos = input.GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= round_button.x + parent.x - math.floor(round_button.height/2) and mx <= round_button.x + round_button.width + parent.x + math.floor(round_button.height/2) and my >= round_button.y + parent.y and my <= round_button.y + round_button.height + parent.y
end

--- calculates the new slider value so you dont have to do math
---@param slider table<string, any>
---@param min integer
---@param max integer
function Math.GetNewSliderValue(window, slider, min, max)
	local mx = input.GetMousePos()[1]
	local initial_mouse_pos = mx - (slider.x + window.x)
	local new_value = Math.clamp(min + ((initial_mouse_pos/slider.width) * (max - min)), min, max)
	return new_value
end

local function unload()
	printc(102, 255, 255, 255, "Unloading alib")

	--- unalive the loaded module
	package.loaded["alib"] = nil

	printc(150, 255, 150, 255, "Unloaded alib successfully!")
	collectgarbage()
	print("Garbage hopefully collected!")
end

local alib = {
	unload = unload,
	settings = settings,
	objects = objects,
	shapes = shapes,
	math = Math
}

printc(150, 255, 150, 255, "Alib " .. version .. " has loaded!", "You can change alib settings by editing alib.lua on tf2 directory/alib/alib.lua")

return alib