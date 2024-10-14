local alib = require ("alib")
local font = draw.CreateFont("TF2 BUILD",12, 1000, E_FontFlag.FONTFLAG_ANTIALIAS)

local window = alib.window:create(0,0,800,600)
window.font = font
window.background = alib.color:new(40,40,40,255)
window.clickable = false

local button = alib.button:create(window, 0, 0, 100, 30)
button.text = "hello"
button.font = font
button.background = alib.color:new(80,80,80,255)
button.selected = alib.color:new(100,255,100,255)
button.text_color = alib.color:new(255,255,255,255)

button.events.mouseclick = function()
   print("oh no")
end

window.events.changed = function(key, old, new)
   print(tostring(key) .. " was " .. tostring(old) .. " now is " .. tostring(new))
end

callbacks.Unregister("Draw", "render things")
callbacks.Register("Draw", "render things",function ()
   alib.window:render(window)
   alib.button:render(button)
end)