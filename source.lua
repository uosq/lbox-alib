local version = "0.40"
local save_settings = true

local settings = {
	font = draw.CreateFont("Arial", 12, 1000),
	window = {
		background = {40, 40, 40, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		shadow = {offset = 3, color = {0, 0 , 0, 200}},
		title = {
			height = 20, background = {50, 131, 168, 255}, text_color = {255, 255, 255, 255}, text_shadow = false,
			fade = {enabled = false, horizontal = true, alpha_start = 255, alpha_end = 20}
		}
	},
	button = {
		background = {102, 255, 255, 255},
		selected = {150, 255, 150, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		shadow = {text = true, offset = 2, color = {0, 0 , 0, 200}},
		text_color = {255, 255, 255, 255},
		round = false,
	},
	checkbox = {
		background = {20, 20, 20, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		checked_color = {150, 255, 150, 255},
		not_checked_color = {255, 150, 150, 255},
		shadow = {offset = 2, color = {0, 0 , 0, 200}},
	},
	slider = {
		background = {20, 20, 20, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		bar_color = {102, 255, 255, 255},
		bar_outlined = false,
		shadow = {offset = 2, color = {0, 0 , 0, 200}},
	},
	list = {
		background = {20, 20, 20, 255},
		selected = {102, 255, 255, 255},
		outline = {thickness = 1, color = {255, 255, 255, 255}},
		shadow = {offset = 3, color = {0, 0, 0, 200}},
		item_height = 20,
		text_color = {255, 255, 255, 255},
	},
}

--[[
local defaultsettings = settings

local jsonlib = http.Get("https://raw.githubusercontent.com/rxi/json.lua/refs/heads/master/json.lua")
---@type {(encode: fun(param: table):string), (decode: fun(json_string: string):table)}
local json = load(jsonlib)()

local function create_default_config(filename)
	filesystem.CreateDirectory("alib/themes")
	local encoded = json.encode(defaultsettings)
	io.output("alib/themes/"..filename..".json")
	io.write(encoded)
	io.flush()
	io.close()
end

--- create default config just in case its not made or outdated
create_default_config("default")]]
filesystem.CreateDirectory("alib")
local saved_settings = io.open("alib/settings.json")
if saved_settings then
	local json_lib = http.Get("https://raw.githubusercontent.com/rxi/json.lua/refs/heads/master/json.lua")
	---@type {(encode: fun(param: table):string), (decode: fun(json_string: string):table)}
	local json = load(json_lib)()
	local data = json.decode(saved_settings:read("a"))
	for k,v in pairs(data) do
		settings[k] = v
	end
	---@diagnostic disable-next-line: cast-local-type
	json = nil
	---@diagnostic disable-next-line: cast-local-type
	json_lib = nil
	printc(233, 245, 66, 255, "Settings loaded!")
end

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
		shapes.circle(x, y, i, 63)
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
---@param title string?
function objects.window(width, height, x, y, title)
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
	if title then
		--- shadow
		change_color(settings.window.shadow.color)
		draw_shadow(width, height + settings.window.title.height, x, y - settings.window.title.height, settings.window.shadow.offset)

		change_color(settings.window.title.background)
		if settings.window.title.fade.enabled then
			shapes.rectanglefade(width, settings.window.title.height, x, y - settings.window.title.height, settings.window.title.fade.alpha_start, settings.window.title.fade.alpha_end, settings.window.title.fade.horizontal)
		else
			shapes.rectangle(width, settings.window.title.height, x, y - settings.window.title.height, true)
		end

		draw.SetFont(settings.font)
		local textwidth, textheight = draw.GetTextSize(title)
		change_color(settings.window.title.text_color)
		if settings.window.title.text_shadow then
			draw.TextShadow(x + math.floor(width/2) - math.floor(textwidth/2), y - math.floor(settings.window.title.height/2) - math.floor(textheight/2), title)
		else
			draw.Text(x + math.floor(width/2) - math.floor(textwidth/2), y - math.floor(settings.window.title.height/2) - math.floor(textheight/2), title)
		end

		change_color(settings.window.outline.color)
		draw_outline(math.floor(width) + 1, height + settings.window.title.height + 1, x, y - settings.window.title.height, settings.window.outline.thickness)
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
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
	if title then
		--- shadow
		change_color(settings.window.shadow.color)
		draw_shadow(width, height + settings.window.title.height, x, y - settings.window.title.height, settings.window.shadow.offset)

		change_color(settings.window.title.background)
		if settings.window.title.fade.enabled then
			shapes.rectanglefade(width, settings.window.title.height, x, y - settings.window.title.height, settings.window.title.fade.alpha_start, settings.window.title.fade.alpha_end, settings.window.title.fade.horizontal)
		else
			shapes.rectangle(width, settings.window.title.height, x, y - settings.window.title.height, true)
		end

		draw.SetFont(settings.font)
		local textwidth, textheight = draw.GetTextSize(title)
		change_color(settings.window.title.text_color)
		if settings.window.title.text_shadow then
			draw.TextShadow(x + math.floor(width/2) - math.floor(textwidth/2), y - math.floor(settings.window.title.height/2) - math.floor(textheight/2), title)
		else
			draw.Text(x + math.floor(width/2) - math.floor(textwidth/2), y - math.floor(settings.window.title.height/2) - math.floor(textheight/2), title)
		end

		change_color(settings.window.outline.color)
		draw_outline(width + 1, height + settings.window.title.height + 1, x, y - settings.window.title.height, settings.window.outline.thickness)
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
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
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
		draw_outline(width + 1, height + 1, x, y, settings.button.outline.thickness)
	end

	--- background
	change_color(color)
	shapes.rectangle(width, height, x, y, true)
	
	--- text
	if text and #text > 0 then
		draw.SetFont(settings.font)
		local textwidth, textheight = draw.GetTextSize(text)
		change_color(settings.button.text_color)
		if settings.button.shadow.text then
			draw.TextShadow(x + math.floor(width/2) - math.floor(textwidth/2), y + height/2 - math.floor(textheight/2), text)
		else
			draw.Text(x + math.floor(width/2) - math.floor(textwidth/2), y + height/2 - math.floor(textheight/2), text)
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
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
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
		draw.SetFont(settings.font)
		local textwidth, textheight = draw.GetTextSize(text)
		change_color(settings.button.text_color)
		if settings.button.shadow.text then
			draw.TextShadow(x + width/2 - math.floor(textwidth/2), y + height/2 - math.floor(textheight/2), text)
		else
			draw.Text(x + width/2 - math.floor(textwidth/2), y + height/2 - math.floor(textheight/2), text)
		end
	end
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param checked boolean
function objects.checkbox(width, height, x, y, checked)
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
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
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
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
		shapes.rectangle(math.floor(width * percentage) - 1, height - 1, x, y, false)
	else
		shapes.rectangle(math.floor(width * percentage) - 1, height - 1, x, y, true)
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
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
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
	shapes.rectanglefade(math.floor(width * percentage) - 1, height - 1, x, y, alpha_start, alpha_end, horizontal)
end

---@param width integer
---@param x integer
---@param y integer
---@param selected_item_index integer starts at 0
---@param items table<integer, string>
function objects.list(width, x, y, selected_item_index, items)
	width = math.floor(width); x = math.floor(x); y = math.floor(y)
	local height = #items * math.floor(settings.list.item_height)

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

		draw.SetFont(settings.font)
		local textwidth, textheight = draw.GetTextSize(item)
		change_color(settings.list.text_color)
		draw.Text(x + width/2 - math.floor(textwidth/2), y + math.floor(textheight/2), item)
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
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   change_color(settings.slider.shadow.color)
   draw_shadow(width, height, x, y, settings.slider.shadow.offset)

   --- background
   change_color(settings.slider.background)
   shapes.rectangle(width, height, x, y, true)

   --- slider bar
   local percentage = (value - min) / (max - min)
   local bar_height = math.floor(height * percentage)
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
	width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   change_color(settings.slider.shadow.color)
   draw_shadow(width, height, x, y, settings.slider.shadow.offset)

   --- background
   change_color(settings.slider.background)
   shapes.rectangle(width, height, x, y, true)

   --- slider bar
   change_color(settings.slider.bar_color)
   local percentage = (value - min) / (max - min)
   local bar_height = math.floor(height * percentage)

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
	local mousePos = input.GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= object.x + (parent and parent.x or 0) and mx <= object.x + object.width + (parent and parent.x or 0) and my >= object.y + (parent and parent.y or 0) and my <= object.y + object.height + (parent and parent.y or 0)
end

--- special isMouseInside for round buttons as we dont know if the object is round or not
---@param parent table<string, any>
---@param round_button table<string, any>
---@nodiscard
---@return boolean
function Math.isMouseInsideRoundButton(parent, round_button)
	local mousePos = input.GetMousePos()
	local mx, my = mousePos[1], mousePos[2]
	return mx >= round_button.x + parent.x - math.floor(round_button.height/2) and mx <= round_button.x + round_button.width + parent.x + math.floor(round_button.height/2) and my >= round_button.y + parent.y and my <= round_button.y + round_button.height + parent.y
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
	local new_value = Math.clamp(min + ((initial_mouse_pos/slider.width) * (max - min)), min, max)
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

---@param parent table<string, any>?
---@param list table
---@param index integer
---@nodiscard
---@return boolean
function Math.isMouseInsideItem(parent, list, index)
   parent = parent or {x = 0, y = 0}
   local height = settings.list.item_height
   local y = parent.y + list.y + ((index - 1) * settings.list.item_height)

   local mousePos = input.GetMousePos()
   local mx, my = mousePos[1], mousePos[2]
   return mx >= list.x + parent.x and mx <= list.x + list.width + parent.x and my >= y and my <= y + height
end

---@param parent table?
---@param list table
---@nodiscard
---@return boolean
function Math.isMouseInsideList(parent, list)
	local mousePos = input.GetMousePos()
   local mx, my = mousePos[1], mousePos[2]
	local height = #list.items * settings.list.item_height
	return mx >= list.x + (parent and parent.x or 0) and mx <= list.x + list.width + (parent and parent.x or 0) and my >= list.y + (parent and parent.y or 0) and my <= list.y + height + (parent and parent.y or 0)
end

---@nodiscard
---@return integer
function Math.GetSliderPercentage(slider)
	return (slider.value - slider.min) / (slider.max - slider.min)
end

---@return integer
---@nodiscard
function Math.GetListHeight(number_of_items)
	return number_of_items * math.floor(settings.list.item_height)
end

---not used for now anywhere in the lib, but nice to have i guess
---oh yeah i didnt test this so you should probably math.floor or math.ceil the values it returns
function Math.HSV_TO_RGB(hue, saturation, value)
	local chroma = value * saturation;
	local hue1 = hue / 60;
	local x = chroma * (1 - math.abs((hue1 % 2) - 1));
	local r1, g1, b1;
	if (hue1 >= 0 and hue1 <= 1) then
	  r1, g1, b1 = chroma, x, 0
	elseif (hue1 >= 1 and hue1 <= 2) then
		r1, g1, b1 = x, chroma, 0
	elseif (hue1 >= 2 and hue1 <= 3) then
		r1, g1, b1 = 0, chroma, x
	elseif (hue1 >= 3 and hue1 <= 4) then
		r1, g1, b1 = 0, x, chroma
	elseif (hue1 >= 4 and hue1 <= 5) then
		r1, g1, b1 = x, 0, chroma
	elseif (hue1 >= 5 and hue1 <= 6) then
		r1, g1, b1 = chroma, 0, x
	end

	local m = value - chroma;
	local r,g,b = r1+m, g1+m, b1+m

	--Change r,g,b values from [0,1] to [0,255]
	return 255*r, 255*g, 255*b
end

local function unload()
	if save_settings then
		printc(102, 50, 50, 255, "Saving settings")
		local json_lib = http.Get("https://raw.githubusercontent.com/rxi/json.lua/refs/heads/master/json.lua")
		if json_lib then
			---@type {(encode: fun(param: table):string), (decode: fun(json_string: string):table)}
			local json = load(json_lib)()
			local localsettings = settings
			localsettings.font = nil
			local encoded_settings = json.encode(localsettings)

			filesystem.CreateDirectory("alib")
			io.output("alib/settings.json")
			io.write(encoded_settings)
			io.flush()
			io.close()

			---@diagnostic disable-next-line: cast-local-type
			json = nil -- unload it as its not needed anymore and will get collected by GC
		end

		---@diagnostic disable-next-line: cast-local-type
		json_lib = nil -- unload it as its not used anymore and will get collected by GC
	end

	printc(102, 255, 255, 255, "Unloading alib")

	printc(150, 255, 150, 255, "Unloaded alib successfully!")

	local mem_before = collectgarbage("count")
	collectgarbage()
	print("Garbage hopefully collected!")
	local mem_after = collectgarbage("count")
	printc(50, 255, 50, 255, "Collected " .. math.floor(math.abs(mem_before - mem_after)) .. " KB") -- i think its Kib, but on official Lua 5.4 docs is Kbyte so i'll go with that

	--- unalive the loaded module
	package.loaded["alib"] = nil
	--- in case its loaded we unalive source.lua too
	package.loaded["source"] = nil
end

local alib = {
	unload = unload,
	settings = settings,
	objects = objects,
	shapes = shapes,
	math = Math,
}

printc(50, 255, 150, 255, "Alib " .. version .. " has loaded!", "You can change alib settings by editing alib.lua on tf2 directory/alib/alib.lua")

--- TODO for 0.4X or 0.50 (probably 0.4 something):
--- + add a window to change every entry on the settings table
--- + make config system with multiple configs

return alib