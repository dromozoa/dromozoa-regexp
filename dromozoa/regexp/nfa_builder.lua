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

return function ()
  local self = {
    _g = graph();
  }

  function self:create_vertex()
    return self._g:create_vertex()
  end

  function self:create_edge(u, v, c)
    if not v then
      v = self:create_vertex()
    end
    local e = self._g:create_edge(u, v)
    e.c = c or 0
    return v
  end

  function self:build(node)
    local s = self:create_vertex()
    s.start = true
    local a = self:extended_reg_exp(node, s)
    a.accept = true
    return self._g
  end

  function self:extended_reg_exp(node, u)
    local n = #node
    if n == 1 then
      return self:ERE_branch(node[1], u)
    else
      local v = self:create_vertex()
      for i = 1, n do
        self:create_edge(self:ERE_branch(node[i], self:create_edge(u)), v)
      end
      return v
    end
  end

  function self:ERE_branch(node, u)
    for i = 1, #node do
      u = self:ERE_expression(node[i], u)
    end
    return u
  end

  function self:ERE_expression(node, u)
    local t = type(node)
    if t == "table" then
      local a, b = node[1], node[2]
      local m, n = 1, 1
      if b then
        m, n = self:ERE_dupl_symbol(b)
      end
      for i = 1, m do
        u = self:one_char_or_coll_elem_ERE_or_grouping(a, u)
      end
      if n then
        for i = m + 1, n do
          u = self:create_edge(u, self:one_char_or_coll_elem_ERE_or_grouping(a, u))
        end
      else
        u = self:create_edge(self:create_edge(self:one_char_or_coll_elem_ERE_or_grouping(a, u), u))
      end
    elseif t == "string" then
      if node == "^" then
        u = self:create_edge(u, nil, 1)
      elseif node == "$" then
        u = self:create_edge(u, nil, 2)
      end
    end
    return u
  end

  function self:one_char_or_coll_elem_ERE_or_grouping(node, u)
    local t = type(node)
    if type(node) == "table" and type(node[1]) == "table" then
      return self:extended_reg_exp(node, u)
    else
      return self:create_edge(u, nil, node)
    end
  end

  function self:ERE_dupl_symbol(node)
    local t = type(node)
    if t == "string" then
      if node == "*" then
        return 0, nil
      elseif node == "+" then
        return 1, nil
      elseif node == "?" then
        return 0, 1
      end
    elseif t == "number" then
      return node, node
    elseif t == "table" then
      return node[1], node[2]
    end
  end

  return self
end
