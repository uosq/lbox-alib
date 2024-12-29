--[[
Loads from the latest version on the repo
WARNING: will freeze the game every time for a few seconds if its not already loaded
--]]

--- return the already loaded module if it exists so we dont have to do all the stuff below
if package.loaded["alib"] then
   return package.loaded["alib"]
end

local ALIB_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/source.lua"
local CHANGELOG_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/changelog"
local latest_version = http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/latest_version")

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
end

local alib = get_alib()
local changelog = get_changelog()

printc(150, 255, 150, 255, "Changelog:", changelog)

---@type table
local loaded = load(alib)()
package.loaded["alib"] = loaded
return loaded
