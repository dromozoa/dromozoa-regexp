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

local string_byte = string.byte
local string_char = string.char

local MIN = 0
local MAX = 255

local class = {}

local function new(a)
  local self = {
    _type = "dromozoa.regexp.character_class";
  }

  function self:decode(a)
    self._bitset = {}
    local t = type(a)
    if t == "table" then
      if a._type == "dromozoa.regexp.character_class" then
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

  function self:test(i)
    return self._bitset[i]
  end

  function self:empty()
    return next(self._bitset) == nil
  end

  function self:count()
    local count = 0
    for k, v in pairs(self._bitset) do
      count = count + 1
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
    for i = MIN, MAX do
      self:flip(i)
    end
    return self
  end

  function self:set_union(that)
    for k, v in pairs(that._bitset) do
      self:set(k)
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
        for i = string_byte(a), string_byte(b) do
          self:set(i)
        end
      else
        self:set_union(class[a])
      end
    elseif t == "string" then
      bitset[string_byte(node)] = true
    end
  end

  function self:encode()
    local count = self:count()
    local n = MAX - MIN + 1
    if count == 0 then
      error "character class is empty"
    elseif count == 1 then
      return string_char((next(self._bitset)))
    elseif count >= n then
      return -1
    end
    local this
    local node
    if count < n / 2 then
      this = self
      node = { true }
    else
      this = new(self):set_negation()
      node = { false }
    end
    local queue = {}
    for i = MIN, MAX do
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
        node[#node + 1] = string_char(a)
      elseif a == b - 1 then
        node[#node + 1] = string_char(a)
        node[#node + 1] = string_char(b)
      else
        node[#node + 1] = { string_char(a), string_char(b) }
      end
    end
    return node
  end

  return self:decode(a)
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
  __call = function (_, ...)
    return new(...)
  end
})
