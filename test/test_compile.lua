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

local json = require "dromozoa.commons.json"
local regexp = require "dromozoa.regexp"

local function test_compile(this)
  local nfa = regexp.syntax_tree.ere(this):normalize():node_to_condition():to_nfa()
  nfa:write_graphviz(assert(io.open("test1.dot", "w"))):close()
  nfa:normalize_assertions()
  local dfa = nfa:minimize()
  dfa:write_graphviz(assert(io.open("test2.dot", "w"))):close()
  local data = dfa:compile()
  -- print(json.encode(data))
end

test_compile("^foo$")
test_compile("foo")
