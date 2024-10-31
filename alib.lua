local get_mouse_pos = input.GetMousePos
local buttondown = input.IsButtonDown

local unregister = callbacks.Unregister
local register = callbacks.Register

local draw_color = draw.Color
local draw_text = draw.Text
local draw_create_font = draw.CreateFont
local draw_set_font = draw.SetFont
local draw_filledrect = draw.FilledRect
local draw_outlinedrect = draw.OutlinedRect
local draw_textsize = draw.GetTextSize
local draw_coloredcircle = draw.ColoredCircle
local draw_line = draw.Line

local is_taking_screenshot = engine.IsTakingScreenshot
local is_game_ui_visible = engine.IsGameUIVisible

local getvalue = gui.GetValue
local setvalue = gui.SetValue

local format = string.format
local load = load
local tostring = tostring
local package = package

local floor = math.floor
local ceil = math.ceil

local table_remove = table.remove
local table_insert = table.insert
local table_concat = table.concat

local printc = printc
local print = print
local warn = warn
local error = error
local xpcall = xpcall
local pcall = pcall

local function unload()
	unregister("Draw", "mouse_manager")
	unregister("Draw", "combbuttons_manager")
	package.loaded.alib = nil
	if package.loaded.console then
		package.loaded.console = nil
	else
		unregister("SendStringCmd", "console_lib")
	end
end

local function is_mouse_inside(object)
   local mousePos = get_mouse_pos()
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

---@param font Font
---@param x number
---@param y number
---@param text string
local function draw_colored_text(color, font, x, y, text)
	draw_color(color.r, color.g, color.b, color.opacity)
	draw_set_font(font)
	draw_text(x, y, text)
end

---@param font string
local function create_font(font, font_size)
	return draw_create_font(font, font_size, 1000)
end

---@param theme_select RGB
local function change_color(theme_select)
	draw_color(theme_select.r, theme_select.g, theme_select.b, theme_select.opacity)
end

---@param red number
---@param green number
---@param blue number
---@param opacity number
---@return RGB
local function rgb(red, green, blue, opacity)
	return {
		r = clamp(red, 0, 255),
		g = clamp(green, 0, 255),
		b = clamp(blue, 0, 255),
		opacity = clamp(opacity, 0, 255)
	}
end

---@param font string
---@param background_color RGB
---@param text_color RGB
---@param outline_color RGB
---@param outline_thickness number
---@param font_size number
---@return Theme
local function create_theme(font, font_size, background_color, selected_color, text_color, outline_color, outline_thickness)
	return {
		background_color = background_color,
		selected_color = selected_color,
		text_color = text_color,
		outline_color = outline_color,
		outline_thickness = outline_thickness,
		font = create_font(font, font_size),
		font_size = font_size
	}
end

---@param name string
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme Theme
---@return Window
local function create_window (name, x, y, width, height, theme)
	return {
		name = name,
		x = x, y = y, width = width, height = height,
		theme = theme,
		enabled = true,
		children = {},
		type = "window",
	}
end

---@param window Window
local function render_window(window)
	if window.enabled == false or (getvalue("clean screenshots") == 1
	and is_taking_screenshot()) then return end
	change_color(window.theme.background_color)
	draw_filledrect(window.x, window.y , window.x + window.width, window.y + window.height)
	change_color(window.theme.outline_color)
	for i = 1, window.theme.outline_thickness do
		draw_outlinedrect(window.x - 1 * i, window.y - 1 * i, window.x + window.width + 1 * i, window.y + window.height + 1 * i)
	end
end

