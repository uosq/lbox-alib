local settings                  = require("src.settings")
local misc                      = require("src.misc")
local intro                     = require("src.intro")
local config                    = require("src.config")

local window                    = require("objects.window")
local windowfade                = require("objects.windowfade")
local button                    = require("objects.button")
local buttonfade                = require("objects.buttonfade")
local checkbox                  = require("objects.checkbox")
local slider                    = require("objects.slider")
local sliderfade                = require("objects.sliderfade")
local list                      = require("objects.list")
local verticalslider            = require("objects.verticalslider")
local verticalsliderfade        = require("objects.verticalsliderfade")

local Math                      = require("src.usefulmath")
local shapes                    = require("src.shapes")

local alib                      = {}
alib.settings                   = settings
alib.misc                       = misc
alib.math                       = Math

alib.objects                    = {}
alib.objects.window             = window
alib.objects.windowfade         = windowfade
alib.objects.button             = button
alib.objects.buttonfade         = buttonfade
alib.objects.checkbox           = checkbox
alib.objects.slider             = slider
alib.objects.sliderfade         = sliderfade
alib.objects.list               = list
alib.objects.verticalslider     = verticalslider
alib.objects.verticalsliderfade = verticalsliderfade

alib.shapes                     = shapes

--- create just in case we dont have it
config.create_default_config("default")

intro.init()

return alib
