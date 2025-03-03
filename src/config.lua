local intro = require("src.intro")
local settings = require("src.settings")

local config = {}

---@return {(encode: fun(param: table):string), (decode: fun(json_string: string):table)}
local function load_json()
   ---Returns the file at version/tag
   ---@param link string
   ---@param version string
   local function get_file(link, version)
      local url = string.format(link, version)
      return http.Get(url)
   end

   local JSON_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/dependencies/json.lua"
   local json = get_file(JSON_LINK, version)
   local loaded = load(json)()
   return loaded
end

local function create_default_config(filename)
   local json = load_json()
   filesystem.CreateDirectory("alib")
   filesystem.CreateDirectory("alib/themes")
   local encoded = json.encode(settings)
   io.output("alib/themes/" .. filename .. ".json")
   io.write(encoded)
   io.flush()
   io.close()
end

--- create default config just in case its not made or outdated
if not _G["alib state"] == intro.states.FINISHED then
   create_default_config("default")
end

local function load_settings(filename)
   filesystem.CreateDirectory("alib")
   filesystem.CreateDirectory("alib/themes")
   local saved_settings = io.open("alib/themes/" .. filename)
   if saved_settings then
      local json = load_json()
      local data = json.decode(saved_settings:read("a"))
      for k, v in pairs(data) do
         settings[k] = v
      end
      printc(233, 245, 66, 255, "Settings loaded!")
   end
end

config.load_settings = load_settings
config.load_json = load_json
config.create_default_config = create_default_config

return config
