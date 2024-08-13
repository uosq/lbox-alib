local alib = require("alib")

local theme = alib.theme("TF2 BUILD", alib.rgb(65,65,65,255), alib.rgb(123,211,40,255), alib.rgb(255,255,255,255), alib.rgb(100,255,100,255), 2)
local window = alib.window.create("window", 70, 90, 400,200, theme)
local button = alib.button.create("button", "bottom text", 40, 50, 80, 20, theme, window, function() print("Hi mom") end)
local slider = alib.slider.create("slider", 40, 70, 100, 20, theme, window, 0, 100, 0 )

alib.window.init(window)
callbacks.Register("Draw", function ()
    alib.window.render(window)
    alib.button.render(button)
    alib.slider.render(slider)
end)

callbacks.Register("Unload", alib.unload)