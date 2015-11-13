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

local function test_dfa(this)
  local nfa = regexp.syntax_tree.ere(this):normalize():node_to_condition():to_nfa()
  nfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  local dfa1 = nfa:to_dfa()
  dfa1:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  local dfa2 = dfa1:minimize()
  dfa2:write_graphviz(assert(io.open("test3.dot", "w"))):close()
end

test_dfa("foo")
test_dfa("foo|bar")
test_dfa("foo|bar|baz")
test_dfa("(foo){2,4}")
test_dfa("foo(bar){2,4}baz")
test_dfa("a{0}")
test_dfa("aa|aba|abbba|abbbba")

local function test_ast(this)
  local dfa = regexp.syntax_tree.ere(this):normalize():node_to_condition():to_nfa():to_dfa():minimize()
  dfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  local ast = dfa:to_ast()
  ast:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  local ere = ast:to_ere()
  print(ere)
end

test_ast("foo|bar|baz")

-- local a = construct("^ab\\^[b-z]+")
-- a:write_graphviz(assert(io.open("test1.dot", "w"))):close()
-- local b = a:minimize()
-- b:write_graphviz(assert(io.open("test2.dot", "w"))):close()

-- construct("b*"):write_graphviz(assert(io.open("test5.dot", "w"))):close()

--[====[
local a = construct(".{8}"):minimize()
local b = construct("(\\\\[[:xdigit:]])+", 2):minimize()
local c = a:intersection(b):minimize()

a:write_graphviz(assert(io.open("test1.dot", "w"))):close()
b:write_graphviz(assert(io.open("test2.dot", "w"))):close()
c:write_graphviz(assert(io.open("test3.dot", "w"))):close()

local node, d = c:to_node()
print(ere_unparser():apply(node))
d:write_graphviz(assert(io.open("test4.dot", "w"))):close()

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

]====]
