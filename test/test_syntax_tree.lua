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

local ere_parser = require "dromozoa.regexp.ere_parser"
local ere_unparser = require "dromozoa.regexp.ere_unparser"

local function parse(regexp)
  return ere_parser(regexp):apply()
end

-- local a = construct("^ab\\^[b-z]+")
-- a:write_graphviz(assert(io.open("test1.dot", "w"))):close()
-- local b = a:minimize()
-- b:write_graphviz(assert(io.open("test2.dot", "w"))):close()

-- construct("b*"):write_graphviz(assert(io.open("test5.dot", "w"))):close()

-- local a = parse("abc|d*|\\|e+|[[:alpha:]0-9]")
local a = parse("a|((((^b|c))))")
a:tree():write_graphviz(assert(io.open("test1.dot", "w"))):close()
a:tree():normalize()
a:tree():write_graphviz(assert(io.open("test2.dot", "w"))):close()
a:tree():setup_condition()
a:tree():write_graphviz(assert(io.open("test3.dot", "w"))):close()
