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

return function()
  local self = {
    _t = {};
  }

  function self:set(m, n)
    local t = self._t
    for i = m, n or m do
      t[i] = true
    end
    return self
  end

  function self:reset(m, n)
    local t = self._t
    for i = m, n or m do
      t[i] = nil
    end
    return self
  end

  function self:flip(m, n)
    local t = self._t
    for i = m, n or m do
      if t[i] then
        t[i] = nil
      else
        t[i] = true
      end
    end
    return self
  end

  function self:test(i)
    return self._t[i] ~= nil
  end

  function self:count()
    local n = 0
    for k in pairs(self._t) do
      n = n + 1
    end
    return n
  end

  function self:set_union(that)
    for k in pairs(that._t) do
      self:set(k)
    end
    return self
  end

  function self:each()
    return next, self._t
  end

  return self
end
