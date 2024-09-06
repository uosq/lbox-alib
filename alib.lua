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
---@field percent number
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
---@field combbuttons table
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

---@class Round_Button
---@field name string The button's name
---@field text string The button's text
---@field parent Window the button's parent Window
---@field x number
---@field y number
---@field width number Horizontal length
---@field height number Vertical length
---@field click function
---@field theme Theme
---@field selectable boolean
---@field enabled boolean
---@field roundness number How "round" the round button is

local function unload()
    local mouse_success = pcall(callbacks.Unregister, "Draw","mouse_manager")
    local combbuttons_success = pcall(callbacks.Unregister, "Draw", "combbuttons_manager")
    assert(mouse_success, "error: couldn't unregister mouse_manager")
    assert(combbuttons_success, "error: couldn't unregister combbuttons_manager")
    package.loaded.alib = nil
end

local function is_mouse_inside(object)
    local mousePos = input.GetMousePos()
    local mx, my = mousePos[1], mousePos[2]
    if (mx < object.x or my < object.y) then
        return false
    elseif (mx > object.x + object.width or my > object.y + object.height) then
        return false
    else
        return true
    end
end

---@param number number
---@param min number
---@param max number
local function clamp(number, min, max)
    assert(number, "error: number is nil")
    assert(min, "error: min is nil")
    assert(max, "error: max is nil")
    number = (number < min and min or number)
    number = (number > max and max or number)
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
local function create_font(font, font_size)
    local success, result = pcall(draw.CreateFont, font, font_size, 1000)
    assert(success, string.format("error: couldn't create font %s\n%s", font, tostring(result)))
    return result
end

