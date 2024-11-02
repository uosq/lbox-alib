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

local tostring = tostring
local tonumber = tonumber
local package = package

local floor = math.floor
local ceil = math.ceil

local table_remove = table.remove
local table_insert = table.insert
local table_concat = table.concat
local table_sort = table.sort

local printc = printc
local print = print
local warn = warn
local error = error
local setmetatable = setmetatable
local rawset, rawget = rawset, rawget

local tick_count = globals.TickCount

local MOUSE_LEFT = MOUSE_LEFT

local objects = {}

---@class color
---@field public r integer red value
---@field public g integer green value
---@field public b integer blue value
---@field public a integer alpha value (transparency/opacity)
local color = {}
color.r = 0
color.g = 0
color.b = 0
color.a = 0
color.__index = color

---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return color
function color.new(r, g, b, a)
	return setmetatable({r=r,g=g,b=b,a=a}, color)
end

---@param a window
---@param b window
local function sort(a, b)
	return a.z > b.z
end

---@param number number
---@param min number
---@param max number
local function clamp(number, min, max)
	number = (number < min and min or number)
	number = (number > max and max or number)
	return number
end

---@class base_object
---@field public x integer
---@field public y integer
---@field public z integer
---@field public width integer
---@field public height integer
---@field public background color
---@field public selected color
---@field public unselected color
---@field public outline {thickness: integer, color: color}
---@field public font Font
---@field public parent window
---@field public enabled boolean
local base_object = {}
base_object.x = 0
base_object.y = 0
base_object.z = 0
base_object.width = 0
base_object.height = 0
base_object.background = color.new(0,0,0,0)
base_object.selected = color.new(0,0,0,0)
base_object.unselected = color.new(0,0,0,0)
base_object.outline = {thickness = 0, color = color.new(0,0,0,0)}
base_object.font = 0
base_object.__index = base_object

function base_object.new()
	return setmetatable({}, base_object)
end

function base_object:__newindex(key, value)
	if key == "parent" then
		local parent = rawget(self, "parent")
		local parent_x, parent_y = rawget(parent, "x"), rawget(parent, "y")
		local self_x, self_y = rawget(self, "x"), rawget(self, "y")
		rawset(self, "x", parent_x + self_x)
		rawset(self, "y", parent_y + self_y)
	end

	rawset(self, key, value)
end

function base_object:render() end
function base_object:delete() self = nil; collectgarbage("collect") end

---@param object base_object?
local function mouse_inside (object)
	if object == nil then return end
	local mouse_pos = get_mouse_pos()
	local mx, my = mouse_pos[1], mouse_pos[2]
	return (mx >= object.x + object.parent.x and my >= object.y + object.parent.y and mx <= object.x + object.parent.x + object.width and my <= object.y + object.height + object.parent.y)
end

---@param color color
---@param font Font
---@param x integer
---@param y integer
---@param text string
local function colored_text(color, font, x, y, text)
	draw_color(color.r, color.g, color.b, color.a)
	draw_set_font(font)
	draw_text(x, y, text)
end

---@param color color
local function change_color(color)
	draw_color(color.r, color.g, color.b, color.a)
end

---@class window : base_object
---@field parent nil
---@field selected nil
---@field unselected nil
---@field private manager_tick number
---@field public children base_object[]
local window = {}
local window_ticks = {}
window.manager_tick = 0
window.children = {}
window.__index = window

