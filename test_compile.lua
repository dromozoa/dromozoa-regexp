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
local decompile = require "dromozoa.regexp.decompile"
local generate = require "dromozoa.regexp.generate"

local loadstring = loadstring or load

local a = dfa("/\\*"):concat(dfa(".*"):difference(".*\\*/.*")):concat("\\*/")
  :branch("-?(0|[1-9][0-9]*)", 2)
  :branch("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([Ee][+[.-.]]?[0-9]+)?", 3)
  :branch("[[:alpha:]]*", 4)
a:write_graphviz(assert(io.open("test-dfa1.dot", "w"))):close()

local function check_code(code)
  assert(code.start == 8)
  assert(code.nonaccept_max == 7)
  assert(#code.accept_tokens == 7)
  assert(#code.transitions == 256 + 14 * 257)
end

local code = a:compile()
check_code(code)
local code = assert(loadstring(generate(code, buffer_writer()):concat()))()
check_code(code)

local b = decompile(code)
dfa(b):write_graphviz(assert(io.open("test-dfa2.dot", "w"))):close()
