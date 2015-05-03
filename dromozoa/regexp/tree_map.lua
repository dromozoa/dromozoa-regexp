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

local function find(i, n, data, keys, path)
  i = i + 1
  local k = keys[i]
  local v = data[k]
  if path then
    path[i + 1] = v
  end
  if i < n then
    if v then
      return find(i, n, v, keys, path)
    end
  else
    return v
  end
end

local function insert(i, n, data, keys, value)
  i = i + 1
  local k = keys[i]
  local v = data[k]
  if i < n then
    if not v then
      v = {}
      data[k] = v
    end
    return insert(i, n, v, keys, value)
  else
    if v == nil then
      data[k] = value
      return value, true
    else
      return v, false
    end
  end
end

local function erase(i, keys, path)
  local k = keys[i]
  local v = path[i]
  v[k] = nil
  if i > 1 and not next(v) then
    return erase(i - 1, keys, path)
  end
end

local function each(i, n, data, keys)
  i = i + 1
  if i < n then
    for k, v in pairs(data) do
      keys[i] = k
      each(i, n, v, keys)
    end
  else
    for k, v in pairs(data) do
      keys[i] = k
      coroutine.yield(keys, v)
    end
  end
end

return function ()
  local _dataset = {}

  local self = {}

  function self:insert(keys, value)
    local n = #keys
    local data = _dataset[n]
    if not data then
      data = {}
      _dataset[n] = data
    end
    return insert(0, n, data, keys, value)
  end

  function self:erase(keys)
    local n = #keys
    local data = _dataset[n]
    if data then
      local path = { data }
      local v = find(0, n, data, keys, path)
      if v ~= nil then
        erase(n, keys, path)
      end
      return v
    end
  end

  function self:find(keys)
    local n = #keys
    local data = _dataset[n]
    if data then
      return find(0, n, data, keys)
    end
  end

  function self:each()
    return coroutine.wrap(function ()
      for n, data in pairs(_dataset) do
        each(0, n, data, {})
      end
    end)
  end

  return self
end
