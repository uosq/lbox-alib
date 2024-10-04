local ls = io.popen("/bin/ls src/ui")
if not ls then return end

local final_string = ""
local main_file = io.open("src/main.lua")
if not main_file then warn("main is nil") return end
local main_file_str = main_file:read("a")
main_file:close()

for file in ls:lines() do
   local file_content = io.open("src/ui/" .. file, "r")
   if not file_content then warn("file is nil") return end
   local str = file_content:read("a")

   local reverse_str = string.reverse(str)
   local newline_position = string.find(reverse_str, "\n")
   local new_str = string.reverse( string.sub(reverse_str, newline_position + 1) ) -- remove the return from the file
   local require_end = string.find(new_str, "---//", 1, true) -- find the require at the start of the file
   new_str = string.sub(new_str, require_end + 6) -- remove the require(s) so it doesnt return early when we load the lib (the + 6 is for removing the ---// and a newline)

      -- remove every comment from the script
   new_str = string.gsub(new_str, "%s*%-%-[^\n\r]*", "")

   final_string = final_string .. new_str .. "\n"
   file_content:close()
end

local main_require_end = string.find(main_file_str, "---//", 1, true) -- just read what happens above lol
main_file_str = string.sub(main_file_str, main_require_end + 6)

final_string = final_string .. main_file_str

local make = io.open("alib.lua","w")
if not make then return end
make:write(final_string)
make:close()