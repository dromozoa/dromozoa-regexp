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

local function each(i, n, data, key)
  i = i + 1
  if i < n then
    for k, v in pairs(data) do
      key[i] = k
      each(i, n, v, key)
    end
  else
    for k, v in pairs(data) do
      key[i] = k
      coroutine.yield(key, v)
    end
  end
end

return function ()
  local _dataset = {}

  local self = {}

  function self:insert(key, value)
    local n = #key
    local data = _dataset[n]
    if not data then
      data = {}
      _dataset[n] = data
    end
    for i = 1, n - 1 do
      local k = key[i]
      local v = data[k]
      if not v then
        v = {}
        data[k] = v
      end
      data = v
    end
    local k = key[n]
    local v = data[k]
    if v == nil then
      data[k] = value
      return value, true
    else
      return v, false
    end
  end

  function self:erase(key)
    local n = #key
    local data = _dataset[n]
    if not data then
      return
    end
    local dataset = { data }
    for i = 1, n - 1 do
      local k = key[i]
      local v = data[k]
      if not v then
        return
      end
      data = v
      dataset[#dataset + 1] = v
    end
    local k = key[n]
    local v = data[k]
    if v == nil then
      return
    else
      for i = #dataset, 1, -1 do
        local data = dataset[i]
        local k = key[i]
        data[k] = nil
        if next(data) ~= nil then
          return v
        end
      end
      _dataset[n] = nil
      return v
    end
  end

  function self:find(key)
    local n = #key
    local data = _dataset[n]
    if not data then
      return
    end
    for i = 1, n - 1 do
      local k = key[i]
      local v = data[k]
      if not v then
        return
      end
      data = v
    end
    local k = key[n]
    local v = data[k]
    return v
  end

  function self:each()
    return coroutine.wrap(function ()
      for n, data in pairs(_dataset) do
        local key = {}
        each(0, n, data, key)
      end
    end)
  end

  return self
end