---@param theme_select RGB
local function change_color(theme_select)
    draw.Color(theme_select.r, theme_select.g, theme_select.b, theme_select.opacity)
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
local function create_theme(font, font_size, background_color, selected_color, text_color, outline_color, outline_thickness)
    return {
        background_color = background_color,
        selected_color = selected_color,
        text_color = text_color,
        outline_color = outline_color,
        outline_thickness = outline_thickness,
        font = create_font(font, font_size)
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
    assert(type(name) == "string", "window name is not a string")
    assert(type(x) == "number", "window x is not a number")
    assert(type(y) == "number", "window y is not a number")
    assert(type(width) == "number", "window width is not a number")
    assert(type(height) == "number", "window height is not a number")
    assert(type(theme) == "table", "window theme is not a Theme (table)")
    return {
        name = name,
        x = x, y = y, width = width, height = height,
        theme = theme,
        enabled = true,
        children = {},
        type = "window",
    }
end

---@param window Window
local function render_window(window)
    assert(type(window) == "table", string.format("%s is not a window (table)", tostring(window)))
    if window.enabled == false or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end
    change_color(window.theme.background_color)
    draw.FilledRect(window.x, window.y , window.x + window.width, window.y + window.height)
    change_color(window.theme.outline_color)
    for i = 1, window.theme.outline_thickness do
        draw.OutlinedRect(window.x - 1 * i, window.y - 1 * i, window.x + window.width + 1 * i, window.y + window.height + 1 * i)
    end
end

---@param window Window
local function window_getchildren(window)
    assert(window.children, string.format("error: window %s has no children or window.children is nil. Is this a mistake?", window.name))
    local children = {}
    for i = 1, #window.children do
        children[#children+1] = window.children[i]
    end
    return children
end

---@param window Window
local function window_init(window)
    assert(type(window) == "table", string.format("%s is not a window (table)", tostring(window)))
    callbacks.Unregister("Draw", "mouse_manager")
    callbacks.Register("Draw", "mouse_manager", function()
        for k,v in pairs(window_getchildren(window)) do
            local state, tick = input.IsButtonPressed(MOUSE_LEFT)
            if v.enabled and v.selectable and is_mouse_inside(v) and state and tick ~= v.last_clicked_tick and v.click then
                assert(pcall(v.click, v), string.format("error: couldn't call .click() on %s.init()", tostring(v.parent.name)))
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
    assert(type(name) == "string", "button name is not a string")
    assert(type(text) == "string", "button text is not a string")
    assert(type(x) == "number", "button x is not a number")
    assert(type(y) == "number", "button y is not a number")
    assert(type(width) == "number", "button width is not a number")
    assert(type(height) == "number", "button height is not a number")
    assert(type(theme) == "table", "button theme is not a Theme (table)")
    assert(type(parent) == "table", "button parent is not a window (table)")
    assert(type(click) == "function", "button click is not a function")
    local button = {
        name = name, text = text,
        x = parent.x + x, y = parent.y + y, width = width, height = height,
        theme = theme,
        parent = parent,
        enabled = true, selectable = true,
        click = click,
        last_clicked_tick = nil,
        type = "button",
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
        change_color(button.theme.selected_color)
    else
        change_color(button.theme.background_color)
    end
    draw.FilledRect(button.x, button.y, button.x + button.width, button.y + button.height)

    draw.SetFont(button.theme.font)
    change_color(button.theme.text_color)
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
---@param theme Theme
---@param parent Window
---@param min number
---@param max number
---@param value number
---@return Slider
local function create_slider(name, x, y, width, height, theme, parent, min, max, value)
    assert(type(name) == "string", "slider name is not a string")
    assert(type(x) == "number", "slider x is not a number")
    assert(type(y) == "number", "slider y is not a number")
    assert(type(width) == "number", "slider width is not a number")
    assert(type(height) == "number", "slider height is not a number")
    assert(type(parent) == "table", "slider parent is not a window (table)")
    assert(type(min) == "number", "slider min is not a number")
    assert(type(max) == "number", "slider max is not a number")
    assert(type(value) == "number", "slider value is not a number")
    local slider = {
        name = name,
        x = parent.x + x, y = parent.y + y, width = width, height = height,
        theme = theme,
        parent = parent,
        min = min, max = max, value = value, percent = (value - min) / max - min,
        last_clicked_tick = nil,
        selectable = true,
        enabled = true,
        type = "slider"
    }
    slider.click = function()
        callbacks.Register("Draw", "sliderclicks", function()
            if input.IsButtonDown(MOUSE_LEFT) and is_mouse_inside(slider) and slider.selectable and slider.enabled then
                local mx = input.GetMousePos()[1]
                local initial_mouse_pos = mx - slider.x
                local new_value = clamp(slider.min + ((initial_mouse_pos/slider.width) * (slider.max - slider.min)), slider.min, slider.max)
                slider.value = new_value
                slider.percent = (new_value - slider.min) / slider.max - slider.min
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

    change_color(slider.theme.outline_color)
    for i = 1, slider.theme.outline_thickness do
        draw.OutlinedRect(slider.x - 1 * i, slider.y - 1 * i, slider.x + slider.width + 1 * i, slider.y + slider.height + 1 * i)
    end

    change_color(slider.theme.background_color)
    draw.FilledRect(slider.x, slider.y, slider.x + slider.width, slider.y + slider.height)

    change_color(slider.theme.selected_color)
    draw.FilledRect(slider.x, slider.y, slider.x + slider.width * slider.percent, slider.y + slider.height)
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
    assert(type(name) == "string", "checkbox name is not string")
    assert(type(x) == "number", "checkbox x is not a number")
    assert(type(y) == "number", "checkbox y is not a number")
    assert(type(size) == "number", "checkbox size is not a number")
    assert(type(theme) == "table", "checkbox theme is not a Theme (table)")
    assert(type(parent) == "table", "checkbox parent is not a window (table)")
    assert(type(click) == "function", "checkbox click is not a function")
    local checkbox = {
        name = name,
        x = parent.x + x, y = parent.y + y, width = 1 * size, height = 1 * size,
        theme = theme,
        parent = parent,
        enabled = true,
        selectable = true,
        checked = false,
        last_clicked_tick = nil,
        type = "checkbox",
    }
    checkbox.click = function ()
        checkbox.checked = not checkbox.checked
        assert(pcall(click,checkbox), string.format("error: couldn't call .click() from checkbox %s", checkbox.name))
    end
    assert(checkbox, string.format("error: couldn't create checkbox %s", checkbox.name))
    parent.children[#parent.children+1] = checkbox
    return checkbox
end

---@param checkbox Checkbox
local function render_checkbox(checkbox)
    if checkbox.enabled == false or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    change_color(checkbox.theme.background_color)
    for i = 1, checkbox.theme.outline_thickness do
        draw.OutlinedRect(checkbox.x - 1 * i, checkbox.y - 1 * i, checkbox.x + checkbox.width + 1 * i, checkbox.y + checkbox.height + 1 * i)
    end

    if checkbox.checked then
        change_color(checkbox.theme.selected_color)
    else
        change_color(checkbox.theme.text_color)
    end
    draw.FilledRect(checkbox.x, checkbox.y, checkbox.x + checkbox.width, checkbox.y + checkbox.height)
end

local function create_combobox_button(parent, index, item)
    local combobox_button = {
        parent = parent,
        height = parent.height,
        width = parent.width,
        index = index,
        item = item,
        x = parent.x,
        y = parent.y + (index * parent.height),
    }

    combobox_button.click = function()
        parent.selected_item = index
        assert(pcall(parent.click), string.format("error: couldn't call .click() from combobox item %s", item))
    end

    assert(combobox_button, string.format("error: couldn't create combobox item %s", item))
    return combobox_button
end

local function render_combobox_button(combobox_button)
    if not combobox_button.parent.displaying_items or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    if is_mouse_inside(combobox_button) then
        change_color(combobox_button.parent.theme.selected_color)
    else
        change_color(combobox_button.parent.theme.background_color)
    end
    draw.FilledRect(combobox_button.x, combobox_button.y, combobox_button.x + combobox_button.parent.width, combobox_button.y + combobox_button.height)

    change_color(combobox_button.parent.theme.outline_color)
    for i = 1, combobox_button.parent.theme.outline_thickness do
        draw.OutlinedRect(combobox_button.x - 1 * i, combobox_button.y - 1 * i, combobox_button.x + combobox_button.width + 1 * i, combobox_button.y + combobox_button.height + 1 * i)
    end

    draw.SetFont(combobox_button.parent.theme.font)
    change_color(combobox_button.parent.theme.text_color)
    local tx, ty = draw.GetTextSize(combobox_button.item)
    draw.Text(combobox_button.x + combobox_button.parent.width / 2 - math.floor(tx / 2), combobox_button.y + combobox_button.height / 2 - math.floor(ty / 2), combobox_button.item)
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
    assert(type(name) == "string" or type(name) == "number", "combobox name is not a string or number")
    assert(type(parent) == "table", "combobox parent is not a window (table)")
    assert(type(x) == "number", "combobox x is not a number")
    assert(type(y) == "number", "combobox y is not a number")
    assert(type(width) == "number", "combobox width is not a number")
    assert(type(height) == "number", "combobox height is not a number")
    assert(type(theme) == "table", "combobox theme is not a theme (table)")
    assert(type(items) == "table", "combobox items is not a table")
    local combobox = {
        name = name,
        parent = parent,
        x = parent.x + x, y = parent.y + y, width = width, height = height,
        theme = theme,
        items = items,
        last_clicked_tick = nil,
        selected_item = 1,
        displaying_items = false, enabled = true, selectable = true,
        type = "combobox",
    }

    combobox.combbuttons = {}
    for k, v in ipairs(combobox.items) do
        combobox.combbuttons[k] = create_combobox_button(combobox, k, v)
    end

    combobox.click = function()
        combobox.displaying_items = not combobox.displaying_items
        for k, v in pairs(window_getchildren(combobox.parent)) do
            if v ~= combobox then
                v.selectable = not combobox.displaying_items
            end
        end
    end

    assert(combobox, string.format("error: couldn't create combobox %s", name))
    parent.children[#parent.children+1] = combobox

    return combobox
end

---@param combobox Combobox
local function render_combobox(combobox)
    if not combobox.enabled or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    if is_mouse_inside(combobox) then
        change_color(combobox.theme.selected_color)
    else
        change_color(combobox.theme.background_color)
    end

    draw.FilledRect(combobox.x, combobox.y, combobox.x + combobox.width, combobox.y + combobox.height)

    draw.SetFont(combobox.theme.font)
    change_color(combobox.theme.text_color)
    local tx, ty = draw.GetTextSize(combobox.items[combobox.selected_item])
    draw.Text(combobox.x + combobox.width / 2 - math.floor(tx / 2), combobox.y + combobox.height / 2 - math.floor(ty / 2), tostring(combobox.items[combobox.selected_item]))

    for i = 1, combobox.theme.outline_thickness do
        draw.OutlinedRect(combobox.x - 1 * i, combobox.y - 1 * i, combobox.x + combobox.width + 1 * i, combobox.y + combobox.height + 1 * i)
    end

    if combobox.displaying_items then
        for k, comboboxbutton in ipairs(combobox.combbuttons) do
            if comboboxbutton then
                render_combobox_button(comboboxbutton)
            end
        end
    end
end

---@param combobox Combobox
local function combobox_init(combobox)
    callbacks.Unregister("Draw", "combbuttons_manager")
    callbacks.Register("Draw", "combbuttons_manager", function()
        local state = input.IsButtonPressed(MOUSE_LEFT)
        for k,v in pairs(combobox.combbuttons) do
            if is_mouse_inside(v) and state and v.click and v.parent.displaying_items then
                assert(pcall(v.click, v), string.format("error: couldn't call .click() from combobox %s", tostring(v.name)))
            end
        end
    end)
end

-- i wasn't planning on adding text like this, but it's for consistency
---@param color RGB
---@param x number
---@param y number
---@param text string
---@return Text
local function create_text(color, x, y, font, font_size, text)
    return {
        color = color,
        x = x,
        font = create_font(font, font_size),
        y = y,
        text = text
    }
end

---@param text Text
local function render_text(text)
    local success = pcall(draw_colored_text, text.color, text.font, text.x, text.y, text.text)
    assert(success, string.format("error: couldn't draw text %s", tostring(text)))
end

---@param name string
---@param text string
---@param parent Window
---@param x number
---@param theme Theme
---@param y number
---@param width number
---@param height number
---@param click function
---@return Round_Button
local function create_round_button(name, text, theme, parent, x, y, width, height, click)
    assert(type(name) == "string", "round button name is not a string")
    assert(type(text) == "string", "round button text is not a string")
    assert(type(theme) == "table", "round button theme is not a theme (table)")
    assert(type(parent) == "table", "round button parent is not a window (table)")
    assert(type(x) == "number", "round button x is not a number")
    assert(type(y) == "number", "round button y is not a number")
    assert(type(width) == "number", "round button width is not a number")
    assert(type(height) == "number", "round button height is not a number")
    assert(type(click) == "function", "round button click is not a function")
    local round_button = {
        name = tostring(name), text = tostring(text),
        parent = parent,
        x = parent.x + x, y = parent.y + y, width = width, height = height,
        last_clicked_tick = nil,
        selectable = true, enabled = true,
        theme = theme,
        click = click,
        type = "round_button"
    }
    assert(round_button, string.format("error: couldn't create round button %s", name))
    parent.children[#parent.children+1] = round_button
    return round_button
end

---@param round_button Round_Button
local function render_round_button(round_button)
    if round_button.enabled == false or (gui.GetValue("clean screenshots") == 1
    and engine.IsTakingScreenshot()) then return end

    local color

    if is_mouse_inside(round_button) then
        change_color(round_button.theme.selected_color)
        color = round_button.theme.selected_color
    else
        color = round_button.theme.background_color
        change_color(round_button.theme.background_color)
    end

    for i = round_button.height, 0, -1 do
        --left v
        draw.ColoredCircle(round_button.x + 3, round_button.y + math.ceil(round_button.height/2), math.floor(round_button.height/2) - 1 * i, color.r, color.g, color.b, color.opacity)
        -- right v
        draw.ColoredCircle(round_button.x + round_button.width - 3, round_button.y + math.ceil(round_button.height/2), math.floor(round_button.height/2) - 1 * i, color.r, color.g, color.b, color.opacity)
    end

    --left v
    draw.ColoredCircle(round_button.x + 3 - 1, round_button.y + math.ceil(round_button.height/2), math.floor(round_button.height/2), round_button.theme.outline_color.r, round_button.theme.outline_color.g, round_button.theme.outline_color.b, round_button.theme.outline_color.opacity)
    -- right v
    draw.ColoredCircle(round_button.x + round_button.width - 3 + 1, round_button.y + math.ceil(round_button.height/2), math.floor(round_button.height/2), round_button.theme.outline_color.r, round_button.theme.outline_color.g, round_button.theme.outline_color.b, round_button.theme.outline_color.opacity)

    change_color(color)
    draw.FilledRect(round_button.x, round_button.y, round_button.x + round_button.width, round_button.y + round_button.height)

    change_color(round_button.theme.outline_color)
    draw.Line(round_button.x, round_button.y, round_button.x + round_button.width, round_button.y)
    draw.Line(round_button.x, round_button.y + round_button.height, round_button.x + round_button.width, round_button.y + round_button.height)

    draw.SetFont(round_button.theme.font)
    change_color(round_button.theme.text_color)
    local tx, ty = draw.GetTextSize(round_button.text)
    draw.Text( round_button.x + round_button.width/2 - math.floor(tx/2), round_button.y + round_button.height/2 - math.floor(ty/2), round_button.text )
end

function string.split(s)
    local words = {}
    for word in string.gmatch(s, "%S+") do
        table.insert(words, word)
    end
    return words
end

---@param theme Theme
local function console_commands (theme)
    local object_list = {}

    local commands = {
        create = {
            window = function(props)
                local name, x, y, width, height = tostring(props[1]), tonumber(props[2]), tonumber(props[3]), tonumber(props[4]), tonumber(props[5])
                local window = create_window(name, x, y, width, height, theme)
                object_list[window.name] = window
                window_init(window)
            end,
            button = function(props)
                local name, text, x, y, width, height, parent = tostring(props[1]), tostring(props[2]), tonumber(props[3]), tonumber(props[4]), tonumber(props[5]), tonumber(props[6]), object_list[tostring(props[7])]
                local button = create_button(name, text, x, y, width, height, theme, parent, function()
                    print(string.format("clicked %s", tostring(props[1])))
                end)
                object_list[button.name] = button
            end,
            slider = function(props)
                local name, x, y, width, height, parent, min, max, val = tostring(props[1]), tonumber(props[2]), tonumber(props[3]), tonumber(props[4]), tonumber(props[5]), object_list[tostring(props[6])], tonumber(props[7]), tonumber(props[8]), tonumber(props[9])
                local slider = create_slider(name, x, y, width, height, theme, parent, min, max, val)
                object_list[slider.name] = slider
            end,
            checkbox = function(props)
                local name, x, y, size, parent = tostring(props[1]), tonumber(props[2]), tonumber(props[3]), tonumber(props[4]), object_list[tostring(props[5])]
                local checkbox = create_checkbox(name, x, y, size, theme, parent, function()end)
                object_list[checkbox.name] = checkbox
            end,
            combobox = function(props)
                local name, x, y, width, height, parent, items = tostring(props[1]), tonumber(props[2]), tonumber(props[3]), tonumber(props[4]), tonumber(props[5]), object_list[tostring(props[6])], string.split(table.concat(props, " ", 7))
                local combobox = create_combobox(name, parent, x, y, width, height, theme, items)
                object_list[combobox.name] = combobox
                combobox_init(combobox)
            end,
            roundbutton = function(props)
                local name, text, parent, x, y, width, height = tostring(props[1]), tostring(props[2]), object_list[tostring(props[3])], tonumber(props[4]), tonumber(props[5]), tonumber(props[6]), tonumber(props[7])
                local round_button = create_round_button(name, text, theme, parent, x, y, width, height, load(table.concat(props, " ", 8)))
                object_list[round_button.name] = round_button
            end
        },
        help = {
            window = function() print("name x y width height") end,
            button = function() print("name text x y width height parent") end,
            slider = function() print("name x y width height parent min max value") end,
            checkbox = function() print("name x y size parent") end,
            combobox = function() print("name x y width height parent items | items example: asdf awdad hello dad") end,
            round_button = function() print("name text x y width height click") end,
        }
    }

    callbacks.Unregister("SendStringCmd", "alib_commands")
    ---@param cmd StringCmd
    callbacks.Register("SendStringCmd","alib_commands", function(cmd)
        local split_cmd = string.split(cmd:Get())
        if split_cmd[1] ~= "alib" then return end
        local icmd = split_cmd[2]
        local obj_type = split_cmd[3]
        local props = string.split(table.concat(split_cmd, " ", 4))
        print(string.format("command: %s | obj_type: %s | props: %s", tostring(icmd), tostring(obj_type), tostring(table.concat(props, " "))))
        commands[icmd][obj_type](props)
        -- example of command ran: alib create window main_window 60 40 800 600 (main_window name; 60 x; 40 y; 800 width; 600 height)
    end)

    callbacks.Unregister("Draw", "alib_commands_render")
    callbacks.Register("Draw", "alib_commands_render", function()
        for k,v in pairs (object_list) do
            if v.type == "window" then
                render_window(v)
                elseif v.type == "button" then
                render_button(v)
                elseif v.type == "checkbox" then
                render_checkbox(v)
                elseif v.type == "slider" then
                render_slider(v)
                elseif v.type == "round_button" then
                render_round_button(v)
                elseif v.type == "combobox" then
                render_combobox(v)
            end
        end
    end)
end

local lib = {
    version = 0.36,
    window = {create = create_window, render = render_window, init = window_init, getchildren = window_getchildren},
    button = {create = create_button, render = render_button},
    round_button = {create = create_round_button, render = render_round_button},
    slider = {create = create_slider, render = render_slider},
    checkbox = {create = create_checkbox, render = render_checkbox},
    combobox = {create = create_combobox, render = render_combobox, init = combobox_init},
    theme = create_theme,
    text = {create = create_text, render = render_text},
    create_font = create_font,
    rgb = rgb,
    clamp = clamp,
    unload = unload,
    commands = console_commands,
}

local known_bugs = {
    "didn't find any",
    "please make a issue with any bugs!!!",
    "specially with console commands"
}

printc( 255,100,100,255, "known bugs:" )
for k,v in pairs (known_bugs) do
    printc(255,100,100,255, tostring(v))
end

printc(204,204,0, 255, "console commands:")
printc(100,255,100, 255, "alib create")
printc(100,255,100, 255, "alib help")
printc(204,204,0, 255, "example:")
printc(204,204,0, 255, "alib create window Main_Window 50 60 800 600")
return lib
