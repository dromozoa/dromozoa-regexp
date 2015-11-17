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

local function test_ast(this, that)
  local dfa = regexp.syntax_tree.ere(this):normalize():node_to_condition():to_nfa():to_dfa():minimize()
  dfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  local ast, nfa = dfa:to_ast()
  ast:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  ast:denormalize()
  ast:write_graphviz(assert(io.open("test3.dot", "w"))):close()
  local result = ast:to_ere(true)
  if that == nil then
    assert(result == this)
  else
    assert(result == that)
    test_ast(that)
  end
end

test_ast("a?", "a?")
test_ast("a*", "(aa*)?")
test_ast("a+", "aa*")
test_ast("abcd*", "abcd*")
test_ast("abcd+", "abcdd*")
test_ast("(abcd)*", "(abcd(abcd)*)?")
test_ast("(abcd)+", "abcd(abcd)*")
test_ast("foo|bar|baz", "ba[rz]|foo")
test_ast("if|then|else|elseif|end", "(elsei|i)f|else|end|then")
test_ast("a*|(abc)*", "a?|aaa*|abc|abca(bca)*bc")

local function to_dfa(this, token)
  local ast = regexp.syntax_tree.ere(this, token)
  ast:normalize()
  ast:node_to_condition()
  local nfa = ast:to_nfa()
  local dfa = nfa:to_dfa()
  return dfa:minimize()
end

local function to_ere(dfa)
  return dfa:to_ast():denormalize():to_ere(true)
end

local dfa = to_dfa("abc|def", 1)
assert(dfa:can_minimize())
dfa:branch(to_dfa("ghi", 2))
dfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
assert(not dfa:can_minimize())
assert(to_ere(dfa) == "abc|def|ghi")

local dfa = to_dfa("abc|def", 1)
assert(dfa:can_minimize())
dfa:concat(to_dfa("ghi", 2))
dfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
assert(dfa:can_minimize())
assert(to_ere(dfa) == "(abc|def)ghi")

local dfa = to_dfa("[a-z]+"):set_intersection(to_dfa(".{4}")):minimize()
assert(to_ere(dfa) == "[a-z][a-z][a-z][a-z]")

local dfa = to_dfa("abc"):set_union(to_dfa("def")):set_union(to_dfa("ghi")):minimize()
assert(to_ere(dfa) == "abc|def|ghi")

local dfa = to_dfa(".{3}"):set_difference(to_dfa("abc")):minimize()
assert(to_ere(dfa) == "[^a]..|a[^b].|ab[^c]")
