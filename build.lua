---@param directory string
local function list_files (directory)
   local ls = io.popen(string.format("/bin/ls %s", directory))
   if not ls then return end
   local t = {}
   for file in ls:lines() do
      if string.find(file, ".lua", 1, true) then
         t[#t+1] = file
      end
   end
   ls:close()
   return t
end

local function read_file(folder, file_name)
   local file = io.open(folder .. file_name)
   if not file then return nil end
   local str = file:read("a")
   file:close()
   return str
end

local function remove_return(file_name, str)
   local pattern = string.format("return %s", file_name)
   pattern = string.gsub(pattern, ".lua", "")
   return string.gsub(str, pattern, "")
end

local function remove_require(str)
   local require_section_end = string.find (str, "---//")
   return string.sub(str, require_section_end + 1)
end

local function remove_comments(str)
   return string.gsub(str, "%s*%-%-[^\n\r]*", "")
end

local function clean_file(file_name, str)
   local new_str = remove_return(file_name, str)
   new_str = remove_require(new_str)
   new_str = remove_comments(new_str)
   return new_str
end

local start = os.clock()

local main_file = read_file("src/","main.lua")
local utils_folder = list_files("src/ui/utils")
local src_folder = list_files("src/ui")

local utils = ""
local src = ""

for k, file_name in pairs (utils_folder) do
   local file = read_file("src/ui/utils/", file_name)
   local new_file = clean_file(file_name, file)
   utils = utils .. new_file .. "\n"
end

for k, file_name in pairs (src_folder) do
   local file = read_file("src/ui/", file_name)
   local new_file = clean_file(file_name, file)
   src = src .. new_file .. "\n"
end

local cleaned_main = remove_require(main_file)
local combined = utils .. src .. cleaned_main

io.output("alib.lua")
io.write(combined)
local finish = os.clock()

print(string.format("Took %f seconds to build alib", finish))