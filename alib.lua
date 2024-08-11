---@class RGB
---@field r number RED value
---@field g number GREEN value 
---@field b number BLUE value
---@field opacity number OPACITY value from 0-1 range

---@class Theme
---@field background_color RGB
---@field outline_thickness number Thickness of the outline (border)
---@field outline_color RGB Color of the outline (border)
---@field text_color RGB Color of the text
---@field selected_color RGB
---@field font Font

---@class Window
---@field name string Name of the window
---@field x number X position
---@field y number Y position
---@field width number Width of the window
---@field height number Height of the window
---@field theme Theme
---@field enabled boolean If it's disabled
---@field background_color RGB Background color of the window
---@field children table Gets all objects below it (children, literally)

---@class Button
---@field name string Name of the button
---@field text string
---@field x number X position
---@field y number Y position
---@field width number Width of the button
---@field theme Theme
---@field parent Window
---@field height number Height of the button
---@field enabled boolean If it's disabled
---@field selectable boolean
---@field click function Called when clicked
---@field last_clicked_tick number please don't change this manually

---@class Slider
---@field name string The name of the slider
---@field x number
---@field y number
---@field width number The width (horizontal length)
---@field height number The height (vertical length)
---@field theme Theme The theme
---@field click function The function called when clicked
---@field parent Window The window above it
---@field min number The lowest the slider can go
---@field max number The highest the slider can go
---@field value number The current value
---@field enabled boolean If it's enabled
---@field selectable boolean If you can click on the slider

---@class Checkbox
---@field name string The name of the checkbox
---@field x number
---@field y number
---@field width number The width (horizontal length)
---@field height number The height (vertical length)
---@field checked boolean If it's true or false
---@field selectable boolean If you can click on the slider
---@field theme Theme The theme
---@field enabled boolean If it's enabled
---@field size number

---@class Combobox
---@field name string
---@field parent Window
---@field x number
---@field y number
---@field width number
---@field height number
---@field theme Theme
---@field items table
---@field selected_item number
---@field displaying_items boolean
---@field enabled boolean
---@field selectable boolean

---@class Text
---@field x number
---@field y number
---@field text string
---@field color RGB
---@field font Font

local function unload()
    callbacks.Unregister("Draw","mouse_manager")
    package.loaded.alib = nil
end

local function is_mouse_inside(object)
    local mousePos = input.GetMousePos()
    local mx, my = mousePos[1], mousePos[2]
    if (mx < object.x) then return false end
    if (mx > object.x + object.width) then return false end
    if (my < object.y) then return false end
    if (my > object.y + object.height) then return false end
    return true
end

---@param number number
---@param min number
---@param max number
local function clamp(number, min, max)
    number = (number < min and min or number)
    number = (number > max and max or number)
    assert(number, "error: number is nil or false")
    return number
end

---@param font Font
---@param x number
---@param y number
---@param text string
local function draw_colored_text(color, font, x, y, text)
    draw.Color(color.r,color.g,color.b,color.opacity)
    draw.SetFont(font)
    draw.Text(x, y, text)
end


---@param font string
local function create_font(font)
    local success,result = pcall(draw.CreateFont, font, 12, 1000)
    assert(success, string.format("error: couldn't create font %s\n%s", font, tostring(result)))
    return result
end

---@param red number
---@param green number
---@param blue number
---@param opacity number
---@return RGB
local function rgb(red, green, blue, opacity)
    return {
        r = clamp(red, 0, 255),
        g = clamp(green, 0, 255),
        b = clamp(blue, 0, 255),
        opacity = clamp(opacity, 0, 255)
    }
end

---@param font string
---@param background_color RGB
---@param text_color RGB
---@param outline_color RGB
---@param outline_thickness number
---@return Theme
local function create_theme(font, background_color, selected_color, text_color, outline_color, outline_thickness)
    return {
        background_color = background_color,
        selected_color = selected_color,
        text_color = text_color,
        outline_color = outline_color,
        outline_thickness = outline_thickness,
        font = create_font(font)
    }
