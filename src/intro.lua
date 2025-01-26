local misc = require("src.misc")
local settings = require("src.settings")
local shapes = require("src.shapes")
local config = require("src.config")

local Math = require("src.usefulmath")
local window = require("objects.window")
local buttonfade = require("objects.buttonfade")

local intro = {}

---@enum intro_states
local intro_states = {
   START = 0,
   LOGO = 1,
   LOGO_FINISHED = 2,
   THEME_SELECTOR = 3,
   FINISHED = 4,
}

intro.states = intro_states
_G["alib state"] = intro.states.START

function intro.init()
   local big_font, version_font
   local screenW, screenH
   local centerX, centerY

   local alibW, alibH
   local alibX, alibY

   local versionW

   --- logo variables
   local color = {}
   local color_variants = { { 255, 255, 255, 255 }, { 60, 60, 60, 255 } }
   local chosen_text_color = color_variants[math.random(1, #color_variants)]
   local degrees = 0
   ---	
   local last_tick = 0
   --- theme selector variables
   local files = {}
   local files_without_extension = {}
   local selected_file = -1
   local themeTEXT = "Themes were found, do you want to load one?"
   local themeTW, themeTH, themeTX, themeTY
   local theme_window = {}
   local load_button = {}
   local close_button = {}
   local list = {}
   ---

   local function intro_start()
      big_font = draw.CreateFont("TF2 BUILD", 128, 1000)
      version_font = draw.CreateFont("TF2 BUILD", 24, 1000)
      screenW, screenH = draw.GetScreenSize()
      centerX, centerY = math.floor(screenW / 2), math.floor(screenH / 2)

      draw.SetFont(big_font)
      alibW, alibH = draw.GetTextSize("ALIB")
      alibX, alibY = centerX - math.floor(alibW / 2), centerY - math.floor(alibH / 2)

      draw.SetFont(version_font)
      versionW = draw.GetTextSize(version)

      draw.SetFont(settings.font)
      themeTW, themeTH = draw.GetTextSize(themeTEXT)

      _G["alib state"] = intro.states.LOGO
      return true
   end

   local function intro_logo()
      local tick_count = globals.TickCount()
      if tick_count > last_tick then
         last_tick = tick_count + Math.Time2Ticks(0.01)

         degrees = degrees + 1
         if degrees >= 360 then
            _G["alib state"] = intro.states.LOGO_FINISHED
            return
         end

         local r, g, b = Math.Hsv_to_RGB(degrees, 1, 1)
         r, g, b = math.floor(r), math.floor(g), math.floor(b)
         color = { r, g, b, 255 }
      end

      misc.change_color(color)
      shapes.triangle(alibX + 64, alibY + math.floor(alibH / 2) + 64, 128)

      draw.SetFont(big_font)
      misc.change_color(color)
      draw.Text(alibX + 2, alibY + 2, "ALIB")

      misc.change_color(chosen_text_color)
      draw.Text(alibX, alibY, "ALIB")

      misc.change_color({ 255, 255, 255, 255 })
      draw.SetFont(version_font)
      draw.TextShadow(alibX - math.floor(versionW / 2) + math.floor(alibW / 2), alibY + math.floor(alibH), version)
   end

   local function intro_logo_finished()
      filesystem.EnumerateDirectory("alib/themes/*.json", function(filename, attributes)
         files[#files + 1] = filename
         files_without_extension[#files_without_extension + 1] = filename:sub(1, #filename - 5)
      end)

      if #files > 1 then
         theme_window.width = math.floor(themeTW) + 5
         theme_window.height = Math.GetListHeight(#files) + 85
         theme_window.x = centerX - math.floor(theme_window.width / 2)
         theme_window.y = centerY - math.floor(theme_window.height / 2)

         load_button.width = 100
         load_button.height = 30
         load_button.x = theme_window.x + math.floor(theme_window.width / 2) - load_button.width
         load_button.y = theme_window.y + theme_window.height - 33

         close_button.width = 100
         close_button.height = 30
         close_button.x = load_button.x + load_button.width + 4
         close_button.y = load_button.y

         themeTX = theme_window.x + math.floor(theme_window.width / 2) - math.floor(themeTW / 2)
         themeTY = theme_window.y + math.floor(themeTH) + 2

         list.width = theme_window.width
         list.x = theme_window.x + math.floor(theme_window.width / 2) - math.floor(list.width / 2)
         list.y = themeTY + math.floor(themeTH) + 10

         _G["alib settings"] = intro.states.THEME_SELECTOR
         return
      end

      _G["alib settings"] = intro.states.FINISHED
   end

   local function intro_theme_selector()
      input.SetMouseInputEnabled(true)
      local load_mouse_inside = Math.isMouseInside(nil, load_button)
      local close_mouse_inside = Math.isMouseInside(nil, close_button)

      local state, tick = input.IsButtonPressed(E_ButtonCode.MOUSE_LEFT)
      if state and tick ~= last_tick then
         last_tick = tick
         for i, v in ipairs(files) do
            local mouse_inside = Math.isMouseInside(nil, list, "ITEM", i)
            if mouse_inside and Math.IsButtonDown(E_ButtonCode.MOUSE_LEFT) then
               selected_file = i
            end
         end

         if load_mouse_inside then
            if files[selected_file] then
               config.load_settings(files[selected_file])
               _G["alib settings"] = settings
            end
         elseif close_mouse_inside then
            input.SetMouseInputEnabled(false)
            _G["alib state"] = intro.states.FINISHED
            return
         end
      end

      window(theme_window.width, theme_window.height, theme_window.x, theme_window.y, "theme selector")
      list(list.width, list.x, list.y, selected_file, files_without_extension)
      buttonfade(load_mouse_inside, load_button.width, load_button.height, load_button.x, load_button.y, 255, 50,
         false,
         "load")
      buttonfade(close_mouse_inside, close_button.width, close_button.height, close_button.x, close_button.y, 255,
         50, false, "close")

      draw.TextShadow(themeTX, themeTY, themeTEXT)
   end

   local function intro_finished()
      big_font, version_font = nil, nil
      screenW, screenH = nil, nil
      centerX, centerY = nil, nil
      alibW, alibH = nil, nil
      alibX, alibY = nil, nil
      versionW = nil
      color = nil
      color_variants = nil
      chosen_text_color = nil
      ---@diagnostic disable-next-line: cast-local-type
      degrees = nil
      ---@diagnostic disable-next-line: cast-local-type
      last_tick = nil
      files = nil
      files_without_extension = nil
      ---@diagnostic disable-next-line: cast-local-type
      selected_file = nil
      ---@diagnostic disable-next-line: cast-local-type
      themeTEXT = nil
      themeTW, themeTH = nil, nil
      theme_window = nil
      load_button = nil
      close_button = nil
      list = nil
      collectgarbage("collect")
      callbacks.Unregister("Draw", "alib intro draw")
   end

   callbacks.Register("Draw", "alib intro draw", function()
      if _G["alib state"] == intro.states.START then
         intro_start()
      elseif _G["alib state"] == intro.states.LOGO then
         intro_logo()
      elseif _G["alib state"] == intro.states.LOGO_FINISHED then
         intro_logo_finished()
      elseif _G["alib state"] == intro.states.THEME_SELECTOR then
         intro_theme_selector()
      elseif _G["alib state"] == intro.states.FINISHED then
         intro_finished()
      end
   end)
end

return intro
