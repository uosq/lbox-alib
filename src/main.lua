local theme = require ("ui.theme")
local window = require "ui.window"
local utils = require "ui.utils"
local slider = require "ui.slider"
error("don't download main.lua!")
---//
local lib = {
   window = window,
   theme = theme,
   utils = utils,
   slider = slider,
}

return lib