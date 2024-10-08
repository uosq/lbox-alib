local alib = require("alib")

local theme = alib.theme("TF2 BUILD", 12, alib.rgb(65,65,65,255), alib.rgb(123,211,40,255), alib.rgb(255,255,255,255), alib.rgb(100,255,100,255), 2)
--[[local window = alib.window.create("window", 70, 90, 400,300, theme)
local button = alib.button.create("button", "bottom text", 40, 50, 80, 20, theme, window, function() print("Hi mom") end)
local slider = alib.slider.create("slider", 40, 80, 100, 20, theme, window, 0, 100, 0 )
local checkbox = alib.checkbox.create("checkbox", 40, 120, 25, theme, window, function(this) print(this.checked) end)
local combobox = alib.combobox.create("combobox", window, 40, 150, 40, 20, theme, {"item1","item2","item3"})
local round_button = alib.round_button.create("round", "hello", theme, window, 90, 300, 100, 30, function()print('hi')end)

alib.window.init(window)
alib.combobox.init(combobox)

alib.commands(theme)

callbacks.Register("Draw", function ()
    alib.window.render(window)
    alib.button.render(button)
    alib.slider.render(slider)
    alib.checkbox.render(checkbox)
    alib.combobox.render(combobox)
    alib.round_button.render(round_button)
end)]]

alib.notify(theme, "Example loaded!")

callbacks.Register("Unload", alib.unload)
