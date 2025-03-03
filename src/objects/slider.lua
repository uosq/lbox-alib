local settings = require("src.settings")
local misc = require("src.misc")

local function slider(width, height, x, y, min, max, value)
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
   -- the magic number 1 makes both the width and height not overlap with the outline as we are drawing it after them are drawed
   if settings.slider.bar_outlined then
      draw.OutlinedRect(x, y, x + math.floor(width * percentage) - 1, y + height - 1)
   else
      draw.FilledRect(x, y, x + math.floor(width * percentage) - 1, y + height - 1)
   end
end

return slider
