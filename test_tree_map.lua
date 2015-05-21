-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-regexp.
--
-- dromozoa-regexp is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-regexp is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-regexp.  If not, see <http://www.gnu.org/licenses/>.

local tree_map = require "dromozoa.regexp.tree_map"

local map = tree_map()
local a, b = map:insert({1,2,3}, false)
assert(a == false)
assert(b == true)
local a, b = map:insert({1,2,3}, "foo")
assert(a == false)
assert(b == false)
assert(map:find {1,2,3} == false)
assert(map:erase {1,2,3} == false)
assert(map:find {1,2,3} == nil)
assert(map:erase {1,2,3} == nil)

local map = tree_map()
map:insert({1,1,1}, 111)
map:insert({1,1,2}, 112)
map:insert({1,2,3}, 123)
map:insert({1,2,4}, 124)
map:insert({2,3,5}, 235)
map:insert({2,3,6}, 236)
map:insert({2,4,7}, 247)
map:insert({2,4,8}, 248)
map:insert({3,3,3}, 333)
map:insert({3,4,4}, 344)
map:insert({3,5,5}, 355)
map:insert({4,4,4}, 444)
map:insert({5,5,5}, 555)
map:insert({5,5}, 55)
map:insert({5}, 5)

local count = 0
for k, v in map:each() do
  count = count + 1
end
assert(count == 15)
