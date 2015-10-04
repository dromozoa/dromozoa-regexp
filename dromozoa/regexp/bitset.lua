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

local pairs = require "dromozoa.commons.pairs"

local class = {}

function class.new()
  return {}
end

function class:set(m, n)
  if not n then n = m end
  for i = m, n do
    self[i] = true
  end
  return self
end

function class:reset(m, n)
  if not n then n = m end
  for i = m, n do
    self[i] = nil
  end
  return self
end

function class:flip(m, n)
  if not n then n = m end
  for i = m, n do
    if self[i] then
      self[i] = nil
    else
      self[i] = true
    end
  end
  return self
end

function class:set_union(that)
  for i in that:each() do
    self:set(i)
  end
  return self
end

function class:test(i)
  return self[i]
end

function class:each()
  return pairs(self)
end

function class:count()
  local n = 0
  for _ in pairs(self) do
    n = n + 1
  end
  return n
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
