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
local dump = require "dromozoa.regexp.dump"

local a = regexp("ab|bc|cd|e*")
a:write_graphviz(assert(io.open("test-dfa1.dot", "w"))):close()
a:set_token(2)
a:write_graphviz(assert(io.open("test-dfa2.dot", "w"))):close()

local a = regexp(".*")
a:difference(regexp(".*\\*/.*"))
a:write_graphviz(assert(io.open("test-dfa3.dot", "w"))):close()

local a = regexp("/\\*"):concat(a):concat(regexp("\\*/"))
a:write_graphviz(assert(io.open("test-dfa4.dot", "w"))):close()
a:branch(regexp("-?(0|[1-9][0-9]*)", 2))
a:write_graphviz(assert(io.open("test-dfa5.dot", "w"))):close()
a:branch(regexp("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([Ee][+[.-.]]?[0-9]+)?", 3))
a:write_graphviz(assert(io.open("test-dfa6.dot", "w"))):close()

local a = regexp("/\\*"):concat(regexp(".*"):difference(".*\\*/.*")):concat("\\*/")
  :branch("-?(0|[1-9][0-9]*)", 2)
  :branch("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([Ee][+[.-.]]?[0-9]+)?", 3)
a:write_graphviz(assert(io.open("test-dfa7.dot", "w"))):close()
dump(a:compile(), assert(io.open("test-dfa7.lua", "w"))):close()
a:minimize()
a:write_graphviz(assert(io.open("test-dfa8.dot", "w"))):close()