function window.new()
	local new = {}
	setmetatable(new, {__index = base_object})
	objects[#objects+1] = new
	table_sort(objects, sort)

	local current_tick = tick_count()

	window_ticks[#window_ticks+1] = current_tick

	new.manager_tick = current_tick -- "unique" id

	unregister("Draw", "mouse_manager " .. current_tick)
	register("Draw", "mouse_manager " .. current_tick, function ()
		local state, tick = buttondown(MOUSE_LEFT)
	
		for _, child in pairs (new.children) do
			if child.enabled or child.background.a > 0 and mouse_inside(child) and state and tick ~= child.last_tick then
				child.click()
				child.last_tick = tick
			end
		end
	end)

	return new
end

function window:render()
	if not self.enabled or getvalue("clean screenshots") == 1 and is_taking_screenshot() then return end

	change_color(self.background)
	draw_filledrect(self.x, self.y, self.x + self.width, self.y + self.height)

	for i = 1, self.outline.thickness do
		draw_outlinedrect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
	end
end

---@class button: base_object
---@field public content {color: color, text: string}
---@field public click function?
---@field public parent window
---@field private last_tick number
local button = {}
button.last_tick = 0
button.click = nil
button.content = {color = color.new(0,0,0,0), text = "button"}
button.__index = base_object

function button.new()
	local new = setmetatable({}, button)
	objects[#objects+1] = new
	table_sort(objects, sort)
	new.parent.children[#new.parent.children+1] = new
	return new
end

function button:render()
	if self.background.a == 0 or (getvalue("clean screenshots") == 1 and is_taking_screenshot()) then return end

	local color = mouse_inside(self) and self.selected or self.unselected
	change_color(color)
	draw_filledrect(self.x + self.parent.x, self.y + self.parent.y, self.x + self.width + self.parent.x, self.y + self.height + self.parent.y)

	draw_set_font(self.font)
	change_color(self.content.color)
	local tx, ty = draw_textsize(self.content.text)
	draw_text(self.x + self.width/2 - floor(tx/2) + self.parent.x, self.y + self.height/2 - floor(ty/2) + self.parent.y, self.content.text)

	for i = 1, self.outline.thickness do
		change_color(self.outline.color)
		draw_outlinedrect(self.x - 1 * i + self.parent.x, self.y - 1 * i + self.parent.y, self.x + self.width + 1 * i + self.parent.x, self.y + self.height + 1 * i + self.parent.y)
	end
end

---@class slider: base_object
---@field public min integer
---@field public max integer
---@field public current number
---@field private percent number
---@field public parent window
---@field public unselected color
local slider = {}
slider.__index = base_object

function slider.new()
	local new = setmetatable({}, {__index = slider})
	objects[#objects+1] = new
	new.outline.thickness = 1
	table_sort(objects, sort)

	new.click = function()
		unregister("Draw", "sliderclicks")
		register("Draw", "sliderclicks", function ()
			if buttondown(MOUSE_LEFT) and mouse_inside(new) and new.background.a > 0 then
				local mx = get_mouse_pos()[1]
				local init_mouse_pos = mx - new.x
				local value = clamp(new.min + ((init_mouse_pos/new.width) * (new.max - new.min)), new.min, new.max)
				new.current = value
			else
				unregister("Draw", "sliderclicks")
			end
		end)
	end

	new.parent.children[#new.parent.children+1] = new
	return new
end

function slider:__newindex(key, value)
	if key == "current" then
		rawset(self, key, value)
		local min, max = rawget(self, "min"), rawget(self, "max")
		rawset(self, "percent", (value - min) / max - min)
	end
	rawset(self, key, value)
end

function slider:render()
	if self.background.a == 0 or (getvalue("clean screenshots") == 1 and is_taking_screenshot()) then return end

	change_color(self.outline.color)
	for i = 1, self.outline.thickness do
		draw_outlinedrect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
	end

	change_color(mouse_inside(self) and self.selected or self.unselected)
	draw_filledrect(self.x, self.y, self.x + self.width, self.y + self.height)

	local color = mouse_inside(self) and self.selected or self.unselected
	change_color(color)
	draw_filledrect(self.x, self.y, self.x + self.width * self.percent, self.y + self.height)
end

---@class checkbox : base_object
---@field private last_tick number
---@field public checked boolean
---@field public on_checked function?
---@field public on_unchecked function?
local checkbox = {}
checkbox.__index = base_object

function checkbox:__newindex (key, value)
	if key == "checked" then
		if value == true then self.on_checked() else self.on_unchecked() end
	end
	rawset(self, key, value)
end

function checkbox:render()
	if self.background.a == 0 or (getvalue("clean screenshots") == 1 and is_taking_screenshot()) then return end

	change_color(mouse_inside(self) and self.selected or self.unselected)
	for i = 1, self.outline.thickness do
		draw_outlinedrect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
	end

	change_color(self.checked and self.selected or self.unselected)
	draw_filledrect(self.x, self.y, self.x + self.width, self.y + self.height)
end

---@class item : base_object
---@field public index integer
---@field public item string
---@field public x integer
---@field public y integer
---@field public parent combobox
---@field public width integer
---@field public height integer
---@field public click function
local item = {}
item.parent = nil
item.index = 0
item.value = ""
item.click = nil

function item.new(parent, index, value)
	local new = setmetatable({parent=parent,index=index,value=value, click = function ()
		parent.selected_item = index
		parent.click()
	end, x = parent.x, y = parent.y + (index * parent.height)}, item)
	return new
end

function item:render()
	if not self.parent.displaying_items or (getvalue("clean screenshots") == 1 and is_taking_screenshot()) then return end

	change_color(mouse_inside(self) and self.parent.selected or self.parent.unselected)
	draw_filledrect(self.x, self.y, self.x + self.parent.width, self.y + self.height)

	change_color(self.parent.outline.color)
	for i = 1, self.parent.outline.thickness do
		draw_outlinedrect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
	end

	draw_set_font(self.parent.font)
	change_color(self.parent.content.color)
	local tx, ty = draw_textsize(self.item)
	draw_text(self.x + self.parent.width/2 - floor(tx/2), self.y + self.height - floor(ty/2), self.item)
end

---@class combobox : base_object
---@field public items table
---@field private last_tick number
---@field public selected_item integer
---@field public displaying_items boolean
---@field public buttons item[]
---@field public content {color: color, text: string}
local combobox = {}
combobox.__index = base_object

function combobox.new()
	local new = setmetatable({}, {__index = combobox})
	objects[#objects+1] = new
	table_sort(objects, sort)

	new.buttons = {}
	for key, value in ipairs(new.items) do
		new.buttons[key] = item.new(new, key, value)
	end

	new.click = function()
		new.displaying_items = not new.displaying_items
		for _, child in (new.parent.children) do
			if child ~= new then
				child.enabled = not new.displaying_items
			end
		end
	end

	local tick = tick_count()

	unregister("Draw", "combobox_manager " .. tick)
	register("Draw", "combobox_manager " .. tick, function()
		local state = buttondown(MOUSE_LEFT)
		for _, but in ipairs(new.buttons) do
			if mouse_inside(but) and state and but.parent.displaying_items then
				but.click()
			end
		end
	end)

	register("Unload", function ()
		unregister("Draw", "combobox_manager " .. tick)
	end)

	return new
end

function combobox:render()
	if self.background.a == 0 or (getvalue("clean screenshots") == 1 and is_taking_screenshot()) then return end

	change_color(mouse_inside(self) and self.selected or self.unselected)
	draw_filledrect(self.x, self.y, self.x + self.width, self.y + self.height)

	draw_set_font(self.font)
	change_color(self.content.color)
	local tx, ty = draw_textsize(self.items[self.selected_item])
	draw.Text(self.x + self.width / 2 - floor(tx / 2), self.y + self.height / 2 - floor(ty / 2), tostring(self.items[self.selected_item]))

	change_color(self.parent.outline.color)
	for i = 1, self.parent.outline.thickness do
		draw_outlinedrect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
	end

	if self.displaying_items then
		for _, but in ipairs(self.buttons) do
			if but then
				but:render()
			end
		end
	end
end

---@class text
---@field public color color
---@field public x integer
---@field public y integer
---@field public text string
---@field font Font
local text = {}
text.__index = base_object

function text.new()
	return setmetatable({}, text)
end

function text:render()
	colored_text(self.color, self.font, self.x, self.y, self.text)
end

local function unload()
	for _, object in pairs (objects) do
		object:delete()
	end

	unregister("Draw", "render all objects alib")
	
	for i = 1, #window_ticks do
		unregister("Draw", "mouse_manager " .. window_ticks[i])
	end

	objects = nil
	package.loaded.alib = nil
end

local function render_all()
	unregister("Draw", "render all objects alib")
	register("Draw", "render all objects alib", function ()
		for _, object in pairs (objects) do
			object:render()
		end
	end)
end

local lib = {
	window = window,
	button = button,
	slider = slider,
	checkbox = checkbox,
	text = text,
	combobox = combobox,
	color = color,
	unload = unload,
	render = render_all,
}

printc(100, 255, 100 , 255, "alib loaded!")

return lib
