local alib = require("alib")

local theme = alib.theme("TF2 BUILD", alib.rgb(65,65,65,1), alib.rgb(255,255,255,1), alib.rgb(100,255,100,1), 2)

local window = alib.window.create("window", 70, 90, 400,200, theme)
alib.window.init(window)

callbacks.Register("Draw", function ()
    alib.window.render(window)
end)