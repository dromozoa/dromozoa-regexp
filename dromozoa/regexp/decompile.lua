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
local bitset = require "dromozoa.regexp.bitset"
local bitset_to_node = require "dromozoa.regexp.bitset_to_node"

return function (code)
  local start = code.start
  local accept_min = code.accept_min
  local accept_max = code.accept_max
  local accept_tokens = code.accept_tokens
  local transitions = code.transitions

  local g = graph()

  local token
  for i = 1, accept_min - 1 do
    g:create_vertex()
  end
  for i = 1, #accept_tokens do
    local u = g:create_vertex()
    local v = accept_tokens[i]
    u.accept = v
    if token == nil or token > v then
      token = v
    end
  end
  g:get_vertex(start).start = token

  for u in g:each_vertex() do
    local offset = u.id * 257 + 1
    local map = {}
    for i = 0, 256 do
      local v = transitions[offset + i]
      if v > 0 then
        local class = map[v]
        if not class then
          class = bitset()
          map[v] = class
        end
        class:set(i)
      end
    end
    for k, v in pairs(map) do
      g:create_edge(u, k).condition = bitset_to_node(v)
    end
  end

  return g
end
