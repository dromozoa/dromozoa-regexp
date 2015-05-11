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

local minimize = require "dromozoa.regexp.minimize"
local node_to_nfa = require "dromozoa.regexp.node_to_nfa"
local parse = require "dromozoa.regexp.parse"
local powerset_construction = require "dromozoa.regexp.powerset_construction"
local reset_state_token = require "dromozoa.regexp.reset_state_token"
local write_graphviz = require "dromozoa.regexp.write_graphviz"

local dfa = powerset_construction(node_to_nfa(parse(arg[1])))
write_graphviz(dfa, assert(io.open("test-dfa1.dot", "w"))):close()
assert(dfa:each_vertex("start")().start == 1)
reset_state_token(dfa, 42)
assert(dfa:each_vertex("start")().start == 42)
write_graphviz(dfa, assert(io.open("test-dfa2.dot", "w"))):close()
