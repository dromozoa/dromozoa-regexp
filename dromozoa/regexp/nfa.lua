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

return function (a)
  local self = {
    _type = "dromozoa.regexp.nfa"
  }

  function self:decode(a)
    self._transition = {}
    self._start = {}
    self._accept = {}
    self._state = 0
    self._stack = {}
    if type(a) == "table" then
      if a._type == "dromozoa.regexp.nfa" then
        self:extended_reg_exp(node)
      end
    end
  end

  function new_state()
    local s = self._state
    self._state = s + 1
    return s
  end

  function self:extended_reg_exp(node)
    local a = { self:ERE_branch() }
    for i = 2, #node do
      a[#a + 1] = 
      -- ???
      self:ERE_branch(node[i])
    end
  end

  function self:ERE_branch(node)
    for i = 1, #node do
      self:ERE_expression(node[i])
    end
  end

  function self:ERE_expression(node)
    local t = type(node)
    if t == "table" then
      local a, b = node[1], node[2]
      self:one_char_or_coll_elem_ERE_or_grouping(a)
      local m, n = 1, 1
      if b then
        m, n = self:ERE_dupl_symbol(b)
      end
    elseif t == "string" then
      self:write(node)
    end
  end

  function self:one_char_or_coll_elem_ERE_or_grouping(node)
    local transition
    local t = type(node)
    if t == "string" then
      transition = character_class(node)
    elseif t == "number" then
      transition = character_class():set_negate()
    elseif t == "table" then
      local u = type(node[1])
      if u == "boolean" then
        transition = character_class(node)
      elseif u == "table" then
        return self:extended_reg_exp(node)
      end
    end
    return transition
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

  return self:encode(a)
end
