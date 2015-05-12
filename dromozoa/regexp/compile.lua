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

local node_to_bitset = require "dromozoa.regexp.node_to_bitset"

return function (g)
  local map = {}
  local n = 0

  for u in g:each_vertex() do
    if not u.accept then
      n = n + 1
      map[u.id] = n
    end
  end

  local nonaccept_max = n
  local accept_tokens = {}

  for u in g:each_vertex("accept") do
    n = n + 1
    map[u.id] = n
    accept_tokens[n - nonaccept_max] = u.accept
  end

  local n = 0
  for u in g:each_vertex("start") do
    n = n + 1
  end
  if n ~= 1 then
    error("compile error")
  end
  local start = map[g:each_vertex("start")().id]

  local transitions = {}
  for i = 1, 256 do
    transitions[i] = false
  end
  for u in g:each_vertex() do
    local offset = map[u.id] * 257
    for i = 0, 256 do
      transitions[offset + i] = false
    end
    for v, e in u:each_adjacent_vertex() do
      local state = map[v.id]
      for k in node_to_bitset(e.condition):each() do
        transitions[offset + k] = state
      end
    end
  end

  return {
    start = start;
    nonaccept_max = nonaccept_max;
    accept_tokens = accept_tokens;
    transitions = transitions;
  }
end
