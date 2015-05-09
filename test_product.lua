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

local construct_nfa = require "dromozoa.regexp.construct_nfa"
local construct_product = require "dromozoa.regexp.construct_product"
local minimize = require "dromozoa.regexp.minimize"
local parse = require "dromozoa.regexp.parse"
local powerset_construction = require "dromozoa.regexp.powerset_construction"
local write_graphviz = require "dromozoa.regexp.write_graphviz"

local dfa1 = minimize(powerset_construction(construct_nfa(parse(arg[1]))))
local dfa2 = minimize(powerset_construction(construct_nfa(parse(arg[2]))))
local dfa3 = construct_product[arg[3]](dfa1, dfa2)
local dfa4 = minimize(dfa3)

write_graphviz(dfa1, assert(io.open("test-dfa1.dot", "w"))):close()
write_graphviz(dfa2, assert(io.open("test-dfa2.dot", "w"))):close()
write_graphviz(dfa3, assert(io.open("test-dfa3.dot", "w"))):close()
write_graphviz(dfa4, assert(io.open("test-dfa4.dot", "w"))):close()
