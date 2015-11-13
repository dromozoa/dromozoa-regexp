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

local apply = require "dromozoa.commons.apply"
local bitset = require "dromozoa.commons.bitset"
local equal = require "dromozoa.commons.equal"
local sequence = require "dromozoa.commons.sequence"
local regexp = require "dromozoa.regexp"

local function test_parse(this)
  local ast = regexp.syntax_tree.ere(this)
  ast:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  local result = ast:to_ere()
  ast:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  assert(result == this)
end

test_parse("foo")
test_parse("foo|bar|baz")
test_parse("^foo|bar$|^baz$")
test_parse("foo+")
test_parse("(foo)+")
test_parse("a+|b*|c?|d{2}|e{2,}|f{2,4}")
test_parse("[a-z]")
test_parse("[a-z][0-9A-Za-z]")
test_parse("[[=equivalence_class=]]")
test_parse("[[:character_class:]]")
test_parse("[[.collating_symbol.]]")
test_parse("[*-]")
test_parse("[*--]")
test_parse("a(bc(def))")
test_parse("((((foo))))")

local function test_normalize(this, that)
  local ast = regexp.syntax_tree.ere(this)
  ast:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  ast = ast:normalize()
  ast:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  local result = ast:to_ere()
  ast:write_graphviz(assert(io.open("test3.dot", "w"))):close()
  if that == nil then
    assert(result == this)
  else
    assert(result == that)
    test_normalize(that)
  end
end

test_normalize("foo")
test_normalize("foo+", "fooo*")
test_normalize("(foo)+", "(foo)(foo)*")
test_normalize("a+|b*|c?|d{2}|e{2,}|f{2,4}", "aa*|b*|c?|dd|eee*|fff?f?")
test_normalize("foo(bar){0}", "foo.{0}")
test_normalize("foo(bar){0}baz", "foo.{0}baz")
test_normalize("foo|(bar){0}", "foo|.{0}")
test_normalize("foo|(bar){0}|baz", "foo|.{0}|baz")
test_normalize("a{0}", ".{0}")
test_normalize("a{0}|b{0}", ".{0}|.{0}")

local function test_condition(this, ...)
  local ast = regexp.syntax_tree.ere(this)
  local that = bitset()
  for v in sequence():push(...):each() do
    if type(v) == "string" then
      that:set(v:byte(1, #v))
    else
      that:set_union(v)
    end
  end
  ast:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  ast:node_to_condition()
  ast:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  local u = apply(apply(ast:start():each_child()):each_child())
  assert(equal(u.condition, that))
end

test_condition("[a-z]", "az")
test_condition("[[:alnum:]]", "09", "AZ", "az")
test_condition("[[.^.][.-.][.].]]", "^", "-", "]")
test_condition(".", bitset():set(0, 255))
test_condition("^", bitset():set(256))
test_condition("$", bitset():set(257))
test_condition("\\.", ".")
test_condition("[^a-z]", bitset():set(0, string.byte("a") - 1):set(string.byte("z") + 1, 255))

local function test_nfa(this)
  local ast = regexp.syntax_tree.ere(this):normalize():node_to_condition()
  ast:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  local nfa = ast:to_nfa()
  nfa:write_graphviz(assert(io.open("test2.dot", "w"))):close()
end

test_nfa("foo")
test_nfa("foo(bar){0}")
test_nfa("foo(bar){0}baz")
test_nfa("foo|(bar){0}")
test_nfa("foo|(bar){0}|baz")
test_nfa("a{0}")
test_nfa("a{0}|b{0}")
test_nfa("a*")
test_nfa("a{1,}")
test_nfa("a{2,}")
test_nfa("a{2,4}")
test_nfa("(foo)*")
test_nfa("(foo)?")
