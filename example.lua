local alib = require("alib")

local theme = alib.theme:new("TF2 BUILD",12,alib.color:new(80,80,80,255), alib.color:new(100,255,100,255), alib.color:new(0,0,0,0), alib.color:new(255,255,255,255), 0)
local window = alib.window:create(0,0,800,600,theme)

window.events.changed = function(key, old, new)
   print(tostring(key) .. " was " .. tostring(old) .. " now is " .. tostring(new))
end