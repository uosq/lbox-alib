local json = require("dependencies.json")
local settings = require("src.settings")
assert(json, "Couldn't find json!")
assert(settings, "Couldn't find settings!")

local encoded = json.encode(settings)

io.output("build/default.json")
io.write(encoded)
io.flush()
io.close()

encoded = nil
settings = nil
json = nil
