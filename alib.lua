local version = "372"

local stable_version = http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/stable_version")
if stable_version > version then
	printc(255, 100, 100, 255, "Your version of alib is outdated! Please update to " .. stable_version)
	return
elseif stable_version < version then
	printc(235, 198, 52, 255, "You're running a unstable version of alib!", "Things can be broken or not working!")
end

local settings = {
	font = 0,
	window = {
		background = {40, 40, 40, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
	},
	button = {
		background = {102, 255, 255, 255},
		selected = {150, 255, 150, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		text_color = {255, 255, 255, 255},
		round = false,
	},
	checkbox = {
		background = {20, 20, 20, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		checked_color = {150, 255, 150, 255},
		not_checked_color = {255, 150, 150, 255}
	},
	slider = {
		background = {20, 20, 29, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		bar_color = {102, 255, 255, 255},
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

---This renders a window
---@param width integer
---@param height integer
---@param x integer
---@param y integer
function objects.window(width, height, x, y)
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
	
	local color = mouse_inside and settings.button.selected or settings.button.background

	--- background
	change_color(color)
	shapes.rectangle(width, height, x, y, true)

	if settings.button.round then
		local radius = math.floor(height/2)

		--- side circles
		change_color(color)
		shapes.filledcircle(x, y + math.ceil(height/2), radius) -- left circle
		shapes.filledcircle(x + width, y + math.ceil(height/2), radius) -- right circle
	else
		--- normal outline
		change_color(settings.button.outline.color)
		draw_outline(width, height, x, y, settings.button.outline.thickness)
	end

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
	--- background
	change_color(settings.slider.background)
	shapes.rectangle(width, height, x, y, true)

	--- outline
	change_color(settings.slider.outline.color)
	draw_outline(width, height, x, y, settings.slider.outline.thickness)

	--- slider bar
	change_color(settings.slider.bar_color)
	local percentage = (value - min) / (max - min)
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

--- checks if mouse is inside or not the object
---@param parent table<string, any>?
---@param object table<string, any>
function Math.isMouseInside(parent, object)
	local mousePos = input.GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= object.x + (parent and parent.x or 0) and mx <= object.x + object.width + (parent and parent.x or 0) and my >= object.y + (parent and parent.y or 0) and my <= object.y + object.height + (parent and parent.y or 0)
end

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
	settings, objects, shapes, Math = nil, nil, nil, nil
	
	--- find file path
	local file_path = GetScriptName() -- i dont know why it doesnt just return the name but thanks for the extra effort!

	--- get the name without all the other junk
	local name = string.match(file_path, "([^/\\]+)$")

	--- get the extension name (.lua, .txt, etc)
	local extension = string.match(name, "%.([^.]+)$")

	--- remove the extension
	name = string.gsub(name, "%." .. extension, "")

	printc(102, 255, 255, 255, "Unloading " .. name)

	--- unalive the loaded module
	package.loaded[name] = nil

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

printc(150, 255, 150, 255, "Alib has loaded!")

return alib