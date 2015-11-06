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
local to_nfa = require "dromozoa.regexp.to_nfa"
local automaton = require "dromozoa.regexp.automaton"

local function construct(regexp, token)
  return to_nfa():apply(ere_parser(regexp):apply(), token)
end

-- local a = construct("^ab\\^[b-z]+")
-- a:write_graphviz(assert(io.open("test1.dot", "w"))):close()
-- local b = a:minimize()
-- b:write_graphviz(assert(io.open("test2.dot", "w"))):close()

local a = construct("ab[b-z]+"):minimize()
local b = construct("a[b-z]c", 2):minimize()
local c = a:difference(b):minimize()

a:write_graphviz(assert(io.open("test1.dot", "w"))):close()
b:write_graphviz(assert(io.open("test2.dot", "w"))):close()
c:write_graphviz(assert(io.open("test3.dot", "w"))):close()

--[[
local a = construct("ab[b-z]+")
a:powerset_construction()
write_graphviz(a.graph, assert(io.open("test-a.dot", "w"))):close()
local b = construct("a[b-z]c", 2)
b:powerset_construction()
write_graphviz(b.graph, assert(io.open("test-b.dot", "w"))):close()

a:product_construction(b, tokens.intersection)
write_graphviz(a.graph, assert(io.open("test1.dot", "w"))):close()
a:reverse()
write_graphviz(a.graph, assert(io.open("test2.dot", "w"))):close()
a:powerset_construction()
write_graphviz(a.graph, assert(io.open("test3.dot", "w"))):close()
a:reverse()
write_graphviz(a.graph, assert(io.open("test4.dot", "w"))):close()
a:powerset_construction()
write_graphviz(a.graph, assert(io.open("test5.dot", "w"))):close()

]]
