local alib = require("alib")
local font = draw.CreateFont("TF2 BUILD", 12, 1000)

local window = alib.window.new()
window.background = alib.color.new(40,40,40,255)
--window.outline.thickness = 0
window.font = font
window.width = 800
window.height = 600
window.x = 0
window.y = 0
window.z = 0

local button = alib.button.new()
button.font = font
button.content.text = "hi"
button.content.color = alib.color.new(255,255,255,255)
button.x = 10
button.y = 20
button.z = 1
button.width = 100
button.height = 20
button.outline.thickness = 1
button.outline.color = alib.color.new(100,255,100,255)
button.click = function()
   print("Hello, world!")
end

callbacks.Register("Draw", alib.render)
callbacks.Register("Unload", alib.unload)
