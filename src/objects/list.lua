local settings = require("src.settings")
local misc = require("src.misc")

local function draw_container(width, height, x, y)
   -- Shadow
   misc.change_color(settings.list.shadow.color)
   misc.draw_shadow(width, height, x, y, settings.list.shadow.offset)

   -- Outline
   misc.change_color(settings.list.outline.color)
   misc.draw_outline(width + 1, height + 1, x, y, settings.list.outline.thickness)

   -- Background
   misc.change_color(settings.list.background)
   draw.FilledRect(x, y, x + width, y + height)
end

local function draw_items(width, item_height, x, y, selected_item_index, items)
   draw.SetFont(settings.font) -- Set font once outside the loop
   local current_y = y

   for i, item in ipairs(items) do
      -- Draw selection highlight if needed
      if i == selected_item_index then
         misc.change_color(settings.list.selected)
         draw.FilledRect(x, current_y, x + width, y + item_height)
      end

      -- Calculate text position
      local textwidth, textheight = draw.GetTextSize(item)
      local text_x = x + math.floor(width / 2) - math.floor(textwidth / 2)
      local text_y = current_y + math.floor(textheight / 2)

      -- Draw text
      misc.change_color(settings.list.text_color)
      draw.Text(text_x, text_y, item)

      -- Move to next item position
      current_y = current_y + item_height
   end
end

---@param width integer
---@param x integer
---@param y integer
---@param selected_item_index integer
---@param items table<integer, string>
local function list(width, x, y, selected_item_index, items)
   local item_height = math.floor(settings.list.item_height)
   local height = math.floor(#items * item_height)

   draw_container(width, height, x, y)
   draw_items(width, item_height, x, y, selected_item_index, items)
end

return list
