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

local graph = require "dromozoa.graph"
local construct_subset = require "dromozoa.regexp.construct_subset"

local function reverse_dfa(dfa)
  local reverse_nfa = graph()
  local map = {}
  for u in dfa:each_vertex() do
    local v = reverse_nfa:create_vertex()
    map[u.id] = v.id
    if u.start then
      v.accept = true
    end
    if u.accept then
      v.start = true
    end
  end
  for e in dfa:each_edge() do
    local e2 = reverse_nfa:create_edge(map[e.vid], map[e.uid])
    e2.condition = e.condition
  end
  local reverse_dfa = construct_subset(reverse_nfa)
  return reverse_dfa
end

return function (dfa)
  return reverse_dfa(reverse_dfa(dfa))
end
