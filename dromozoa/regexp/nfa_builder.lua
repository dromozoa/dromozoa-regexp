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

return function ()
  local self = {}

  function self:new_state()
    local state = self._state + 1
    self._state = state
    return state
  end

  function self:new_transition(u, v, condition)
    if not v then
      v = self:new_state()
    end
    if not condition then
      condition = 0
    end
    local t = self._transition
    t[#t + 1] = { u, v, condition }
    return v
  end

  function self:build(node)
    self._transition = {}
    self._state = 0
    local accept = self:extended_reg_exp(node, self:new_state())
    return {
      transition = self._transition;
      start = { 1 };
      accept = { accept };
    }
  end

  function self:extended_reg_exp(node, u)
    local n = #node
    if n == 1 then
      return self:ERE_branch(node[1], u)
    else
      local v = {}
      for i = 1, n do
        v[i] = self:ERE_branch(node[i], self:new_transition(u))
      end
      local w = self:new_state()
      for i = 1, n do
        self:new_transition(v[i], w)
      end
      return w
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
          u = self:new_transition(u, self:one_char_or_coll_elem_ERE_or_grouping(a, u))
        end
      else
        u = self:new_transition(self:new_transition(self:one_char_or_coll_elem_ERE_or_grouping(a, u), u))
      end
    elseif t == "string" then
      if node == "^" then
        u = self:new_transition(u, nil, 1)
      elseif node == "$" then
        u = self:new_transition(u, nil, 2)
      end
    end
    return u
  end

  function self:one_char_or_coll_elem_ERE_or_grouping(node, u)
    local t = type(node)
    if type(node) == "table" and type(node[1]) == "table" then
      return self:extended_reg_exp(node, u)
    else
      return self:new_transition(u, nil, node)
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
