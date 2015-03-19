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

local bitset = require "dromozoa.regexp.bitset"
local character_class = require "dromozoa.regexp.character_class"

local function decoder(b)
  local self = {
    _b = b;

    ["epsilon"] = function (self)
    end;

    ["^"] = function (self)
      self:set(256)
    end;

    ["$"] = function (self)
      self:set(257)
    end;

    ["char"] = function (self, node, a)
      self:set(string.byte(a))
    end;

    ["\\"] = function (self, node, a)
      self:set(string.byte(a))
    end;

    ["."] = function (self)
      self:set(0, 255)
    end;

    ["["] = function (self, node)
      for i = 2, #node do
        self:visit(node[i])
      end
    end;

    ["[^"] = function (self, node)
      for i = 2, #node do
        self:visit(node[i])
      end
      self:flip(0, 255)
    end;

    ["[:"] = function (self, node, a)
      self:set_union(character_class[a])
    end;

    ["[-"] = function (self, node, a, b)
      self:set(string.byte(a), string.byte(b))
    end;

    ["[."] = function (self, node, a)
      self:set(string.byte(a))
    end;

    ["[char"] = function (self, node, a)
      self:set(string.byte(a))
    end;
  }

  function self:set(m, n)
    self._b:set(m, n)
  end

  function self:flip(m, n)
    self._b:flip(m, n)
  end

  function self:set_union(that)
    self._b:set_union(that)
  end

  function self:visit(node)
    self[node[1]](self, node, node[2], node[3], node[4])
  end

  function self:decode(node)
    self:visit(node)
  end

  return self
end

return function (node)
  local b = bitset()
  decoder(b):decode(node)
  return b
end
