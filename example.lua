local alib = require("alib")
local font = draw.CreateFont("TF2 BUILD", 12, 1000)
alib.settings.font = font

local window = {x = 5, y = 1080/2, width = 350, height = 200}

local button = {
   x = 20, y = 5, width = 100, height = 20,
   text = "hi",
   is_mouse_inside = false,
   click = function()
      print("helo world!")
   end
}

local checkbox = {
   x = 20, y = 35, width = 50, height = 50,
   checked = false,
   is_mouse_inside = false,
}

local slider = {
   x = 20, y = 100, width = 100, height = 20,
   value = 50,
   is_mouse_inside = false,
}

local fade_button = {
   x = 130, y = 5, width = 100, height = 20,
   text = "hello",
   is_mouse_inside = false,
   click = function ()
      print("hi dad!")
   end
}

local fade_button2 = {
   x = 240, y = 5, width = 100, height = 20,
   text = "yes",
   is_mouse_inside = false,
   click = function ()
      print("hi mom!")
   end
}

local fade_slider = {
   x = 20, y = 130, width = 100, height = 20,
   value = 50,
   is_mouse_inside = false,
}

local checked_checkbox = {
   x = 80, y = 35, width = 50, height = 50,
   checked = true,
   is_mouse_inside = false,
}

local list = {
   x = 150, y = 35, width = 180,
   items = {"hello", "hi", "hi dad!", "hi mom", "hi bro", "hi sis"},
   selected_item_index = 1,
}

local verticalslider = {
   x = 20, y = 160, width = 311, height = 20,
   min = 0, max = 100, value = 50,
   flipped = false,
   is_mouse_inside = false,
}

local last_clicked = 0

--- we handle mouse clicking here
--- this isn't the most ideal way to handle it but it's an example so you gotta put some effort in
---@param usercmd UserCmd
callbacks.Register("CreateMove", function (usercmd)
   button.is_mouse_inside = alib.math.isMouseInside(window, button)
   slider.is_mouse_inside = alib.math.isMouseInside(window, slider)
   checkbox.is_mouse_inside = alib.math.isMouseInside(window, checkbox)
   checked_checkbox.is_mouse_inside = alib.math.isMouseInside(window, checked_checkbox)
   fade_button.is_mouse_inside = alib.math.isMouseInside(window, fade_button)
   fade_button2.is_mouse_inside = alib.math.isMouseInside(window, fade_button2)
   fade_slider.is_mouse_inside = alib.math.isMouseInside(window, fade_slider)
   verticalslider.is_mouse_inside = alib.math.isMouseInside(window, verticalslider)

   local state, tick = input.IsButtonPressed(E_ButtonCode.MOUSE_LEFT)
   if state and tick ~= last_clicked then
      last_clicked = tick
      if button.is_mouse_inside then
         button.click()
      elseif checkbox.is_mouse_inside then
         checkbox.checked = not checkbox.checked
      elseif checked_checkbox.is_mouse_inside then
         checked_checkbox.checked = not checked_checkbox.checked
      elseif fade_button.is_mouse_inside then
         fade_button.click()
      elseif fade_button2.is_mouse_inside then
         fade_button2.click()
      end
   end

   if input.IsButtonDown(E_ButtonCode.MOUSE_LEFT) and slider.is_mouse_inside then
      local value = alib.math.GetNewSliderValue(window, slider, 0, 100)
      slider.value = value
   end

   if input.IsButtonDown(E_ButtonCode.MOUSE_LEFT) and fade_slider.is_mouse_inside then
      local value = alib.math.GetNewSliderValue(window, fade_slider, 0, 100)
      fade_slider.value = value
   end

   if input.IsButtonDown(E_ButtonCode.MOUSE_LEFT) and verticalslider.is_mouse_inside then
      local value = alib.math.GetNewVerticalSliderValue(window, verticalslider, verticalslider.min, verticalslider.max, verticalslider.flipped)
      verticalslider.value = value
   end

   for i,v in ipairs (list.items) do
      local is_mouse_inside = alib.math.isMouseInsideItem(window, list, i)
      if is_mouse_inside and input.IsButtonDown(E_ButtonCode.MOUSE_LEFT) then
         list.selected_item_index = i
      end
   end

   --[[ its not really useful this for now, but at least explains how isMouseInsideList works xd
   if input.IsButtonDown(E_ButtonCode.KEY_UP) and alib.math.isMouseInsideList(window, list) then
      if list.selected_item_index > 1 then
         list.selected_item_index = list.selected_item_index - 1
      end
   elseif input.IsButtonDown(E_ButtonCode.KEY_DOWN) and alib.math.isMouseInsideList(window, list) then
      if list.selected_item_index + 1 < #list.items then
         list.selected_item_index = list.selected_item_index + 1
      end
   end
   ]]
end)

--- we render things here
callbacks.Register("Draw", function ()
   --- window
   alib.objects.window(window.width, window.height, window.x, window.y, "example test :)")

   --- button
   alib.objects.button(button.is_mouse_inside, button.width, button.height, button.x + window.x, button.y + window.y, button.text)

   --- button fade horizontal
   alib.objects.buttonfade(fade_button.is_mouse_inside, fade_button.width, fade_button.height, fade_button.x + window.x, fade_button.y + window.y, 255, 50, true, fade_button.text)

   --- button fade vertical
   alib.objects.buttonfade(fade_button2.is_mouse_inside, fade_button2.width, fade_button2.height, fade_button2.x + window.x, fade_button2.y + window.y, 255, 50, false, fade_button2.text)

   --- checkbox
   alib.objects.checkbox(checkbox.width, checkbox.height, checkbox.x + window.x, checkbox.y + window.y, checkbox.checked)

   --- slider
   alib.objects.slider(slider.width, slider.height, slider.x + window.x, slider.y + window.y, 0, 100, slider.value)

   --- faded slider
   alib.objects.sliderfade(fade_slider.width, fade_slider.height, fade_slider.x + window.x, fade_slider.y + window.y, 0, 100, fade_slider.value, 50, 255, true)

   --- checked checkbox
   alib.objects.checkbox(checked_checkbox.width, checked_checkbox.height, checked_checkbox.x + window.x, checked_checkbox.y + window.y, checked_checkbox.checked)

   --- list
   alib.objects.list(list.width, list.x + window.x, list.y + window.y, list.selected_item_index, list.items)

   --- vertical slider
   alib.objects.verticalslider(verticalslider.width, verticalslider.height, verticalslider.x + window.x, verticalslider.y + window.y, verticalslider.min, verticalslider.max, verticalslider.value, verticalslider.flipped)
end)

callbacks.Register("Unload", alib.unload)