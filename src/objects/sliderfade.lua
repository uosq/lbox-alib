local settings = require("src.settings")
local misc = require("src.misc")

local function sliderfade(width, height, x, y, min, max, value, start_alpha, end_alpha, horizontal)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)

   --- shadow
   misc.change_color(settings.slider.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.slider.shadow.offset)

   --- background
   misc.change_color(settings.slider.background)
   draw.FilledRect(x, y, x + width, y + height)

   --- outline
   misc.change_color(settings.slider.outline.color)
   misc.draw_outline(width, height, x, y, settings.slider.outline.thickness)

   --- slider bar
   misc.change_color(settings.slider.bar_color)
   local percentage = (value - min) / (max - min)
   draw.FilledRectFade(x, y, x + math.floor(width * percentage) - 1, height - 1, start_alpha, end_alpha, horizontal)
end

return sliderfade
