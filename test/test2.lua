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

local json = require "dromozoa.commons.json"
local regexp = require "dromozoa.regexp"

local a = regexp.ere("ab[cd]", 1)
local b = regexp.ere("abc+", 2)

a:write_graphviz(assert(io.open("test1.dot", "w"))):close()
b:write_graphviz(assert(io.open("test2.dot", "w"))):close()
-- a:set_union(b)
-- a:concat(b)
a:branch(b)
a:write_graphviz(assert(io.open("test3.dot", "w"))):close()

local a = regexp.ere("a*|(b+$|c*)")
a:write_graphviz(assert(io.open("test4.dot", "w"))):close()
local data = a:compile()
print(regexp.match(data, "bbbb"))


