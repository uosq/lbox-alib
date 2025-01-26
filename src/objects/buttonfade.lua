local settings = require("src.settings")
local shapes = require("src.shapes")
local misc = require("src.misc")

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param text string?
---@param alpha_start integer
---@param alpha_end integer
---@param horizontal boolean
local function buttonfade(mouse_inside, width, height, x, y, alpha_start, alpha_end, horizontal, text)
   width = math.floor(width); height = math.floor(height); x = math.floor(x); y = math.floor(y)
   --- shadow
   misc.change_color(settings.button.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.button.shadow.offset)

   --- background
   local color = mouse_inside and settings.button.selected or settings.button.background
   misc.change_color(color)
   shapes.rectanglefade(width, height, x, y, alpha_start, alpha_end, horizontal)

   --- outline
   misc.change_color(settings.button.outline.color)
   misc.draw_outline(width, height, x, y, settings.button.outline.thickness)

   --- text
   if text and #text > 0 then
      draw.SetFont(settings.font)
      local textwidth, textheight = draw.GetTextSize(text)
      misc.change_color(settings.button.text_color)
      if settings.button.shadow.text then
         draw.TextShadow(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight / 2), text)
      else
         draw.Text(x + math.floor(width / 2) - math.floor(textwidth / 2),
            y + math.floor(height / 2) - math.floor(textheight / 2), text)
      end
   end
end

return buttonfade