---@param window Window
---@deprecated
---this is useless why did i do this wtf
local function window_getchildren(window)
	local children = {}
	for i = 1, #window.children do
		children[#children+1] = window.children[i]
	end
	return children
end

---@param window Window
local function window_init(window)
	unregister("Draw", "mouse_manager")
	register("Draw", "mouse_manager", function()
		for k,v in pairs(window.children) do
			local state, tick = buttondown(MOUSE_LEFT)
			if v.enabled and v.selectable and is_mouse_inside(v) and state and tick ~= v.last_clicked_tick and v.click then
				v.click(v)
			end
			v.last_clicked_tick = tick
		end
	end)
end

---@param name string
---@param text string
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme Theme
---@param parent Window
---@param click function
---@return Button
local function create_button(name, text, x, y, width, height, theme, parent, click)
	local button = {
		name = name, text = text,
		x = parent.x + x, y = parent.y + y, width = width, height = height,
		theme = theme,
		parent = parent,
		enabled = true, selectable = true,
		click = click,
		last_clicked_tick = nil,
		type = "button",
	}
	parent.children[#parent.children+1] = button
	return button
end

---@param button Button
local function render_button (button)
	if button.enabled == false or (getvalue("clean screenshots") == 1
	and is_taking_screenshot()) then return end

	if is_mouse_inside(button) then
		change_color(button.theme.selected_color)
	else
		change_color(button.theme.background_color)
	end
	draw_filledrect(button.x, button.y, button.x + button.width, button.y + button.height)

	draw_set_font(button.theme.font)
	change_color(button.theme.text_color)
	local tx, ty = draw_textsize(button.text)
	draw_text( button.x + button.width/2 - floor(tx/2), button.y + button.height/2 - floor(ty/2), button.text )

	for i = 1, button.theme.outline_thickness do
		draw_outlinedrect(button.x - 1 * i, button.y - 1 * i, button.x + button.width + 1 * i, button.y + button.height + 1 * i)
	end
end

---@param name string
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme Theme
---@param parent Window
---@param min number
---@param max number
---@param value number
---@return Slider
local function create_slider(name, x, y, width, height, theme, parent, min, max, value)
	local slider = {
		name = name,
		x = parent.x + x, y = parent.y + y, width = width, height = height,
		theme = theme,
		parent = parent,
		min = min, max = max, value = value, percent = (value - min) / max - min,
		last_clicked_tick = nil,
		selectable = true,
		enabled = true,
		type = "slider"
	}
	slider.click = function()
		callbacks.Register("Draw", "sliderclicks", function()
			if buttondown(MOUSE_LEFT) and is_mouse_inside(slider) and slider.selectable and slider.enabled then
				local mx = get_mouse_pos()[1]
				local initial_mouse_pos = mx - slider.x
				local new_value = clamp(slider.min + ((initial_mouse_pos/slider.width) * (slider.max - slider.min)), slider.min, slider.max)
				slider.value = new_value
				slider.percent = (new_value - slider.min) / slider.max - slider.min
			else
				unregister( "Draw", "sliderclicks" )
			end
		end)
	end

	parent.children[#parent.children+1] = slider
	return slider
end

---@param slider Slider
local function render_slider(slider)
	if slider.enabled == false or (getvalue("clean screenshots") == 1
	and is_taking_screenshot()) then return end

	change_color(slider.theme.outline_color)
	for i = 1, slider.theme.outline_thickness do
		draw_outlinedrect(slider.x - 1 * i, slider.y - 1 * i, slider.x + slider.width + 1 * i, slider.y + slider.height + 1 * i)
	end

	change_color(slider.theme.background_color)
	draw_filledrect(slider.x, slider.y, slider.x + slider.width, slider.y + slider.height)

	change_color(slider.theme.selected_color)

---@diagnostic disable-next-line: invisible
	draw_filledrect(slider.x, slider.y, slider.x + slider.width * slider.percent, slider.y + slider.height)
end

---@param name string
---@param x number
---@param y number
---@param size number
---@param theme Theme
---@param parent Window
---@param click function
---@return Checkbox
---it uses selected_color as the color used when checked and text_color as unchecked
local function create_checkbox(name, x, y, size, theme, parent, click)
	local checkbox = {
		name = name,
		x = parent.x + x, y = parent.y + y, width = 1 * size, height = 1 * size,
		theme = theme,
		parent = parent,
		enabled = true,
		selectable = true,
		checked = false,
		last_clicked_tick = nil,
		type = "checkbox",
	}
	checkbox.click = function ()
		checkbox.checked = not checkbox.checked
		click(checkbox)
	end
	parent.children[#parent.children+1] = checkbox
	return checkbox
end

---@param checkbox Checkbox
local function render_checkbox(checkbox)
	if checkbox.enabled == false or (getvalue("clean screenshots") == 1
	and is_taking_screenshot()) then return end

	change_color(checkbox.theme.background_color)
	for i = 1, checkbox.theme.outline_thickness do
		draw_outlinedrect(checkbox.x - 1 * i, checkbox.y - 1 * i, checkbox.x + checkbox.width + 1 * i, checkbox.y + checkbox.height + 1 * i)
	end

	if checkbox.checked then
		change_color(checkbox.theme.selected_color)
	else
		change_color(checkbox.theme.text_color)
	end
	draw_filledrect(checkbox.x, checkbox.y, checkbox.x + checkbox.width, checkbox.y + checkbox.height)
end

local function create_combobox_button(parent, index, item)
	local combobox_button = {
		parent = parent,
		height = parent.height,
		width = parent.width,
		index = index,
		item = item,
		x = parent.x,
		y = parent.y + (index * parent.height),
	}

	combobox_button.click = function()
		parent.selected_item = index
		parent.click()
	end

	return combobox_button
end

local function render_combobox_button(combobox_button)
	if not combobox_button.parent.displaying_items or (getvalue("clean screenshots") == 1
	and is_taking_screenshot()) then return end

	if is_mouse_inside(combobox_button) then
		change_color(combobox_button.parent.theme.selected_color)
	else
		change_color(combobox_button.parent.theme.background_color)
	end
	draw_filledrect(combobox_button.x, combobox_button.y, combobox_button.x + combobox_button.parent.width, combobox_button.y + combobox_button.height)

	change_color(combobox_button.parent.theme.outline_color)
	for i = 1, combobox_button.parent.theme.outline_thickness do
		draw_outlinedrect(combobox_button.x - 1 * i, combobox_button.y - 1 * i, combobox_button.x + combobox_button.width + 1 * i, combobox_button.y + combobox_button.height + 1 * i)
	end

	draw.SetFont(combobox_button.parent.theme.font)
	change_color(combobox_button.parent.theme.text_color)
	local tx, ty = draw_textsize(combobox_button.item)
	draw.Text(combobox_button.x + combobox_button.parent.width / 2 - floor(tx / 2), combobox_button.y + combobox_button.height / 2 - floor(ty / 2), combobox_button.item)
end

---@param name string
---@param parent Window
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme Theme
---@param items table
---@return Combobox
local function create_combobox(name, parent, x, y, width, height, theme, items)
	local combobox = {
		name = name,
		parent = parent,
		x = parent.x + x, y = parent.y + y, width = width, height = height,
		theme = theme,
		items = items,
		last_clicked_tick = nil,
		selected_item = 1,
		displaying_items = false, enabled = true, selectable = true,
		type = "combobox",
	}

	combobox.combbuttons = {}
	for k, v in ipairs(combobox.items) do
		combobox.combbuttons[k] = create_combobox_button(combobox, k, v)
	end

	combobox.click = function()
		combobox.displaying_items = not combobox.displaying_items
		for k, v in pairs(window_getchildren(combobox.parent)) do
			if v ~= combobox then
				v.selectable = not combobox.displaying_items
			end
		end
	end

	parent.children[#parent.children+1] = combobox
	return combobox
end

---@param combobox Combobox
local function render_combobox(combobox)
	if not combobox.enabled or (getvalue("clean screenshots") == 1
	and is_taking_screenshot()) then return end

	if is_mouse_inside(combobox) then
		change_color(combobox.theme.selected_color)
	else
		change_color(combobox.theme.background_color)
	end

	draw_filledrect(combobox.x, combobox.y, combobox.x + combobox.width, combobox.y + combobox.height)

	draw.SetFont(combobox.theme.font)
	change_color(combobox.theme.text_color)
	local tx, ty = draw_textsize(combobox.items[combobox.selected_item])
	draw.Text(combobox.x + combobox.width / 2 - floor(tx / 2), combobox.y + combobox.height / 2 - floor(ty / 2), tostring(combobox.items[combobox.selected_item]))

	for i = 1, combobox.theme.outline_thickness do
		draw_outlinedrect(combobox.x - 1 * i, combobox.y - 1 * i, combobox.x + combobox.width + 1 * i, combobox.y + combobox.height + 1 * i)
	end

	if combobox.displaying_items then
		for k, comboboxbutton in ipairs(combobox.combbuttons) do
			if comboboxbutton then
				render_combobox_button(comboboxbutton)
			end
		end
	end
end

---@param combobox Combobox
local function combobox_init(combobox)
	unregister("Draw", "combbuttons_manager")
	register("Draw", "combbuttons_manager", function()
		local state = buttondown(MOUSE_LEFT)
		for k,v in pairs(combobox.combbuttons) do
			if is_mouse_inside(v) and state and v.click and v.parent.displaying_items then
				v.click(v)
			end
		end
	end)
end

-- i wasn't planning on adding text like this, but it's for consistency
---@param color RGB
---@param x number
---@param y number
---@param text string
---@return Text
local function create_text(color, x, y, font, font_size, text)
	return {
		color = color,
		x = x,
		font = create_font(font, font_size),
		y = y,
		text = text
	}
end

---@param text Text
local function render_text(text)
	draw_colored_text(text.color, text.font, text.x, text.y, text.text)
end

---@param name string
---@param text string
---@param parent Window
---@param x number
---@param theme Theme
---@param y number
---@param width number
---@param height number
---@param click function
---@return Round_Button
local function create_round_button(name, text, theme, parent, x, y, width, height, click)
	local round_button = {
		name = tostring(name), text = tostring(text),
		parent = parent,
		x = parent.x + x, y = parent.y + y, width = width, height = height,
		last_clicked_tick = nil,
		selectable = true, enabled = true,
		theme = theme,
		click = click,
		type = "round_button"
	}

	parent.children[#parent.children+1] = round_button
	return round_button
end

---@param round_button Round_Button
local function render_round_button(round_button)
	-- Early exit if button is disabled or screenshot is in progress
	if not round_button.enabled or (getvalue("clean screenshots") == 1 and is_taking_screenshot()) then return end

	local color = is_mouse_inside(round_button) and round_button.theme.selected_color or round_button.theme.background_color
	change_color(color)

	for i = round_button.height, 0, -1 do
		--left v
		draw_coloredcircle(round_button.x + 3, round_button.y + ceil(round_button.height/2), floor(round_button.height/2) - 1 * i, color.r, color.g, color.b, color.opacity)
		-- right v
		draw_coloredcircle(round_button.x + round_button.width - 3, round_button.y + ceil(round_button.height/2), floor(round_button.height/2) - 1 * i, color.r, color.g, color.b, color.opacity)
	end

	--left v
	draw_coloredcircle(round_button.x + 3 - 1, round_button.y + ceil(round_button.height/2), floor(round_button.height/2), round_button.theme.outline_color.r, round_button.theme.outline_color.g, round_button.theme.outline_color.b, round_button.theme.outline_color.opacity)
	-- right v
	draw_coloredcircle(round_button.x + round_button.width - 3 + 1, round_button.y + ceil(round_button.height/2), floor(round_button.height/2), round_button.theme.outline_color.r, round_button.theme.outline_color.g, round_button.theme.outline_color.b, round_button.theme.outline_color.opacity)

	change_color(color)
	draw_filledrect(round_button.x, round_button.y, round_button.x + round_button.width, round_button.y + round_button.height)

	change_color(round_button.theme.outline_color)
	draw_line(round_button.x, round_button.y, round_button.x + round_button.width, round_button.y)
	draw_line(round_button.x, round_button.y + round_button.height, round_button.x + round_button.width, round_button.y + round_button.height)

	draw_set_font(round_button.theme.font)
	change_color(round_button.theme.text_color)
	local tx, ty = draw_textsize(round_button.text)
	draw_text( round_button.x + round_button.width/2 - floor(tx/2), round_button.y + round_button.height/2 - floor(ty/2), round_button.text )
end

function string.split(s)
	local words = {}
	for word in string.gmatch(s, "%S+") do
		table_insert(words, word)
	end
	return words
end

---@return table|nil
local function load_consolelib(prefixes)
	local function cant_find()
		printc(255, 150, 150, 255, "Couldn't load console.lua, will use built-in command lib")
	end
	local success, result = xpcall(require, cant_find, "console")
	if success then return result end

	---@param str StringCmd
	local function run_command(str)
		local cmd = string.split(str:Get())

		local prefix
		for k,v in pairs (prefixes) do
			if k == tostring(cmd[1]) then
					prefix = v
					print("found prefix " .. k)
			end
		end

		if prefix == nil then return end
		table_remove(cmd, 1)

		-- Extract the command name and parameters
		local command_name = cmd[1]
		table_remove(cmd, 1)

		-- Check if the command exists
		if not prefix.command_list[command_name] then
			error("Command '" .. command_name .. "' not found.")
			return
		end

		local parameters = {}

		-- convert parameters[key] to the desired type
		for k, v in pairs (prefix.command_list[command_name].required_parameters) do
			if tostring(v) == "string" then
				parameters[k] = tostring(cmd[1])
				table_remove(cmd, 1)
			elseif tostring(v) == "number" then
				parameters[k] = tonumber(cmd[1])
				table_remove(cmd, 1)
			elseif tostring(v) == "bool" then
				if tostring(cmd[1]) == "true" then
					parameters[k] = true
					table_remove(cmd, 1)
				else
					parameters[k] = false
					table_remove(cmd, 1)
				end
			elseif tostring(v) == "function" then
				table_remove(cmd, 1)
				local func_body = load(table_concat(cmd, " "), nil, "t")
				parameters[k] = func_body
				cmd = {}
				break
			elseif tostring(v) == "table" then
					--table_remove(cmd, 1)
				local concated = table_concat(cmd, " ")
				print(concated)
				local new_table = load("return " .. concated, nil, "t")()
				if type(new_table) ~= "table" then
					error(string.format("the new table %s is NOT a table", new_table))
				end
				parameters[k] = new_table
				cmd = {}
				break
			end
		end

		if #cmd > 0 then
			printc(255,100,100,255, "Too many parameters")
		end

		-- Call the command's callback with the parameters
		return xpcall(prefix.command_list[command_name].callback, debug.traceback, parameters)
	end

	-- changes a command[key] to a value so yeah, it's probably useless now that you can change the values with a command.callback/required_parameters and stuff so yeah have fun
	---@param prefix string
	---@param name string
	---@param key string
	---@param value any
	local function change_command(prefix, name, key, value)
		assert(prefixes[prefix], "prefix is nil")
		assert(prefixes[prefix].command_list, "command_list is nil")
		prefixes[prefix].command_list[name][key] = value
		if not prefixes[prefix].command_list[name][key] == value then
			warn(string.format("couldn't change %s's %s to be %s", tostring(name), tostring(key), tostring(value)))
			return false
		end
		printc(100,255,255,255, string.format("changed command %s's %s at prefix %s", name, key, prefix))
		return true
	end

	-- fancy way of saying command = nil
	---@param prefix string
	---@param name string
	local function destroy_command(prefix, name)
		prefixes[prefix].command_list[name] = nil
		if prefixes[prefix].command_list[name] then
			printc(255,100,100,255, string.format("command %s at prefix %s wasn't destroyed somehow", name, prefix))
			return false
		end
		printc(255,100,100,255, string.format("destroyed command %s at prefix %s", name, prefix))
		return true
	end

	-- makes a Command that is literally just a table with another name but i like it :)
	---@param prefix string
	---@param name string
	---@return Command|nil
	local function create_command(prefix, name)
		prefixes[prefix].command_list[name] = {
			callback = nil,
			required_parameters = {}, -- {name = "string"},
			description = "",
		}

		if not prefixes[prefix].command_list[name] then
			printc(255,100,100,255, "couldn't create command %s at prefix %s", name, prefix)
			return nil
		else
			printc(100,100,255,255, string.format("create command %s at prefix %s", name, prefix))
		end

		return prefixes[prefix].command_list[name]
	end

	-- this is probably the second most important function in the lib
	---@param new_prefix string
	local function create_prefix(new_prefix)
		prefixes[new_prefix] = {
			command_list = {}
		}

		if prefixes[new_prefix] then
			printc(100,255,100,255, string.format("created prefix %s", tostring(new_prefix)))
			return true
		end
		return false
	end

	local lib = {}
	lib.create_command = create_command
	lib.change_command = change_command
	lib.destroy_command = destroy_command
	lib.create_prefix = create_prefix

	unregister("SendStringCmd", "console_lib")
	register("SendStringCmd", "console_lib", run_command)

	return lib
end

---@param theme Theme
local function console_commands(theme)
	local console_lib = load_consolelib()
	if not console_lib then return end

	local object_list = {}
	local object_type = {window = "window", button = "button", checkbox = "checkbox", combobox = "combobox", slider = "slider", round_button = "round_button"}

	console_lib.create_prefix("alib")
	local alib_create = console_lib.create_command("alib", "create")
	alib_create.required_parameters = {object_type = "string", properties = "table"}
	alib_create.description = "Create a new object (window, button, round_button, etc)"
	alib_create.callback = function(params)
		if params.object_type == object_type.window then
			local window = create_window(params.properties.name, params.properties.x, params.properties.y, params.properties.width, params.properties.height, theme)
			object_list[window.name] = window
			window_init(window)

		elseif params.object_type == object_type.button then
				local button = create_button(params.properties.name, params.properties.text, params.properties.x, params.properties.y, params.properties.width, params.properties.height, theme, object_list[params.properties.parent], params.properties.click)
				object_list[button.name] = button

		elseif params.object_type == object_type.checkbox then
			local checkbox = create_checkbox(params.properties.name, params.properties.x, params.properties.y, params.properties.size, theme, object_list[params.properties.parent], params.properties.click)
			object_list[checkbox.name] = checkbox

		elseif params.object_type == object_type.slider then
			local slider = create_slider(params.properties.name, params.properties.x, params.properties.y, params.properties.width, params.properties.height, theme, object_list[params.properties.parent], params.properties.min, params.properties.max, params.properties.value)
			object_list[slider.name] = slider
			
		elseif params.object_type == object_type.round_button then
			local round_button = create_round_button(params.properties.name, params.properties.text, theme, object_list[params.properties.parent], params.properties.x, params.properties.y, params.properties.width, params.properties.height, params.properties.click)
			object_list[round_button.name] = round_button

		elseif params.object_type == object_type.combobox then
			local combobox = create_combobox(params.properties.name, object_list[params.properties.parent], params.properties.x, params.properties.y,params.properties.width, params.properties.height, theme, params.properties.items)
			object_list[combobox.name] = combobox
			combobox_init(combobox)
		end
	end

	unregister("Draw", "alib_commands_render")
	register("Draw", "alib_commands_render", function()
		for k,v in pairs (object_list) do
			if v.type == "window" then
				render_window(v)
			elseif v.type == object_type.button then
				render_button(v)
			elseif v.type == object_type.checkbox then
				render_checkbox(v)
			elseif v.type == object_type.slider then
				render_slider(v)
			elseif v.type == object_type.round_button then
				render_round_button(v)
			elseif v.type == object_type.combobox then
				render_combobox(v)
			end
		end
	end)

	local alib_help = console_lib.create_command("alib", "help")
	alib_help.required_parameters = {object_type = "string"}
	alib_help.description = "Prints the object properties that you need to define when creating it"
	alib_help.callback = function(params)
		if params.object_type == object_type.button then
			print("name: string\nx: number\ny: number\nwidth: number\nheight: number\nclick: function")
		elseif params.object_type == object_type.checkbox then
			print("name: string\nx: number\ny: number\nsize: number\nparent: string")
		elseif params.object_type == object_type.combobox then
			print("name: string\nx: number\ny: number\nwidth: number\nheight: number\nparent: string\nitems: number | items example: items = {'asdf', 'awdad', 'hello', 'dad'}")
		elseif params.object_type == object_type.window then
			print("name: string\nx: number\ny: number\nwidth: number\nheight: number")
		elseif params.object_type == object_type.round_button then
			print("name: string\ntext: string\nx: string\ny: string\nwidth: number\nheight: number\nclick: function")
		else
			printc(255,255,255,255, "Available types:")
			for k,v in pairs (object_type) do
				print(v)
			end
		end
	end
end

local lib = {
	version = 0.37,
	window = {create = create_window, render = render_window, init = window_init, getchildren = window_getchildren},
	button = {create = create_button, render = render_button},
	round_button = {create = create_round_button, render = render_round_button},
	slider = {create = create_slider, render = render_slider},
	checkbox = {create = create_checkbox, render = render_checkbox},
	combobox = {create = create_combobox, render = render_combobox, init = combobox_init},
	theme = create_theme,
	text = {create = create_text, render = render_text},
	create_font = create_font,
	rgb = rgb,
	clamp = clamp,
	unload = unload,
	commands = console_commands,
}

local known_bugs = {
	"didn't find any",
	"please make a issue with any bugs!!!",
}

printc( 255,100,100,255, "known bugs:" )
for k,v in pairs (known_bugs) do
	printc(255,100,100,255, tostring(v))
end

return lib
