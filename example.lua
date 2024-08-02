local alib = require('alib')

local window_theme = alib.theme:new(
    'Verdana',
    alib.rgba(50,50,50),
    nil,
    nil,
    alib.rgba(120,30,125)
)

local button_theme = alib.theme:new(
    'Verdana',
    alib.rgba(150,150,150),
    alib.rgba(123,123,255),
    alib.rgba(255,255,255),
    alib.rgba(100,255,100)
)

local window = alib.window:create(
    'window',
    100,100,500,300,
    window_theme,
    1,
    nil
)

local button = alib.button:create(
    'button',
    'bottom text',
    10,50,100,40,
    button_theme,
    1,
    window,
    function()
        print('oi')
    end
)

local slider_theme = alib.theme:new(
    'Verdana',
    alib.rgba(255,255,255,255),
    alib.rgba(255,100,100,255),
    alib.rgba(255,255,255),
    alib.rgba(100,100,100,255)
)

local slider = alib.slider:create(
    'slider', "hello",
    window,
    0, 50, 100,
    200, 100,
    100,20,
    slider_theme,
    0
)

local topbar_theme = alib.theme:new(
    'Verdana',
    alib.rgba(0,0,0),
    alib.rgba(0,0,0),
    alib.rgba(255,255,255),
    alib.rgba(0,0,0)
)

local topbar = button:create(
    'topbar', 'topbar',
    0,0,
    window.width,
    30,
    topbar_theme,
    0,
    window,
    function()
        local mx = input.GetMousePos()[1]
        local my = input.GetMousePos()[2]
        local drag_delta = { x=0, y=0 }
        local last_mouse_pos = { x=mx,y=my }
        drag_delta.x = mx - last_mouse_pos.x
        drag_delta.y = my - last_mouse_pos.y

        local window_children = window:getchildren()

        local randomtext = alib.rstring(128)
        callbacks.Register("Draw", "mousedrag" .. randomtext, function()
            -- thanks lnxlib
            local mx = input.GetMousePos()[1]
            local my = input.GetMousePos()[2]
            if not input.IsButtonDown( MOUSE_LEFT ) then
                callbacks.Unregister( "Draw", "mousedrag" .. randomtext )
                return
            end
            drag_delta.x = mx - last_mouse_pos.x
            drag_delta.y = my - last_mouse_pos.y
            last_mouse_pos = {x=mx,y=my}
            for k,v in pairs (window_children) do
                v.x = v.x + drag_delta.x
                v.y = v.y + drag_delta.y
            end
            window.x = window.x + drag_delta.x
            window.y = window.y + drag_delta.y
        end)
    end
)

local checkbox_theme = alib.theme:new(
    'Verdana',
    alib.rgba(20,20,20),
    alib.rgba(0,0,0),
    alib.rgba(255,255,255),
    nil
)

local checkbox = alib.checkbox:create(
    'checkboxlol',"lol",
    10,250,20,1,
    window,
    false,
    checkbox_theme,
    alib.rgba(100,255,100),
    alib.rgba(255,0,0),
    function(this)
        print(this.checked)
    end
)

local combobox_theme = alib.theme:new(
    'Verdana',
    alib.rgba(255,255,255),
    alib.rgba(40,40,40),
    alib.rgba(255,0,0),
    alib.rgba(15,15,15)
)

local values_theme = alib.theme:new(
    'Verdana',
    alib.rgba(20,20,20),
    alib.rgba(100,255,100),
    alib.rgba(255,255,255),
    nil
)

local combobox = alib.combobox:create(
    'ddrop',
    window,
    40, 250, 100, 20,
    0,
    combobox_theme,
    values_theme,
    {"hi mom","hi dad"}
)

local txt_theme = alib.theme:new(
    'Verdana',
    nil, nil, alib.rgba(255,255,255), nil
)

local txt = alib.text:new(
    'textlolo',
    20,150,
    window,
    txt_theme,
    'hello mom'
)

callbacks.Register( "Draw", 'render' ,function()
    window:render()
    button:render()
    topbar:render()
    slider:render()
    checkbox:render()
    combobox:render()
    txt:render()
end)

callbacks.Register("Unload", function()

    for k,v in pairs (window:getchildren()) do
        v.visible = false
    end

    callbacks.Unregister('Draw','render')
end)