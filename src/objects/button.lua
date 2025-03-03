local settings = require("src.settings")
local misc = require("src.misc")

--- unfortunately if buttons are round we dont have outlines (im too lazy to make them :troll:)
---@param mouse_inside boolean
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param text string?
local function button(mouse_inside, width, height, x, y, text)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   if not settings.button.round then
      misc.change_color(settings.button.shadow.color)
      misc.draw_shadow(width, height, x, y, settings.button.shadow.offset)
   end

   local color = mouse_inside and settings.button.selected or settings.button.background

   if settings.button.round then
      local radius = math.floor(height / 2)

      if settings.button.shadow.offset > 0 then
         --- oh boy these shadows will be EXPENSIVE
         local offset = settings.button.shadow.offset
         misc.change_color(settings.button.shadow.color)
         misc.draw_shadow(width, height, x, y, offset)

         misc.change_color(settings.button.shadow.color)
         misc.filledcircle(x + offset, y + math.ceil(height / 2) + offset, radius)         -- left circle
         misc.filledcircle(x + width + offset, y + math.ceil(height / 2) + offset, radius) -- right circle
      end

      --- side circles
      misc.change_color(color)
      misc.filledcircle(x, y + math.ceil(height / 2), radius)         -- left circle
      misc.filledcircle(x + width, y + math.ceil(height / 2), radius) -- right circle
   else
      --- normal outline
      misc.change_color(settings.button.outline.color)
      misc.draw_outline(width + 1, height + 1, x, y, settings.button.outline.thickness)
   end

   --- background
   misc.change_color(color)
   draw.FilledRect(x, y, x + width, y + height)

   --- text
   if text and #text > 0 then
      draw.SetFont(settings.font)
      local textwidth, textheight = draw.GetTextSize(text)
      misc.change_color(settings.button.text_color)
      if settings.button.shadow.text then
         draw.TextShadow(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight /
               2), text)
      else
         draw.Text(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight / 2),
            text)
      end
   end
end

return button
