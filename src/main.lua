local window = require "ui.window"
local color = require "ui.utils.color"
local theme = require "ui.utils.theme"
local utils = require "ui.utils.utils"
local button = require "ui.button"
local slider = require "ui.slider"
local checkbox = require "ui.checkbox"
local combobox = require "ui.combobox"
---//

debug = nil

local lib = {
   window = window,
   button = button,
   slider = slider,
   checkbox = checkbox,
   combobox = combobox,
   color = color,
   theme = theme,
   utils = utils
}

return lib