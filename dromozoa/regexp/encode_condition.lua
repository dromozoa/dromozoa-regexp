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

local function create_node(a, b)
  if a == b then
    return { "[char", string.char(a) }
  else
    return { "[-", { "[char", string.char(a) }, { "[char", string.char(b) } }
  end
end

return function (set)
  local count = set:count()
  if count == 0 then
    return { "epsilon" }
  elseif set:test(256) then
    return { "^" }
  elseif set:test(257) then
    return { "$" }
  elseif count < 128 then
    local t = {}
    for i = 0, 255 do
      if set:test(i) then
        local v = t[#t]
        if v and v[2] == i - 1 then
          v[2] = i
        else
          t[#t + 1] = { i, i }
        end
      end
    end
    if count == 1 then
      return { "char", string.char(t[1][1]) }
    end
    local node = { "[" }
    for i = 1, #t do
      local v = t[i]
      node[#node + 1] = create_node(v[1], v[2])
    end
    return node
  else
    local t = {}
    for i = 0, 255 do
      if not set:test(i) then
        local v = t[#t]
        if v and v[2] == i - 1 then
          v[2] = i
        else
          t[#t + 1] = { i, i }
        end
      end
    end
    local node = { "[^" }
    for i = 1, #t do
      local v = t[i]
      node[#node + 1] = create_node(v[1], v[2])
    end
    return node
  end
end
