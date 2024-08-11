local alib = require("alib")

local theme = alib.theme("TF2 BUILD", alib.rgb(65,65,65,1), alib.rgb(255,255,255,1), alib.rgb(100,255,100,1), 2)
local window = alib.window.create("window", 70, 90, 400,200, theme)
local button = alib.button.create("button", "bottom text", 40, 50, 50, 40, theme, window, function() print("Hi mom") end)

alib.window.init(window)
callbacks.Register("Draw", function ()
    alib.window.render(window)
    alib.button.render(button)
end)

callbacks.Register("Unload", alib.unload)