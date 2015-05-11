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

local dfa = require "dromozoa.regexp.dfa"

local p = dfa("ab|bc|cd|e*")
p:write_graphviz(assert(io.open("test-dfa1.dot", "w"))):close()
p:minimize()
p:write_graphviz(assert(io.open("test-dfa2.dot", "w"))):close()
p:reset_state_token(2)
p:write_graphviz(assert(io.open("test-dfa3.dot", "w"))):close()

local p = dfa(".*")
p:difference(dfa(".*\\*/.*"))
p:write_graphviz(assert(io.open("test-dfa4.dot", "w"))):close()
p:minimize()
p:write_graphviz(assert(io.open("test-dfa5.dot", "w"))):close()

local p = dfa("/\\*"):concat(p):concat(dfa("\\*/"))
p:write_graphviz(assert(io.open("test-dfa6.dot", "w"))):close()
p:minimize()
p:write_graphviz(assert(io.open("test-dfa7.dot", "w"))):close()

p:branch(dfa("-?(0|[1-9][0-9]*)", 2):minimize())
p:branch(dfa("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][0-9]+)?", 3):minimize())
p:write_graphviz(assert(io.open("test-dfa8.dot", "w"))):close()

