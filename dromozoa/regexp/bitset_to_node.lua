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

local function range_builder()
  local _a = {}
  local _b = {}

  local self = {}

  function self:push(i)
    local n = #_b
    if n > 0 then
      local b = _b[n]
      if b == i - 1 then
        _b[n] = i
        return
      end
    end
    n = n + 1
    _a[n] = i
    _b[n] = i
  end

  function self:each()
    local n = #_b
    local i = 0
    return function ()
      i = i + 1
      if i <= n then
        return string.char(_a[i]), string.char(_b[i])
      end
    end
  end

  return self
end

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

    local builder = range_builder()
    if is_matching_list then
      for i = 0, 255 do
        if set:test(i) then
          builder:push(i)
        end
      end
    else
      for i = 0, 255 do
        if not set:test(i) then
          builder:push(i)
        end
      end
    end

    if n == 1 then
      return { "char", ((builder:each()())) }
    end

    local node
    if is_matching_list then
      node = { "[" }
    else
      node = { "[^" }
    end
    for a, b in builder:each() do
      if a == b then
        node[#node + 1] = { "[char", a }
      elseif a == b - 1 then
        node[#node + 1] = { "[char", a }
        node[#node + 1] = { "[char", b }
      else
        node[#node + 1] = { "[-", { "[char", a }, { "[char", b } }
      end
    end
    return node
  end
end
