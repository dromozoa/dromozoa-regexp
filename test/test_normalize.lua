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

local function test_normalize(this, that, that2, that3)
  local ast = regexp.syntax_tree.ere(this)
  ast:normalize()
  ast:node_to_condition()
  local nfa = ast:to_nfa()
  nfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  nfa:normalize_assertions()
  nfa:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  if that == nil then
    assert(nfa:empty())
  else
    local dfa = nfa:to_dfa()
    dfa:write_graphviz(assert(io.open("test3.dot", "w"))):close()
    dfa = dfa:minimize()
    dfa:write_graphviz(assert(io.open("test4.dot", "w"))):close()
    local result = dfa:to_ast():denormalize():to_ere(true)
    -- print(result)
    assert(result == that or result == that2 or result == that3)
  end
end

test_normalize("^abc|d^ef|gh$i|jkl$|mno$$|^pqr$|^^stu$$|^$^$|$^$^",
               "(^j|j)kl$|^($|mno$)|^abc|^pqr$|^stu$|mno$",
               "^($|jkl$|mno$)|^abc|^pqr$|^stu$|jkl$|mno$")
test_normalize("(^j|j)kl$|^($|mno$)|^abc|^pqr$|^stu$|mno$",
               "^($|jkl$|mno$)|^abc|^pqr$|^stu$|jkl$|mno$")
test_normalize("^($|jkl$|mno$)|^abc|^pqr$|^stu$|jkl$|mno$",
               "(^j|j)kl$|^($|mno$)|^abc|^pqr$|^stu$|mno$",
               "^($|jkl$|mno$)|^abc|^pqr$|^stu$|jkl$|mno$",
               "(^m|m)no$|^($|jkl$)|^abc|^pqr$|^stu$|jkl$")
test_normalize("(^m|m)no$|^($|jkl$)|^abc|^pqr$|^stu$|jkl$",
               "^($|jkl$|mno$)|^abc|^pqr$|^stu$|jkl$|mno$")
test_normalize("^foo", "^foo")
test_normalize("^foo$", "^foo$")
test_normalize("foo", "foo")
test_normalize("foo$", "^foo$|foo$", "(^f|f)oo$")
test_normalize("$foo^")
