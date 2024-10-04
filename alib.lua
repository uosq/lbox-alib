
local button = {
   name = "", text = "",
   x = 0, y = 0, width = 0, height = 0,
   theme = {},
   parent = {},
   enabled = true, selectable = true,
   click = nil,
   last_clicked_tick = nil,
   type = "button",
}
button.__index = button

function button:new(name, text, parent, x, y, width, height, theme, click)
   local mt = setmetatable({}, button)
   mt.name = name
   mt.text = text
	mt.x = parent.x + x
   mt.y = parent.y + y
   mt.width = width
   mt.height = height
	mt.theme = theme
	mt.parent = parent
	mt.enabled = true
   mt.selectable = true
	mt.click = click
	mt.last_clicked_tick = nil
	mt.type = "button"
	parent.children[#parent.children+1] = mt
   return mt
end

function button:render()
   if not self.enabled or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end

	if utils.is_mouse_inside(self) then
		utils.change_color(self.theme.selected_color)
	else
		utils.change_color(self.theme.background_color)
	end
	draw.FilledRect(self.x, self.y, self.x + self.width, self.y + self.height)

	draw.SetFont(self.theme.font)
	utils.change_color(self.theme.text_color)
	local tx, ty = draw.GetTextSize(self.text)
	draw.Text( self.x + self.width/2 - math.floor(tx/2), self.y + self.height/2 - math.floor(ty/2), self.text )

	for i = 1, self.theme.outline_thickness do
		draw.OutlinedRect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
	end
end


local slider = {
   name = "",
   x = 0, y = 0, width = 0, height = 0,
   theme = {}, parent = {},
   min = 0, max = 0, value = 0, percent = 0,
   last_clicked_tick = nil,
   selectable = true, enabled = true,
   type = "slider",
   click = nil,
}
slider.__index = slider
function slider.new(name, x, y, width, height, theme, parent, min, max, value)
   local slider_mt = setmetatable({}, slider)
   slider_mt.name = name
   slider_mt.x = parent.x + x
   slider_mt.y = parent.y + y
   slider_mt.width = width
   slider_mt.height = height
   slider_mt.theme = theme
   slider_mt.parent = parent
   slider_mt.min = min
   slider_mt.max = max
   slider_mt.value = value
   slider_mt.percent = (value - min) / max - min
   slider_mt.last_clicked_tick = nil
   
   slider_mt.click = function()
      callbacks.Register("Draw", "sliderclicks", function()
			if input.IsButtonDown(MOUSE_LEFT) and utils.is_mouse_inside(slider) and slider.selectable and slider.enabled then
				local mx = input.GetMousePos()[1]
				local initial_mouse_pos = mx - slider.x
				local new_value = utils.clamp(slider.min + ((initial_mouse_pos/slider.width) * (slider.max - slider.min)), slider.min, slider.max)
				slider.value = new_value
				slider.percent = (new_value - slider.min) / slider.max - slider.min
			else
				callbacks.Unregister( "Draw", "sliderclicks" )
			end
		end)
   end
   parent.children[#parent.children+1] = slider_mt
   return slider_mt
end


theme = {
   background_color = {},
   selected_color = {},
   text_color = {},
   outline_color = {},
   outline_thickness = 0,
   font = 0,
   font_size = 0,
}
theme.__index = theme
function theme:create_font(font, font_size)
	local success, result = pcall(draw.CreateFont, font, font_size, 1000)
	assert(success, string.format("error: couldn't create font %s\n%s", font, tostring(result)))
	return result
end
function theme:new(font, font_size, background_color, selected_color, text_color, outline_color, outline_thickness)
   local mt = setmetatable({}, theme)
	mt.background_color = background_color
	mt.selected_color = selected_color
	mt.text_color = text_color
	mt.outline_color = outline_color
	mt.outline_thickness = outline_thickness
	mt.font = self:create_font(font, font_size)
	mt.font_size = font_size
	return mt
end
function theme:change_color(color)
	draw.Color(color.r, color.g, color.b, color.opacity)
end

utils = {}

utils.is_mouse_inside = function(object)
	local mousePos = input.GetMousePos()
   local mx, my = mousePos[1], mousePos[2]
   if (mx < object.x or my < object.y) or (mx > object.x + object.width or my > object.y + object.height) then
      return false
   end
   return true
end
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
utils.rgb = function(red, green, blue, opacity)
	return {
		r = utils.clamp(red, 0, 255),
		g = utils.clamp(green, 0, 255),
		b = utils.clamp(blue, 0, 255),
		opacity = utils.clamp(opacity, 0, 255)
	}
end


local window = {
   name = "",
   x = 0, y = 0, width = 0, height = 0,
   theme = {},
   enabled = true,
   children = {},
   type = "window"
}
window.__index = window

function window.new(name, x, y, width, height, theme)
   local mt = setmetatable({}, window)
   mt.name = name
   mt.x = x
   mt.y = y
   mt.width = width
   mt.height = height
   mt.theme = theme
   return mt
end

function window:render()
   if not self.enabled or gui.GetValue("clean screenshots") == 1 and engine.IsTakingScreenshot() then return end
   theme:change_color(self.theme.background_color)
   draw.FilledRect(self.x, self.y, self.x + self.width, self.y + self.height)
   theme:change_color(self.theme.outline_color)
   for i = 1, self.theme.outline_thickness do
      draw.OutlinedRect(self.x - 1 * i, self.y - 1 * i, self.x + self.width + 1 * i, self.y + self.height + 1 * i)
   end
end

function window:init()
   callbacks.Unregister("Draw", "mouse_manager")
	callbacks.Register("Draw", "mouse_manager", function()
		for k,v in pairs(self.children) do
			local state, tick = input.IsButtonPressed(MOUSE_LEFT)
			if v.enabled and v.selectable and utils.is_mouse_inside(v) and state and tick ~= v.last_clicked_tick and v.click then
				assert(pcall(v.click, v), string.format("error: couldn't call .click() on %s.init()", tostring(v.parent.name)))
			end
			v.last_clicked_tick = tick
		end
	end)
end

local lib = {
   window = window,
   theme = theme,
   utils = utils,
   slider = slider,
}

return lib