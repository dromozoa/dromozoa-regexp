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

return require "dromozoa.commons.sequence_writer"

--[[

return function ()
  local _buffer = {}

  local self = {}

  local function write(i, j, v, ...)
    if i < j then
      i = i + 1
      _buffer[i] = v
      return write(i, j, ...)
    else
      return self
    end
  end

  function self:write(...)
    local n = #_buffer
    return write(n, n + select("#", ...), ...)
  end

  function self:concat(...)
    return table.concat(_buffer, ...)
  end

  return self
end

]]
