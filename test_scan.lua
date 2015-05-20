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

local json = require "dromozoa.json"

local buffer_writer = require "dromozoa.regexp.buffer_writer"
local dfa = require "dromozoa.regexp.dfa"
local scan = require "dromozoa.regexp.scan"
local scanner = require "dromozoa.regexp.scanner"

local loadstring = loadstring or load

local dfa1 = dfa("[[:space:]]+", 1)
  :branch("-?(0|[1-9][0-9]*)", 2)
  :branch("\\{", 3)
  :branch("}", 4)
  :branch("\"", 5)

local dfa2 = dfa("\"", 6)
  :branch("\\\\.", 7)
  :branch("[^\\\"]+", 8)

dfa1:write_graphviz(assert(io.open("test-dfa1.dot", "w"))):close()
dfa2:write_graphviz(assert(io.open("test-dfa2.dot", "w"))):close()

local s = '  {  0 123 { "aaa" } } '
local tokens, begins, ends = scan({
  dfa1:compile(), dfa2:compile()
}, {
  scanner.SKIP;
  scanner.PUSH;
  scanner.PUSH;
  scanner.PUSH;
  scanner.CALL(2);
  scanner.RETURN;
  scanner.PUSH;
  scanner.PUSH;
}, s)
print(json.encode(tokens))
print(json.encode(begins))
print(json.encode(ends))

for i = 1, #tokens do
  print(json.encode({ tokens[i], s:sub(begins[i], ends[i]) }))
end
