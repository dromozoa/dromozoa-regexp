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

local branch = require "dromozoa.regexp.branch"
local minimize = require "dromozoa.regexp.minimize"
local node_to_nfa = require "dromozoa.regexp.node_to_nfa"
local parse = require "dromozoa.regexp.parse"
local powerset_construction = require "dromozoa.regexp.powerset_construction"
local write_graphviz = require "dromozoa.regexp.write_graphviz"

local m1 = minimize(powerset_construction(node_to_nfa(parse(arg[1]), 1)))
local m2 = minimize(powerset_construction(node_to_nfa(parse(arg[2]), 2)))

write_graphviz(m1, assert(io.open("test-m1a.dot", "w"))):close()
write_graphviz(m2, assert(io.open("test-m2.dot", "w"))):close()
branch(m1, m2)
write_graphviz(m1, assert(io.open("test-m1b.dot", "w"))):close()
local m3 = powerset_construction(m1)
write_graphviz(m3, assert(io.open("test-m3.dot", "w"))):close()
