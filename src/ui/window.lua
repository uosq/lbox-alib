---@class window
local window = {
   x = 0, y = 0, width = 0, height = 0
}
window.__index = window

function window.new()
   local mt = setmetatable({}, window)
   return mt
end

function window:render()
   print("rendered :)")
end

return window