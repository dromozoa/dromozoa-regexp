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

local buffer_writer = require "dromozoa.regexp.buffer_writer"

local header = [[
return function (ctx, out)
  local save = {}
  for k, v in pairs(_G) do
    save[k] = v
  end
  for k, v in pairs(ctx) do
    _G[k] = v
  end
]]

local footer = [[
  for k, v in pairs(_G) do
    _G[k] = save[k]
  end
  return out
end
]]

return function (template)
  local out = buffer_writer()
  out:write(header)

  local prechomp = 0
  local postchomp = 0
  local is_expr = 0

  for a, b in (template .. "[%%]"):gmatch("(.-)%[%%%s*(.-)%s*%%%]") do
    b, prechomp = b:gsub("^%-%s*", "")

    if prechomp > 0 then
      a = a:gsub("%s$", "")
    end
    if postchomp > 0 then
      a = a:gsub("^%s", "")
    end
    if #a > 0 then
      out:write(string.format("out:write(%q)\n", a))
    end

    b, postchomp = b:gsub("%s*%-$", "")
    b, is_expr = b:gsub("^=%s*", "")

    if #b > 0 then
      if is_expr > 0 then
        out:write("out:write(", b, ")\n")
      else
        out:write(b, "\n")
      end
    end
  end

  out:write(footer)
  return out:concat()
end
