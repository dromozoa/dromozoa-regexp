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


local buffer_writer = require "dromozoa.regexp.buffer_writer"
local dfa = require "dromozoa.regexp.dfa"
local scan = require "dromozoa.regexp.scan"
local scanner = require "dromozoa.regexp.scanner"

local loadstring = loadstring or load

local dfa1 = dfa("[[:space:]]+", 1)
  :branch("-?(0|[1-9][0-9]*)", 2)
  :branch("\"", 3)

local dfa2 = dfa("\\\\.", 4)
  :branch("[^\\\"]+", 5)
  :branch("\"", 6)

dfa1:write_graphviz(assert(io.open("test-dfa1.dot", "w"))):close()
dfa2:write_graphviz(assert(io.open("test-dfa2.dot", "w"))):close()

local s = [[ 01 42  "foo"   "bar\nbaz" ]]
local tokens, begins, ends = scan({
  dfa1:compile(), dfa2:compile()
}, {
  scanner.SKIP;
  scanner.PUSH;
  scanner.CALL(2);
  scanner.PUSH;
  scanner.PUSH;
  scanner.RETURN;
}, s)

local data = {
  { 2, "0" };
  { 2, "1" };
  { 2, "42" };
  { 3 };
  { 5, "foo" };
  { 6 };
  { 3 };
  { 5, "bar" };
  { 4, "\\n" };
  { 5, "baz" };
  { 6 };
}

assert(#tokens == #data)
for i = 1, #tokens do
  local a = data[i][1]
  local b = data[i][2]
  assert(tokens[i] == a)
  if b then
    assert(s:sub(begins[i], ends[i]) == b)
  end
end
