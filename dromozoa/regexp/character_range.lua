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

return function ()
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

  function self:initialize(bitset, i, j, negate)
  end

  function self:each()
    local n = #_b
    local i = 0
    return function ()
      i = i + 1
      if i <= n then
        return _a[i], _b[i]
      end
    end
  end

  return self
end
