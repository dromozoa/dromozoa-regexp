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

return function (_out, _indent)
  local _depth = 0
  local _buffer = {}

  local self = {}

  local function write(i, j, v, ...)
    if i < j then
      i = i + 1
      if type(v) == "string" then
        for a, b in v:gmatch("([^\n]*)(\n?)") do
          if #a > 0 then
            _buffer[#_buffer + 1] = a
          end
          if #b > 0 then
            self:flush()
            _out:write(b)
          end
        end
      else
        _buffer[#_buffer + 1] = v
      end
      return write(i, j, ...)
    else
      return self
    end
  end

  function self:add(n)
    if not n then n = 1 end
    _depth = _depth + n
    return self
  end

  function self:sub(n)
    if not n then n = 1 end
    _depth = _depth - n
    return self
  end

  function self:write(...)
    return write(0, select("#", ...), ...)
  end

  function self:flush()
    _out:write(string.rep(_indent, _depth), table.concat(_buffer))
    for i = 1, #_buffer do
      _buffer[i] = nil
    end
    return _out
  end

  return self
end
