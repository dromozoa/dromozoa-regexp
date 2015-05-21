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
local remove_assertions = require "dromozoa.regexp.remove_assertions"
local write_graphviz = require "dromozoa.regexp.write_graphviz"

local ast = parse(arg[1])
local nfa = node_to_nfa(parse(arg[1]))
local dfa1 = powerset_construction(nfa)
local dfa2 = minimize(dfa1)
local dfa3 = remove_assertions(dfa2)
local dfa4 = minimize(dfa2)
local dfa5 = minimize(dfa3)

write_graphviz(nfa, assert(io.open("test-nfa.dot", "w"))):close()
write_graphviz(dfa1, assert(io.open("test-dfa1.dot", "w"))):close()
write_graphviz(dfa2, assert(io.open("test-dfa2.dot", "w"))):close()
write_graphviz(dfa3, assert(io.open("test-dfa3.dot", "w"))):close()
write_graphviz(dfa4, assert(io.open("test-dfa4.dot", "w"))):close()
write_graphviz(dfa5, assert(io.open("test-dfa5.dot", "w"))):close()
