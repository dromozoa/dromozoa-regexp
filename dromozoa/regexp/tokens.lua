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

local class = {}

function class.intersection(a, b)
  if a ~= nil and b ~= nil then
    if a < b then
      return a
    else
      return b
    end
  end
end

function class.union(a, b)
  if a ~= nil then
    if b ~= nil then
      if a < b then
        return a
      else
        return b
      end
    end
    return a
  end
  return b
end

function class.difference(a, b)
  if a ~= nil and b == nil then
    return a
  end
end

return class
