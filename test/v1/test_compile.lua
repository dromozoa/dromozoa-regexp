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

local sequence_writer = require "dromozoa.commons.sequence_writer"
local regexp = require "dromozoa.regexp"
local decompile = require "dromozoa.regexp.decompile"
local dump = require "dromozoa.regexp.dump"

local loadstring = loadstring or load

local a = regexp("/\\*"):concat(regexp(".*"):difference(".*\\*/.*")):concat("\\*/")
  :branch("-?(0|[1-9][0-9]*)", 2)
  :branch("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([Ee][+[.-.]]?[0-9]+)?", 3)
  :branch("[[:alpha:]]*", 4)
a:write_graphviz(assert(io.open("test-dfa1.dot", "w"))):close()

local function check_code(code)
  assert(code.start)
  assert(#code.accepts == 14)
  assert(#code.transitions == 255 + 14 * 256)
  assert(#code.end_assertions == 14)
end

local code = a:compile()
check_code(code)
local code = assert(loadstring(dump(code, sequence_writer()):concat()))()
check_code(code)

local b = decompile(code)
regexp(b):write_graphviz(assert(io.open("test-dfa2.dot", "w"))):close()
