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

local sequence = require "dromozoa.commons.sequence"
local xml = require "dromozoa.commons.xml"

local function quote_char(byte)
  local char = string.char(byte)
  if char:match("^%g$") then
    return xml.escape("'" .. char .. "'", "%W")
  else
    return string.format("0x%02X", byte)
  end
end

local class = {}

function class.quote_condition(condition)
  if condition == nil then
    return "&epsilon;"
  elseif condition:test(256) then
    return "^"
  elseif condition:test(257) then
    return "$"
  else
    local out = sequence()
    for range in condition:ranges():each() do
      local a, b = range[1], range[2]
      if a == b then
        out:push(quote_char(a))
      elseif a == b - 1 then
        out:push(quote_char(a))
        out:push(quote_char(b))
      else
        out:push(quote_char(a) .. "-" .. quote_char(b))
      end
    end
    return out:concat()
  end
end

return class
