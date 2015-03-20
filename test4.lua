local json = require "dromozoa.json"
local map = require "dromozoa.regexp.map"

local m = map()
m:insert({1,2,3}, false)
m:insert({1,2,3}, "foo")
m:insert({1,2,2}, "bar")
m:insert({1,3,4}, "baz")
m:insert({2,3,4}, "qux")
print(m:find({1,2,3}))
print(m:erase({1,2,3}))
print(m:find({1,2,3}))
print(json.encode(m._t))

