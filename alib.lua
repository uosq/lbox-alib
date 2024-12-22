-- alib.lua
local function get_version(str)
   local removed = string.gsub(str, "local version = ", "")
   return string.sub(removed, 2, #removed - 1)
end

-- Create a table to track loaded instances and their states
if not _G["alib_instances"] then
   _G["alib_instances"] = {
      count = 0,
      loaded = nil,
   }
end

-- Check for updates and download if needed
local function check_updates()
   local latest_version = http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/latest_version")

   local alib_file = io.open("alib/alib.lua")
   local local_version = "none"
   local should_update = false

   if alib_file then
      local_version = get_version(alib_file:read())
      should_update = local_version ~= latest_version
      alib_file:close()
   else
      should_update = true
   end

   if should_update then
      printc(255, 50, 50, 255, "Your alib file is outdated or doesn't exist, downloading new version...")
      filesystem.CreateDirectory("alib")
      io.output("alib/alib.lua")
      local raw = http.Get(string.format("https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/source.lua",
         latest_version))
      io.write(raw)
      io.flush()
      io.close()
      print("Update complete!")
      print(local_version .. " --> " .. latest_version)
      printc(150, 255, 150, 255, "Changelog: ",
         http.Get(string.format("https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/changelog", latest_version)))
   end
end

local function load_library()
   local lib = io.open("alib/alib.lua")
   if not lib then
      print(debug.traceback("Failed to open alib.lua"))
      return nil
   end

   local content = lib:read("*a")
   lib:close()

   -- Increment instance count
   _G["alib_instances"].count = _G["alib_instances"].count + 1
   print(_G["alib_instances"].count)

   -- If library is already loaded, return the cached instance
   if _G["alib_instances"].loaded then
      return _G["alib_instances"].loaded
   end

   -- Load the library and cache it
   local loaded = load(content)()
   _G["alib_instances"].loaded = loaded

   return loaded
end

local function unload_library()
   -- Decrement instance count | doing this is absolute useless, _G doesn't work correctly or i am just too stupid to see how its not working
   _G["alib_instances"].count = _G["alib_instances"].count - 1

   -- If this is the last instance, perform full cleanup
   if _G["alib_instances"].count <= 0 then
      local mem_before = collectgarbage("count")

      -- Unregister all callbacks
      callbacks.Unregister("CreateMove", "alib alpha")
      callbacks.Unregister("Draw", "alib intro")
      callbacks.Unregister("Draw", "alib ask load")

      -- Clear global state
      _G["alib_instances"].loaded = nil
      _G["alib_instances"].count = 0
      _G["alib settings"] = nil

      -- Clean up package cache
      package.loaded["alib"] = nil
      package.loaded["source"] = nil

      -- Force garbage collection
      collectgarbage("collect")
      local mem_after = collectgarbage("count")

      print("Unloaded alib")
      print("Collected " .. math.floor(math.abs(mem_before - mem_after)) .. " KB")
   end
end

-- Check for updates first
check_updates()

-- Load or get cached instance
local alib = load_library()

-- Add unload function to the library
if alib then
   alib.unload = unload_library
end

return alib
