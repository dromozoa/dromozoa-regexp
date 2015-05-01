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

local string_char = string.char

return function (set)
  local n = set:count()
  if n == 0 then
    return { "epsilon" }
  elseif n == 256 then
    return { "." }
  elseif set:test(257) then
    return { "^" }
  elseif set:test(256) then
    return { "$" }
  else
    local is_matching_list = n < 128
    local t = {}
    for i = 0, 255 do
      if set:test(i) == is_matching_list then
        local v = t[#t]
        if v and v[2] == i - 1 then
          v[2] = i
        else
          t[#t + 1] = { i, i }
        end
      end
    end
    if n == 1 then
      return { "char", string_char(t[1][1]) }
    end
    local node = { is_matching_list and "[" or "[^" }
    for i = 1, #t do
      local v = t[i]
      local a, b = v[1], v[2]
      if a == b then
        node[#node + 1] = { "[char", string_char(a) }
      elseif a == b - 1 then
        node[#node + 1] = { "[char", string_char(a) }
        node[#node + 1] = { "[char", string_char(b) }
      else
        node[#node + 1] = { "[-", { "[char", string_char(a) }, { "[char", string_char(b) } }
      end
    end
    return node
  end
end
