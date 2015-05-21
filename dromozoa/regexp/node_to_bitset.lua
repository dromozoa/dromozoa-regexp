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

local function converter()
  local _bitset = bitset()

  local self = {
    ["epsilon"] = function (self)
    end;

    ["^"] = function (self)
      _bitset:set(257)
    end;

    ["$"] = function (self)
      _bitset:set(256)
    end;

    ["char"] = function (self, node, a)
      _bitset:set(string.byte(a))
    end;

    ["\\"] = function (self, node, a)
      _bitset:set(string.byte(a))
    end;

    ["."] = function (self)
      _bitset:set(0, 255)
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
      _bitset:flip(0, 255)
    end;

    ["[:"] = function (self, node, a)
      _bitset:set_union(character_class[a])
    end;

    ["[-"] = function (self, node, a, b)
      _bitset:set(string.byte(a[2]), string.byte(b[2]))
    end;

    ["[."] = function (self, node)
      _bitset:set(string.byte(node[2]))
    end;

    ["[char"] = function (self, node)
      _bitset:set(string.byte(node[2]))
    end;
  }

  function self:visit(node)
    return self[node[1]](self, node, node[2], node[3], node[4])
  end

  function self:convert(node)
    self:visit(node)
    return _bitset
  end

  return self
end

return function (node)
  return converter():convert(node)
end
