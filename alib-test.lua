

local LATEST_VERSION = "v0.37.2"--http.Get("https://raw.githubusercontent.com/uosq/lbox-alib/refs/heads/main/stable_version")
local RAW_CONTENT = http.Get(string.format("https://github.com/uosq/lbox-alib/releases/download/%s/alib.lua", LATEST_VERSION))

filesystem.CreateDirectory("alib")
io.output("alib/alib.lua")
io.write(RAW_CONTENT)
io.flush()
io.close(io.stdout)

local file = io.open("alib/alib.lua")
if file then
   local line = file:read()
   local removed = string.gsub(line, "local version = ", "")
   local downloaded_version = string.sub(removed, 2, #removed-1)
   
   file:close()
end