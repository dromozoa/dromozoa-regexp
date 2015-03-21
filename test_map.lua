local map = require "dromozoa.regexp.map"

local m = map()
local a, b = m:insert({1,2,3}, false)
assert(a == false)
assert(b == true)
local a, b = m:insert({1,2,3}, "foo")
assert(a == false)
assert(b == false)
assert(m:find {1,2,3} == false)
assert(m:erase {1,2,3} == false)
assert(m:find {1,2,3} == nil)
assert(m:erase {1,2,3} == nil)

local m = map()
m:insert({1,1,1}, 111)
m:insert({1,1,2}, 112)
m:insert({1,2,3}, 123)
m:insert({1,2,4}, 124)
m:insert({2,3,5}, 235)
m:insert({2,3,6}, 236)
m:insert({2,4,7}, 247)
m:insert({2,4,8}, 248)
m:insert({3,3,3}, 333)
m:insert({3,4,4}, 344)
m:insert({3,5,5}, 355)
m:insert({4,4,4}, 444)
m:insert({5,5,5}, 555)
m:insert({5,5}, 55)
m:insert({5}, 5)

local count = 0
for k, v in m:each() do
  count = count + 1
end
assert(count == 15)
