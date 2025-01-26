--[[
Loads from the latest version on the repo
WARNING: will freeze the game the first time its loaded!
--]]

--- return the already loaded module if it exists so we dont have to do all the stuff below
if package.loaded["alib"] then
   return package.loaded["alib"]
end

local json = require("dependencies.json")

--local ALIB_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/source.lua"
--local CHANGELOG_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/changelog"
local request = http.Get("https://api.github.com/repos/uosq/lbox-alib/releases/tags/0.44")

---@type GithubResult
local decoded = json.decode(request)
local latest_version = decoded.tag_name

local alib = ""

for index, asset in pairs(decoded.assets) do
   if asset.name == "source.lua" then
      alib = http.Get(asset.browser_download_url)
   elseif asset.name == "changelog" then
      printc(150, 255, 150, 255, "Changelog:", http.Get(asset.browser_download_url))
   end
end

--[[
---Returns the file at version/tag
---@param link string
---@param version string
local function get_file(link, version)
   local url = string.format(link, version)
   return http.Get(url)
end

local function get_changelog()
   return get_file(CHANGELOG_LINK, latest_version)
end

local function get_alib()
   return get_file(ALIB_LINK, latest_version)
end]]

---@type table
local loaded = load(alib)()

local function unload()
   local mem_before = collectgarbage("count")

   callbacks.Unregister("Draw", "alib unstable version")
   callbacks.Unregister("Draw", "alib intro draw")

   -- Clean up package cache
   package.loaded["alib"] = nil
   package.loaded["source"] = nil
   _G["alib state"] = nil
   _G["alib settings"] = nil
   loaded = nil

   -- Force garbage collection
   collectgarbage("collect")
   local mem_after = collectgarbage("count")

   local cleaned = tostring(mem_before - mem_after / 1024)

   print("Unloaded alib")
   print("Collected " .. cleaned .. " MB of used memory")
end

loaded.unload = unload
return loaded
