local settings = require("src.settings")
local misc = require("src.misc")

local function checkbox(width, height, x, y, checked)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   misc.change_color(settings.button.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.checkbox.shadow.offset)

   --- outline
   misc.change_color(settings.checkbox.outline.color)
   misc.draw_outline(width, height, x, y, settings.checkbox.outline.thickness)

   -- checked
   if checked then
      misc.change_color(settings.checkbox.checked_color)
   else
      misc.change_color(settings.checkbox.not_checked_color)
   end
   draw.FilledRect(x, y, x + width - 1, y + height - 1)
end

return checkbox
