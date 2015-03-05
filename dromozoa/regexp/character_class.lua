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

local class = {}

local function new(a)
  local self = {
    _bitset = {}
  }

  function self:test(i)
    return self._bitset[i]
  end

  function self:count()
    local count = 0
    for i = 0, 255 do
      if self:test(i) then
        count = count + 1
      end
    end
    return count
  end

  function self:set(i)
    self._bitset[i] = true
    return self
  end

  function self:flip(i)
    local bitset = self._bitset
    if bitset[i] then
      bitset[i] = nil
    else
      bitset[i] = true
    end
    return self
  end

  function self:set_negation()
    for i = 0, 255 do
      self:flip(i)
    end
    return self
  end

  function self:set_union(that)
    for i = 0, 255 do
      if that:test(i) then
        self:set(i)
      end
    end
    return self
  end

  function self:bracket_expression(node)
    for i = 2, #node do
      self:expression_term(node[i])
    end
    if not node[1] then
      self:set_negation()
    end
  end

  function self:expression_term(node)
    local bitset = self._bitset
    local t = type(node)
    if t == "table" then
      local a, b = node[1], node[2]
      if b then
        for i = string.byte(a), string.byte(b) do
          bitset[i] = true
        end
      else
        self:set_union(class[a])
      end
    elseif t == "string" then
      bitset[string.byte(node)] = true
    end
  end

  function self:to_ast()
    local count = self:count()
    if count < 256 then
      local this
      local node
      if count < 128 then
        this = self
        node = { true }
      else
        this = new(self):set_negation()
        node = { false }
      end
      local queue = {}
      for i = 0, 255 do
        if this:test(i) then
          local v = queue[#queue]
          if v and v[2] == i - 1 then
            v[2] = i
          else
            queue[#queue + 1] = { i, i }
          end
        end
      end
      for i = 1, #queue do
        local v = queue[i]
        local a, b = v[1], v[2]
        if a == b then
          node[#node + 1] = string.char(a)
        elseif a == b - 1 then
          node[#node + 1] = string.char(a)
          node[#node + 1] = string.char(b)
        else
          node[#node + 1] = { string.char(a), string.char(b) }
        end
      end
      return node
    else
      return -1
    end
  end

  local t = type(a)
  if t == "table" then
    if a._bitset then
      self:set_union(a)
    elseif type(a[1]) == "boolean" then
      self:bracket_expression(a)
    else
      self:expression_term(a)
    end
  elseif t == "string" then
    self:expression_term(a)
  end

  return self
end

class.upper  = new { "A", "Z" }
class.lower  = new { "a", "z" }
class.digit  = new { "0", "9" }
class.space  = new { true, " ", "\f", "\n", "\r", "\t", "\v" }
class.cntrl  = new { true, { "\000", "\031" }, "\127" }
class.punct  = new { true, { "!", "/" }, { ":", "@" }, { "[", "`" }, { "{", "~"  } }
class.xdigit = new { true, { "0", "9" }, { "A", "F" }, { "a", "f" } }
class.blank  = new { " ", "\t" }
class.alpha  = new(class.upper):set_union(class.lower)
class.alnum  = new(class.alpha):set_union(class.digit)
class.graph  = new(class.alnum):set_union(class.punct)
class.print  = new(class.graph):set_union(new " ")

return setmetatable(class, {
  __call = function (class, ...)
    return new(...)
  end
})
