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
local string_byte = string.byte

local character_class = {}
character_class.upper = bitset()
  :set(string_byte("AZ", 1, 2))
character_class.lower = bitset()
  :set(string_byte("az", 1, 2))
character_class.digit = bitset()
  :set(string_byte("09", 1, 2))
character_class.space = bitset()
  :set(string_byte " ")
  :set(string_byte "\f")
  :set(string_byte "\n")
  :set(string_byte "\r")
  :set(string_byte "\t")
  :set(string_byte "\v")
character_class.cntrl = bitset()
  :set(0, 31)
  :set(127)
character_class.punct = bitset()
  :set(string_byte("!/", 1, 2))
  :set(string_byte(":@", 1, 2))
  :set(string_byte("[`", 1, 2))
  :set(string_byte("{~", 1, 2))
character_class.xdigit = bitset()
  :set(string_byte("09", 1, 2))
  :set(string_byte("AF", 1, 2))
  :set(string_byte("af", 1, 2))
character_class.blank = bitset()
  :set(string_byte " ")
  :set(string_byte "\t")
character_class.alpha = bitset()
  :set_union(character_class.upper)
  :set_union(character_class.lower)
character_class.alnum = bitset()
  :set_union(character_class.alpha)
  :set_union(character_class.digit)
character_class.graph = bitset()
  :set_union(character_class.alnum)
  :set_union(character_class.punct)
character_class.print = bitset()
  :set_union(character_class.graph)
  :set(string_byte " ")
return character_class
