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

local regexp = require "dromozoa.regexp"

local a = regexp.ere("foo", 1)
local b = regexp.ere("bar", 2)
local c = regexp.ere("baz", 3)
local d = a:branch(b):branch(c)
d:write_graphviz(assert(io.open("test1.dot", "w"))):close()
assert(d:to_ere() == "bar|baz|foo")

local data = d:compile()
assert(regexp.match(data, "foo") == 1)
assert(regexp.match(data, "bar") == 2)
assert(regexp.match(data, "baz") == 3)
assert(not regexp.match(data, "qux"))

local e = d:minimize()
e:write_graphviz(assert(io.open("test2.dot", "w"))):close()
assert(e:to_ere() == "ba[rz]|foo")

local comment = regexp.ere("/\\*"):concat(regexp.ere(".*\\*"):set_difference(regexp.ere(".*\\*/.*"))):concat(regexp.ere("/"))
-- local comment = regexp.ere(".*\\*"):set_difference(regexp.ere(".*\\*/.*"))
comment:write_graphviz(assert(io.open("test3.dot", "w"))):close()
-- print(comment:to_ere())
