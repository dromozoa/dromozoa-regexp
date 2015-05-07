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

local function construct(_data)
  local self = {}

  function self:set(m, n)
    if not n then n = m end
    for i = m, n do
      _data[i] = true
    end
    return self
  end

  function self:reset(m, n)
    if not n then n = m end
    for i = m, n do
      _data[i] = nil
    end
    return self
  end

  function self:flip(m, n)
    if not n then n = m end
    for i = m, n do
      if _data[i] then
        _data[i] = nil
      else
        _data[i] = true
      end
    end
    return self
  end

  function self:set_union(that)
    for i in that:each() do
      self:set(i)
    end
    return self
  end

  function self:test(i)
    return _data[i]
  end

  function self:each()
    return next, _data
  end

  function self:count()
    local n = 0
    for _ in pairs(_data) do
      n = n + 1
    end
    return n
  end

  return self
end

return function ()
  return construct({})
end
