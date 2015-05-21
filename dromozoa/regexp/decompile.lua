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

return function (data)
  local start = data.start
  local accepts = data.accepts
  local transitions = data.transitions
  local end_assertions = data.end_assertions

  local g = graph()

  local token
  for i = 1, #accepts do
    local u = g:create_vertex()
    local v = accepts[i]
    if v then
      u.accept = v
      if token == nil or token > v then
        token = v
      end
    end
  end
  g:get_vertex(start).start = token

  for u in g:each_vertex() do
    local cs = u.id
    local map = {}
    for i = 0, 255 do
      local ns = transitions[cs * 256 + i]
      if ns then
        local class = map[ns]
        if not class then
          class = bitset()
          map[ns] = class
        end
        class:set(i)
      end
    end
    local ns = end_assertions[cs]
    if ns then
      map[ns] = bitset():set(256)
    end
    for k, v in pairs(map) do
      g:create_edge(cs, k).condition = bitset_to_node(v)
    end
  end

  return g
end
