local json = require "dromozoa.json"
local map = require "dromozoa.regexp.map"

local m = map()
local a, b = m:insert({1,2,3}, false)
assert(a == false)
assert(b == true)
local a, b = m:insert({1,2,3}, "foo")
assert(a == false)
assert(b == false)
print(json.encode(m._t))
assert(m:find {1,2,3} == false)
assert(m:erase {1,2,3} == false)
print(json.encode(m._t))
assert(m:find {1,2,3} == nil)
assert(m:erase {1,2,3} == nil)
