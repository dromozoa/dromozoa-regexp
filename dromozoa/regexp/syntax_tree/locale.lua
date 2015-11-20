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

local bitset = require "dromozoa.commons.bitset"

local function get_posix_character_classes()
  local character_classes = {}

  character_classes.upper = bitset()
    :set(string.byte("AZ", 1, 2))

  character_classes.lower = bitset()
    :set(string.byte("az", 1, 2))

  character_classes.alpha = bitset()
    :set_union(character_classes.upper)
    :set_union(character_classes.lower)

  character_classes.digit = bitset()
    :set(string.byte("09", 1, 2))

  character_classes.alnum = bitset()
    :set_union(character_classes.alpha)
    :set_union(character_classes.digit)

  character_classes.space = bitset()
    :set(string.byte(" ", 1, 2))
    :set(string.byte("\f", 1, 2))
    :set(string.byte("\n", 1, 2))
    :set(string.byte("\r", 1, 2))
    :set(string.byte("\t", 1, 2))
    :set(string.byte("\v", 1, 2))

  character_classes.cntrl = bitset()
    :set(0, 31)
    :set(127)

  character_classes.punct = bitset()
    :set(string.byte("!/", 1, 2))
    :set(string.byte(":@", 1, 2))
    :set(string.byte("[`", 1, 2))
    :set(string.byte("{~", 1, 2))

  character_classes.graph = bitset()
    :set_union(character_classes.alnum)
    :set_union(character_classes.punct)

  character_classes.print = bitset()
    :set_union(character_classes.graph)
    :set(string.byte(" "))

  character_classes.xdigit = bitset()
    :set(string.byte("09", 1, 2))
    :set(string.byte("AF", 1, 2))
    :set(string.byte("af", 1, 2))

  character_classes.blank = bitset()
    :set(string.byte(" "))
    :set(string.byte("\t"))

  return character_classes
end

local function get_posix_collating_elements()
  local collating_elements = {}
  for i = 0, 127 do
    collating_elements[string.char(i)] = i
  end
  return collating_elements
end

local A, Z = string.byte("AZ", 1, 2)
local a, z = string.byte("az", 1, 2)
local tolower = a - A
local toupper = A - a

local function posix_islower(byte)
  return a <= byte and byte <= z
end

local function posix_isupper(byte)
  return A <= byte and byte <= Z
end

local function posix_tolower(byte)
  if posix_isupper(byte) then
    return byte + tolower
  else
    return byte
  end
end

local function posix_toupper(byte)
  if posix_islower(byte) then
    return byte + toupper
  else
    return byte
  end
end

return {
  character_classes = get_posix_character_classes();
  collating_elements = get_posix_collating_elements();
  islower = posix_islower;
  isupper = posix_isupper;
  tolower = posix_tolower;
  toupper = posix_toupper;
}
