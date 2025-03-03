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
