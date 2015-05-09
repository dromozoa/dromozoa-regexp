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

local function reverse(g)
  local result = graph()
  local map = {}

  for a in g:each_vertex() do
    local b = result:create_vertex()
    map[a.id] = b.id
    b.start = a.accept
    b.accept = a.start
  end

  for a in g:each_edge() do
    local b = result:create_edge(map[a.vid], map[a.uid])
    -- should clone?
    b.condition = a.condition
  end

  return result
end

return function (g)
  -- Brzozowski's algorithm
  return construct_subset(reverse(construct_subset(reverse(g))))
end
