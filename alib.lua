local latest_version = http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/latest_version")

local ALIB_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/source.lua"
local CHANGELOG_LINK = "https://raw.githubusercontent.com/uosq/lbox-alib/refs/tags/%s/changelog"

local function write_output(file, out)
   io.output(file)
   io.write(out)
   io.flush()
   io.close()
end

local function get_version(str)
   local removed = string.gsub(str, "local version = ", "")
   return string.sub(removed, 2, #removed - 1)
end

---Returns the file at version/tag
---@param link string
---@param version string
local function get_file(link, version)
   local url = string.format(link, version)
   return http.Get(url)
end

--- Downloads source.lua
local function download_alib()
   filesystem.CreateDirectory("alib")
   local alib = get_file(ALIB_LINK, latest_version)
   return alib
end

local function get_changelog()
   return get_file(CHANGELOG_LINK, latest_version)
end

--- Returns whether the alib needs to be updated or not
local function check_update()
   local should_update = false
   local alib = io.open("alib/alib.lua")
   local localversion = "non"
   if alib then
      localversion = get_version(alib:read()) --- read first line
      should_update = localversion ~= latest_version

      alib:close()
   else --- didnt find file, so immediate download
      should_update = true
   end

   if should_update then
      printc(102, 192, 205, 255, localversion .. " --> " .. latest_version)
      printc(215, 66, 245, 255, get_changelog())
   end

   return should_update
end

---@return boolean success
local function update_files()
   --- now we see if its needed to download new alib version
   local should_download_alib = check_update()
   local updated = false
   if should_download_alib then
      local alib = download_alib()
      write_output("alib/alib.lua", alib)
      updated = true
   end

   return updated
end

local function load_alib()
   if package.loaded["alib"] then --- from my testing, this never got returned so i dont know if it'll stay here
      return package.loaded["alib"]
   end
   local alib_file = io.open("alib/alib.lua")
   if alib_file then
      local alib = alib_file:read("a")
      local loaded = load(alib)()
      alib_file:close()

      package.loaded["alib"] = loaded
      return package.loaded["alib"]
   end
end

update_files()

return load_alib()
