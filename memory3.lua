local json = require "dromozoa.json"
local parse = require "dromozoa.regexp.parse"
local decode_condition = require "dromozoa.regexp.decode_condition"

collectgarbage()
collectgarbage()

local a = collectgarbage("count")

local data = {}
for i = 1, 1000 do
  data[i] = { "[", { "[:", "alnum" } }
end

collectgarbage()
collectgarbage()

local b = collectgarbage("count")
print(b - a)

