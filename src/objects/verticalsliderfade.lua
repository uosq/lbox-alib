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
