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
  local self = {
    _t = {};
  }

  function self:find(key)
    local n = #key
    local t = self._t
    local u = t[n]
    if not u then
      return nil
    end
    for i = 1, n do
      u = u[key[i]]
      if u == nil then
        return nil
      end
    end
    return u
  end

  function self:insert(key, value)
    local n = #key
    local t = self._t
    local u = t[n]
    if not u then
      u = {}
      t[n] = u
    end
    for i = 1, n - 1 do
      local k = key[i]
      local v = u[k]
      if not v then
        v = {}
        u[k] = v
      end
      u = v
    end
    local k = key[n]
    local v = u[k]
    if v == nil then
      u[k] = value
      return value, true
    else
      return v, false
    end
  end

  function self:erase(key)
    local n = #key
    local t = self._t
    local u = t[n]
    if not u then
      return nil
    end
    local s = { u }
    for i = 1, n - 1 do
      u = u[key[i]]
      if not u then
        return nil
      end
      s[#s + 1] = u
    end
    local v = u[key[n]]
    if v == nil then
      return nil
    else
      -- {1,2,3}
      -- {{},{},{}}
      for i = #s, 1, -1 do
        local w = s[i]
        w[key[i]] = nil
        if next(w) ~= nil then
          return v
        end
      end

      return v
    end
  end

  return self
end
