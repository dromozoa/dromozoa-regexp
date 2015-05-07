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

local character_range = require "dromozoa.regexp.character_range"

return function (bitset)
  local n = bitset:count()
  if n == 0 then
    return { "epsilon" }
  elseif n == 256 then
    return { "." }
  elseif bitset:test(257) then
    return { "^" }
  elseif bitset:test(256) then
    return { "$" }
  else
    local is_matching_list = n < 128

    local range = character_range()
    if is_matching_list then
      for i = 0, 255 do
        if bitset:test(i) then
          range:push(i)
        end
      end
    else
      for i = 0, 255 do
        if not bitset:test(i) then
          range:push(i)
        end
      end
    end

    if n == 1 then
      return { "char", string.char((range:each()())) }
    end

    local node
    if is_matching_list then
      node = { "[" }
    else
      node = { "[^" }
    end
    for a, b in range:each() do
      if a == b then
        node[#node + 1] = { "[char", string.char(a) }
      elseif a == b - 1 then
        node[#node + 1] = { "[char", string.char(a) }
        node[#node + 1] = { "[char", string.char(b) }
      else
        node[#node + 1] = { "[-", { "[char", string.char(a) }, { "[char", string.char(b) } }
      end
    end
    return node
  end
end
