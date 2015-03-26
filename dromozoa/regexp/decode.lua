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

local function decoder(g)
  local self = {
    _g = g;

    ["|"] = function (self, u, node, a, b)
      if b then
        local v = self:create_vertex()
        for i = 2, #node do
          self:create_edge(self:visit(self:create_edge(u), node[i]), v)
        end
        return v
      else
        return self:visit(u, a)
      end
    end;

    ["concat"] = function (self, u, node)
      for i = 2, #node do
        u = self:visit(u, node[i])
      end
      return u
    end;

    ["+"] = function (self, u, node, a)
      return self:create_duplication(u, a, 1)
    end;

    ["*"] = function (self, u, node, a)
      return self:create_duplication(u, a, 0)
    end;

    ["?"] = function (self, u, node, a)
      return self:create_duplication(u, a, 0, 1)
    end;

    ["{m"] = function (self, u, node, a, b)
      return self:create_duplication(u, a, b, b)
    end;

    ["{m,"] = function (self, u, node, a, b)
      return self:create_duplication(u, a, b)
    end;

    ["{m,n"] = function (self, u, node, a, b, c)
      return self:create_duplication(u, a, b, c)
    end;
  }

  function self:create_vertex()
    return self._g:create_vertex()
  end

  function self:create_edge(u, v, condition)
    if not v then
      v = self:create_vertex()
    end
    local e = self._g:create_edge(u, v)
    if condition then
      e.condition = condition
    else
      e.condition = { "epsilon" }
    end
    return v
  end

  function self:create_duplication(u, node, m, n)
    for i = 1, m do
      u = self:visit(u, node)
    end
    if n then
      for i = m + 1, n do
        u = self:create_edge(u, self:visit(u, node))
      end
    else
      u = self:create_edge(self:create_edge(self:visit(u, node), u))
    end
    return u
  end

  function self:fallback(u, node)
    return self:create_edge(u, nil, node)
  end

  function self:visit(u, node)
    return (self[node[1]] or self.fallback)(self, u, node, node[2], node[3], node[4])
  end

  function self:decode(node)
    local s = self:create_vertex()
    s.start = true
    local a = self:visit(s, node)
    a.accept = true
    return self._g
  end

  return self
end

return function (node)
  return decoder(graph()):decode(node)
end
