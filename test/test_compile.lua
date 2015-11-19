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

local dumper = require "dromozoa.commons.dumper"
local equal = require "dromozoa.commons.equal"
local json = require "dromozoa.commons.json"
local regexp = require "dromozoa.regexp"

local function compile(this)
  local nfa = regexp.syntax_tree.ere(this):normalize():node_to_condition():to_nfa()
  nfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  nfa:normalize_assertions()
  local dfa = nfa:minimize()
  dfa:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  dfa:compile()
  local data = dfa:compile()
  -- print(json.encode(data))
  return data
end

local data = compile("foo")
assert(data.start ~= 0)
assert(data.start_assertion == 0)
assert(regexp.find(data, "foo"))
assert(regexp.find(data, "barfoo"))

local data = compile("^foo")
assert(data.start == 0)
assert(data.start_assertion ~= 0)
assert(regexp.find(data, "foo"))
assert(not regexp.find(data, "barfoo"))

local data = compile("$")
assert(data.start ~= 0)
assert(data.start_assertion ~= 0)
local i, j, token = regexp.find(data, "")
assert(i == 1)
assert(j == 0)
assert(token)
local i, j, token = regexp.find(data, "foo")
assert(i == 4)
assert(j == 3)
assert(token)

local data = compile("^foo|bar|baz$")
local dfa = regexp.decompile(data)
dfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
assert(dfa:to_ere() == "(^b|b)ar|(^b|b)az$|^foo")

local data = compile("^foo|^bar$")
local dfa = regexp.decompile(data)
dfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
assert(dfa:to_ere() == "^bar$|^foo")

local a = regexp.ere("foo", 17)
local b = regexp.ere("bar", 23)
local c = regexp.ere("baz", 37)
local d = a:branch(b):branch(c)
d:write_graphviz(assert(io.open("test1.dot", "w"))):close()
local data = d:compile()
assert(regexp.match(data, "foo") == 17)
assert(regexp.match(data, "bar") == 23)
assert(regexp.match(data, "baz") == 37)
assert(not regexp.match(data, "qux"))
-- print(dumper.encode(data))
local data2 = dumper.decode(dumper.encode(data))
assert(equal(data, data2))
local e = regexp.decompile(data)
e:write_graphviz(assert(io.open("test2.dot", "w"))):close()
local data3 = e:compile()
