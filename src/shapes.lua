local shapes = {}

---@param x integer
---@param y integer
---@param origin {}
---@param angle any
local function rotate_point(x, y, origin, angle)
   local x = x - (origin[1] or 0)
   local y = y - (origin[2] or 0)

   local cos_angle = math.cos(math.rad(angle))
   local sin_angle = math.sin(math.rad(angle))

   --- i wish we had support for numbers instead of integers :sob:
   local rotated_x = math.floor((x * cos_angle) - (y * sin_angle))
   local rotated_y = math.floor((x * sin_angle) + (y * cos_angle))

   rotated_x = rotated_x + origin[1]
   rotated_y = rotated_y + origin[2]

   return rotated_x, rotated_y
end

---@param x integer
---@param y integer
---@param size integer
---@param origin {[1]: integer, [2]: integer}? The origin of rotation, think of it like the pivot (or fulcrum idk english is hard) of a lever
---@param angle integer degress (20, 30, 45, 60, etc)
function shapes.rotatable_line(x, y, size, origin, angle)
   ---@diagnostic disable-next-line: redefined-local
   local origin = origin or { 0, 0 }
   local x1, y1 = rotate_point(x, y + size, origin, angle)
   local x2, y2 = rotate_point(x + size, y, origin, angle)
   draw.Line(x1, y1, x2, y2)
end

---I love unoptimized stuff! Doesnt work right but im too lazy to delete it
--- @param width integer
---@param height integer
---@param x integer
---@param y integer
---@param angle integer degrees (20, 30, 45, 60, etc)
function shapes.rotatable_rectangle(width, height, x, y, angle)
   local origin = { x + math.floor(width / 2), y + math.floor(height / 2) } --- middle of the rectangle

   for i = 0, height do
      local start_x, start_y = rotate_point(x, y + i, origin, angle)
      local end_x, end_y = rotate_point(x + width, y + i, origin, angle)
      draw.Line(start_x, start_y, end_x, end_y)
   end
end

---@param filled boolean
---@param width integer
---@param height integer
---@param x integer
---@param y integer
function shapes.rectangle(width, height, x, y, filled)
   if filled then
      draw.FilledRect(x, y, width + x, y + height)
   else
      draw.OutlinedRect(x, y, width + x, y + height)
   end
   return true
end

---@param x integer
---@param y integer
---@param radius integer
---@param segments integer
function shapes.circle(x, y, radius, segments)
   draw.OutlinedCircle(x, y, radius, segments)
   return true
end

function shapes.filledcircle(x, y, radius)
   local circle = shapes.circle
   --- i wish there was a filled circle already :(
   --- would probably be faster if it was in C
   for i = 1, radius do
      circle(x, y, i, 63)
   end
   return true
end

---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@param alpha_start integer [0, 255]
---@param alpha_end integer [0, 255]
---@param horizontal boolean? default = true
function shapes.rectanglefade(width, height, x, y, alpha_start, alpha_end, horizontal)
   draw.FilledRectFade(x, y, x + width, y + height, alpha_start, alpha_end, horizontal)
   return true
end

--- tbh i dont know why someone would use this but ok?
function shapes.triangle(x, y, size)
   draw.Line(x, y, x + size, y)
   draw.Line(x + math.floor(size / 2), y - size, x + size, y)
   draw.Line(x + math.floor(size / 2), y - size, x, y)
   return true
end

return shapes
