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
    n = n + 1
    map[u.id] = n
  end

  local start
  for u in g:each_vertex("start") do
    assert(not start)
    start = map[u.id]
  end
  assert(start)

  local accepts = {}
  for i = 1, n do
    accepts[i] = false
  end
  for u in g:each_vertex("accept") do
    accepts[map[u.id]] = u.accept
  end

  local transitions = {}
  local end_assertions = {}
  for i = 1, 255 do
    transitions[i] = false
  end
  for u in g:each_vertex() do
    local cs = map[u.id]
    local offset = cs * 256

    for i = offset, offset + 255 do
      transitions[i] = false
    end
    end_assertions[cs] = false

    for v, e in u:each_adjacent_vertex() do
      local ns = map[v.id]
      local class = node_to_bitset(e.condition)
      if class:test(256) then
        end_assertions[cs] = ns
      else
        for k, v in class:each() do
          transitions[offset + k] = ns
        end
      end
    end
  end

  return {
    start = start;
    accepts = accepts;
    transitions = transitions;
    end_assertions = end_assertions;
  }
end