end

---@param name string
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme Theme
---@return Window
local function create_window (name, x, y, width, height, theme)
    return {
        name = name,
        x = x, y = y, width = width, height = height,
        theme = theme,
        enabled = true,
        children = {},
    }
end

---@param window Window
local function render_window(window)
    if window.enabled == false or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end
    draw.Color(window.theme.background_color.r, window.theme.background_color.g, window.theme.background_color.b, window.theme.background_color.opacity)
    draw.FilledRect(window.x, window.y , window.x + window.width, window.y + window.height)
    for i = 1, window.theme.outline_thickness do
        draw.OutlinedRect(window.x - 1 * i, window.y - 1 * i, window.x + window.width + 1 * i, window.y + window.height + 1 * i)
    end
end

---@param window Window
local function window_getchildren(window)
    local children = {}
    assert(window.children, string.format("warning: window %s has no children. Is this a mistake?", window.name))
    for i = 1, #window.children do
        children[#children+1] = window.children[i]
    end
    return children
end

---@param window Window
local function window_init(window)
    callbacks.Unregister("Draw", "mouse_manager")
    callbacks.Register("Draw", "mouse_manager", function()
        local state, tick = input.IsButtonPressed(MOUSE_LEFT)
        for k,v in pairs(window_getchildren(window)) do
            if v.enabled and v.selectable and is_mouse_inside(v) and state and tick ~= v.last_clicked_tick and v.click then
                v.click()
            end
            v.last_clicked_tick = tick
        end
    end)
end

---@param name string
---@param text string
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme Theme
---@param parent Window
---@param click function
local function create_button(name, text, x, y, width, height, theme, parent, click)
    local button = {
        name = name, text = text,
        x = parent.x + x, y = parent.y + y, width = width, height = height,
        theme = theme,
        parent = parent,
        enabled = true, selectable = true,
        click = click,
        last_clicked_tick = nil,
    }
    assert(button, string.format("error: couldn't create button %s", name))
    parent.children[#parent.children+1] = button
    return button
end

---@param button Button
local function render_button (button)
    if button.enabled == false or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end
    
    if is_mouse_inside(button) then
        draw.Color(button.theme.selected_color.r, button.theme.selected_color.g, button.theme.selected_color.b, button.theme.selected_color.opacity)
    else
        draw.Color(button.theme.background_color.r, button.theme.background_color.g, button.theme.background_color.b, button.theme.background_color.opacity)
    end
    draw.FilledRect(button.x, button.y, button.x + button.width, button.y + button.height)
    
    draw.SetFont(button.theme.font)
    draw.Color(button.theme.text_color.r, button.theme.text_color.g, button.theme.text_color.b, button.theme.text_color.opacity)
    local tx, ty = draw.GetTextSize(button.text)
    draw.Text( button.x + button.width/2 - math.floor(tx/2), button.y + button.height/2 - math.floor(ty/2), button.text )
    
    for i = 1, button.theme.outline_thickness do
        draw.OutlinedRect(button.x - 1 * i, button.y - 1 * i, button.x + button.width + 1 * i, button.y + button.height + 1 * i)
    end
end

---@param name string
---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@param theme Theme
---@param parent Window
---@param min number
---@param max number
---@param value number
---@return Slider
local function create_slider(name, x, y, width, height, text, theme, parent, min, max, value)
    local slider = {
        name = name,
        x = parent.x + x, y = parent.y + y, width = width, height = height,
        theme = theme,
        parent = parent,
        min = min, max = max, value = value,
        last_clicked_tick = nil,
        selectable = true,
        enabled = true,
    }
    slider.click = function()
        callbacks.Register("Draw", "sliderclicks", function()
            if input.IsButtonDown(MOUSE_LEFT) and is_mouse_inside(slider) and slider.selectable and slider.enabled then
                local mx = input.GetMousePos()[1]
                local initial_mouse_pos = mx - slider.x
                local new_value = slider.min + (initial_mouse_pos/slider.width) * (slider.max - slider.min)
                slider.value = clamp(new_value, slider.min, slider.max)
            else
                callbacks.Unregister( "Draw", "sliderclicks" )
            end
        end)
    end
    assert(slider, string.format("error: couldn't create slider %s", name))

    parent.children[#parent.children+1] = slider
    return slider
end

---@param slider Slider
local function render_slider(slider)
    if slider.enabled == false or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    draw.Color(slider.theme.background_color.r, slider.theme.background_color.g, slider.theme.background_color.b, slider.theme.background_color.opacity)
    local slider_percent = (slider.value - slider.min) / slider.max - slider.min
    draw.FilledRect(slider.x, slider.y, slider.x + slider.width * slider_percent, slider.y + slider.height)
end

---@param name string
---@param x number
---@param y number
---@param size number
---@param theme Theme
---@param parent Window
---@param click function
---@return Checkbox
---it uses selected_color as the color used when checked and text_color as unchecked
local function create_checkbox(name, x, y, size, theme, parent, click)
    local checkbox = {
        name = name,
        x = parent.x + x, y = parent.y + y, width = 1 * size, height = 1 * size,
        theme = theme,
        parent = parent,
        enabled = true,
        selectable = true,
        checked = false,
        last_clicked_tick = nil,
    }
    checkbox.click = function ()
        checkbox.checked = not checkbox.checked
        click(checkbox)
    end
    assert(checkbox, string.format("error: couldn't create checkbox %s", name))
    parent.children[#parent.children+1] = checkbox
    return checkbox
end

---@param checkbox Checkbox
local function render_checkbox(checkbox)
    if checkbox.enabled == false or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    draw.Color(checkbox.theme.background_color.r, checkbox.theme.background_color.g, checkbox.theme.background_color.b, checkbox.theme.background_color.opacity)
    for i = 1, checkbox.theme.outline_thickness do
        draw.OutlinedRect(checkbox.x - 1 * i, checkbox.y - 1 * i, checkbox.x + checkbox.width + 1 * i, checkbox.y + checkbox.height + 1 * i)
    end

    if checkbox.checked then
        draw.Color(checkbox.theme.selected_color.r, checkbox.theme.selected_color.g, checkbox.theme.selected_color.b, checkbox.theme.selected_color.opacity)
    else
        draw.Color(checkbox.theme.text_color.r, checkbox.theme.text_color.g, checkbox.theme.text_color.b,checkbox.theme.text_color.opacity)
    end
    draw.FilledRect(checkbox.x, checkbox.y, checkbox.x + checkbox.width, checkbox.y + checkbox.height)
end

local function create_combobox_button (parent, index, height, item)
    local combobox_button = {
        parent = parent,
        height = height,
        index = index,
        item = item,
        x = parent.x,
        y = parent.y + (index * height) + (parent.theme.outline_thickness or 0),
    }

    combobox_button.click = function()
        if not parent.displaying_items then return end
        parent.selected_item = index
        parent.click()
    end

    return combobox_button
end

local function render_combobox_button(combobox_button)
    if not combobox_button.parent.displaying_items or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    if is_mouse_inside(combobox_button) then
        draw.Color(combobox_button.parent.theme.selected_color.r, combobox_button.parent.theme.selected_color.g, combobox_button.parent.theme.selected_color.b, combobox_button.parent.theme.selected_color.opacity)
    else
        draw.Color(combobox_button.theme.background_color.r, combobox_button.theme.background_color.g, combobox_button.theme.background_color.b, combobox_button.theme.background_color.opacity)
    end
    draw.FilledRect (combobox_button.x, combobox_button, combobox_button.x + combobox_button.parent.width, combobox_button.y + combobox_button.parent.height)

    local tx, ty = draw.GetTextSize(combobox_button.parent.items[combobox_button.index])
    draw.SetFont(combobox_button.parent.theme.font)
    draw.Text( combobox_button.x + combobox_button.parent.width/2 - math.floor(tx/2), combobox_button.y + combobox_button.height/2 - math.floor(ty/2), combobox_button.parent.items[combobox_button.index] )
end

---@param name string
---@param parent Window
---@param x number
---@param y number
---@param width number
---@param height number
---@param theme Theme
---@param items table
---@return Combobox
local function create_combobox(name, parent, x, y, width, height, theme, items)
    local combobox = {
        name = name,
        parent = parent,
        x = parent.x + x, y = parent.y + y, width = width, height = height,
        theme = theme,
        items = items,
        last_clicked_tick = nil,
        selected_item = 1,
        displaying_items = false, enabled = true, selectable = true,
    }

    combobox.click = function()
        combobox.displaying_items = not combobox.displaying_items
        
        for k,v in pairs(window_getchildren(combobox.parent)) do
            if v ~= combobox then
                v.selectable = not combobox.displaying_items
            end
        end
    end

    return combobox
end

---@param combobox Combobox
local function render_combobox(combobox)
    if not combobox.enabled or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    if is_mouse_inside(combobox) then
        draw.Color(combobox.theme.selected_color.r, combobox.theme.selected_color.g, combobox.theme.selected_color.b, combobox.theme.selected_color.opacity)
    else
        draw.Color(combobox.theme.background_color.r, combobox.theme.background_color.g, combobox.theme.background_color.b, combobox.theme.background_color.opacity)
    end
    draw.FilledRect(combobox.x, combobox.y, combobox.x + combobox.width, combobox.y + combobox.height)

    draw.SetFont(combobox.theme.font)
    draw.Color(combobox.theme.text_color.r, combobox.theme.text_color.g, combobox.theme.text_color.b, combobox.theme.text_color.opacity)
    local tx, ty = draw.GetTextSize(combobox.items[combobox.items[combobox.selected_item]])
    draw.Text( combobox.x + combobox.parent.width/2 - math.floor(tx/2), combobox.y + combobox.height/2 - math.floor(ty/2), tostring(combobox.items[combobox.selected_item]) )

    for i = 1, combobox.theme.outline_thickness do
        draw.OutlinedRect(combobox.x - 1 * i, combobox.y - 1 * i, combobox.x + combobox.width + 1 * i, combobox.y + combobox.height + 1 * i)
    end

    if not combobox.displaying_items then return end

    -- probably not the best idea to create and render it on the rendering part lol
    for k,v in ipairs(combobox.items) do
        local combbutton = create_combobox_button(combobox, k, 20, v)
        render_combobox_button(combbutton)
    end
end

-- i wasn't planning on adding text like this, but it's for consistency
---@param color RGB
---@param x number
---@param y number
---@param text string
---@return Text
local function create_text(color, x, y, font, text)
    return {
        color = color,
        x = x,
        font = create_font(font),
        y = y,
        text = text
    }
end

---@param text Text
local function render_text(text)
    draw_colored_text(text.color, text.font, text.x, text.y, text.text)
end

local lib = {
    version = 0.35,
    window = {create = create_window, render = render_window, init = window_init, getchildren = window_getchildren},
    button = {create = create_button, render = render_button},
    slider = {create = create_slider, render = render_slider},
    checkbox = {create = create_checkbox, render = render_checkbox},
    combobox = {create = create_combobox, render = render_combobox},
    theme = create_theme,
    text = {create = create_text, render = render_text},
    create_font = create_font,
    rgb = rgb,
    clamp = clamp,
    unload = unload
}

local known_bugs = {
    "i didn't have enough time to test 0.35 yet"
}

printc( 255,100,100,255, "known bugs:" )
for k,v in pairs (known_bugs) do
    printc(255,100,100,255, tostring(v))
end

return lib
