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

local format = string.format
local ere_unparser = require "dromozoa.regexp.ere_unparser"

local quote_impl = {
  ["\""] = "\\\"";
  ["\\"] = "\\\\";
  ["\n"] = "\\n";
}

local function quote(v)
  return "\"" .. v:gsub("[\"\\\n]", quote_impl) .. "\""
end

local function buffer()
  local self = { _buffer = {} }

  function self:write(...)
    local b = self._buffer
    for i = 1, select("#", ...) do
      b[#b + 1] = select(i, ...)
    end
  end

  function self:concat()
    return table.concat(self._buffer)
  end

  return self
end

return function (a)
  local self = {
    _type = "dromozoa.regexp.nfa"
  }

  function self:decode(a)
    self._transition = {}
    self._start = {}
    self._accept = {}
    self._state = 0
    if type(a) == "table" then
      self:extended_reg_exp(a, self:new_state())
    end
  end

  function self:new_state()
    local s = self._state
    self._state = s + 1
    return s
  end

  function self:new_transition(c, u, v)
    local a = self._transition
    local b = a[u]
    if b then
      b[#b + 1] = { c, v }
    else
      a[u] = { { c, v } }
    end
    return v
  end

  function self:extended_reg_exp(node, u)
    local e = self:new_state()
    for i = 1, #node do
      local v = self:new_state()
      self:new_transition(nil, u, v)
      local w = self:ERE_branch(node[i], v)
      self:new_transition(nil, w, e)
      print(u, v, w, e)
    end
    return e
  end

  function self:ERE_branch(node, u)
    for i = 1, #node do
      local v = self:ERE_expression(node[i], u)
      u = v
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
        local v = self:one_char_or_coll_elem_ERE_or_grouping(a, u)
        u = v
      end
      if n then
        for i = m + 1, n do
          local v = self:one_char_or_coll_elem_ERE_or_grouping(a, u)
          self:new_transition(nil, u, v)
          u = v
        end
      else
        local v = self:one_char_or_coll_elem_ERE_or_grouping(a, u)
        local w = self:new_state()
        self:new_transition(nil, v, u)
        self:new_transition(nil, u, w)
        u = w
      end
    elseif t == "string" then
      -- [TODO] anchoring
    end
    return u
  end

  function self:one_char_or_coll_elem_ERE_or_grouping(node, U)
    local t = type(node)
    if t == "string" then
      return self:new_transition(node, U, self:new_state())
    elseif t == "number" then
      return self:new_transition(node, U, self:new_state())
    elseif t == "table" then
      local u = type(node[1])
      if u == "boolean" then
        return self:new_transition(node, U, self:new_state())
      elseif u == "table" then
        return self:extended_reg_exp(node, U)
      end
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

  function self:encode_dot(out)
    out:write("digraph \"nfa\" {\n")
    for k, v in pairs(self._transition) do
      for i = 1, #v do
        local a = v[i]
        if a[1] then
          local b = buffer()
          local u = ere_unparser()
          u._out = b
          u:one_char_or_coll_elem_ERE_or_grouping(a[1])
          out:write(format("%s -> %s [label = %s];\n", k, a[2], quote(b:concat())))
        else
          out:write(format("%s -> %s [label = \"&epsilon;\"];\n", k, a[2]))
        end
      end
    end
    out:write("}\n")
  end

  return self
end
