local latest_version = http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/latest_version")

local updater_version = "0.38.4"
local should_update = false

local function get_version(str)
   local removed = string.gsub(str, "local version = ", "")
   return string.sub(removed, 2, #removed-1)
end

local alib_file = io.open("alib/alib.lua")
local local_version = "none"
if alib_file then
   local_version = get_version(alib_file:read()) -- reads first line
   should_update = local_version ~= latest_version
   alib_file:close()
else
   should_update = true
end

if should_update then
   if updater_version ~= latest_version then
      printc(255, 50, 50, 255, "Your alib updater is outdated, please update it as lbox's api doesn't allow to do it via script :)")
   end
   printc(255, 50, 50, 255, "Your alib file is outdated or doesn't exist, downloading new version...")
   filesystem.CreateDirectory("alib")
   io.output("alib/alib.lua")
   local raw = http.Get(string.format("https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/source.lua", latest_version))
   io.write(raw)
   io.flush()
   io.close(io.stdout)
   print("Update complete!")
   print(local_version .. " --> " .. latest_version)
   printc(150, 255, 150, 255, "Changelog: ", http.Get(string.format("https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/changelog", latest_version)))
end

--- means we finished and can actually run the lib
local lib = io.open("alib/alib.lua")
if not lib then print(debug.traceback("something has gone wrong!!!")) return end
local content = lib:read("a")
lib:close()
local loaded = load(content)()

return loaded