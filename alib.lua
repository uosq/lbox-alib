local LATEST_VERSION = http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/latest_version")
local should_update = false

local function get_version(str)
   local removed = string.gsub(str, "local version = ", "")
   return string.sub(removed, 2, #removed-1)
end

local alib_file = io.open("alib/alib.lua")
if alib_file then
   local local_version = get_version(alib_file:read())
   should_update = local_version < LATEST_VERSION
   alib_file:close()
else
   should_update = true
end

if should_update then
   printc(255, 50, 50, 255, "alib is outdated or doesn't exist, downloading new version...")
   filesystem.CreateDirectory("alib")
   io.output("alib/alib.lua")
   local raw = http.Get(string.format("https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/source.lua", LATEST_VERSION))
   io.write(raw)
   io.flush()
   io.close(io.stdout)
   print("Update complete!")
end

--- means we finished and can actually run the lib
local lib = io.open("alib/alib.lua")
if not lib then print(debug.traceback("something has gone wrong!!!")) return end
local content = lib:read("a")
lib:close()
local loaded = load(content)()

return loaded