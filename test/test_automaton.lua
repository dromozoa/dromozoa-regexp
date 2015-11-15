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
test_dfa("(abc)*")

local function test_ast(this, n)
  local dfa = regexp.syntax_tree.ere(this):normalize():node_to_condition():to_nfa():to_dfa():minimize()
  dfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  local ast, nfa = dfa:to_ast()
  ast:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  nfa:write_graphviz(assert(io.open("test3.dot", "w"))):close()
  local ere = ast:to_ere()
  print(ere)
  if n < 4 then
    test_ast(ere, n + 1)
  end
end

test_ast("(abc)*", 0)
test_ast("foo|bar|baz", 0)
