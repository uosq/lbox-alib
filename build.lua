local ls = io.popen("/bin/ls src/ui")
if not ls then return end

local final_string = ""
local main_file = "main.lua"
local main_file_content = io.open("src/"..main_file)
if not main_file_content then warn("main is nil") return end
local main_file_str = main_file_content:read("a")
main_file_content:close()

for file in ls:lines() do
   if file ~= main_file then
      local file_content = io.open("src/ui/" .. file, "r")
      if not file_content then warn("file is nil") return end
      local str = file_content:read("a")
      local reverse_str = string.reverse(str)
      local newline_position = string.find(reverse_str, "\n")
      local new_str = string.reverse( string.sub(reverse_str, newline_position + 1) )
      final_string = final_string .. new_str .. "\n"
      file_content:close()
   end
end

local main_require_end = string.find(main_file_str, "---//", 1, true)
main_file_str = string.sub(main_file_str, main_require_end + 6)

final_string = final_string .. main_file_str

local make = io.open("alib.lua","w")
if not make then return end
make:write(final_string)
make:close()