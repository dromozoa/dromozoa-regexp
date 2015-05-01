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

local function write(buffer, i, j, v, ...)
  buffer[i] = v
  if i < j then
    return write(buffer, i + 1, j, ...)
  end
end

return function ()
  local _buffer = {}

  local self = {}

  function self:write(...)
    local i = #_buffer + 1
    local j = i + select("#", ...)
    write(_buffer, i, j, ...)
    return self
  end

  function self:concat(...)
    return table.concat(_buffer, ...)
  end

  return self
end
