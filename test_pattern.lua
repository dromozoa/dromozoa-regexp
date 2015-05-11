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

local P = require "dromozoa.regexp.pattern"

local p = P("ab|bc|cd|e*")
p:write_graphviz(assert(io.open("test-p1.dot", "w"))):close()
p:minimize()
p:write_graphviz(assert(io.open("test-p2.dot", "w"))):close()
p:reset_state_token(2)
p:write_graphviz(assert(io.open("test-p3.dot", "w"))):close()

local p = P(".*")
p:difference(P(".*\\*/.*"))
p:write_graphviz(assert(io.open("test-p4.dot", "w"))):close()
p:minimize()
p:write_graphviz(assert(io.open("test-p5.dot", "w"))):close()

local p = P("/\\*"):concat(p):concat(P("\\*/"))
p:write_graphviz(assert(io.open("test-p6.dot", "w"))):close()
p:minimize()
p:write_graphviz(assert(io.open("test-p7.dot", "w"))):close()

p:branch(P("-?(0|[1-9][0-9]*)", 2):minimize())
p:branch(P("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][0-9]+)?", 3):minimize())
p:write_graphviz(assert(io.open("test-p8.dot", "w"))):close()

