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

local clone = require "dromozoa.commons.clone"

local function merge(g, result, map)
  for a in g:each_edge() do
    local b = result:create_edge(map[a.uid], map[a.vid])
    b.condition = clone(a.condition)
  end
  return result
end

return {
  start = function (g, result, u)
    local map = {}
    for a in g:each_vertex() do
      local b = result:create_vertex()
      map[a.id] = b.id
      if a.start then
        local e = result:create_edge(u, b)
        e.condition = { "epsilon" }
      end
      b.accept = a.accept
    end
    return merge(g, result, map)
  end;

  accept = function (g, result, u)
    local map = {}
    for a in g:each_vertex() do
      local b = result:create_vertex()
      map[a.id] = b.id
      b.start = a.start
      if a.accept then
        local e = result:create_edge(b, u)
        e.condition = { "epsilon" }
      end
    end
    return merge(g, result, map)
  end;
}
