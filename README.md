### TODO: optimize code (hopefully in a near future)
I like making useless things that probably only I will use :)

currently this has `window,button,checkbox,dropdown/combobox and slider` support, all the properties can be changed and used like a normal table

read the wiki if you have any problem

a example on how to use this
```lua
local alib = require('alib')

local theme = alib.theme:new()

local window = alib.window:create(
    100,100,500,300, -- x, y, width, height
    theme, -- earth is made of earth
    1 -- outline thickness
)

local button = alib.button:create(
    'button', -- the button name
    'text', -- the button text
    10,50,100,40, -- parent.x + x, parent.y + y, width, height
    theme, -- yes
    1, -- outline thickness
    window, -- button's dad
    function(this) -- "this" is a reference to the button if you need to access any value of it like text (or values if is a dropdown)
        print("Hello, world!")
    end
)

callbacks.Register("Draw", function()
    window:render()
    button:render()
end)

callbacks.Register("Unload", function()
    alib.unload()
end)
```