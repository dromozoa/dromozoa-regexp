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

local function write_indent(out, indent, depth)
  for i = 1, depth do
    out:write(indent)
  end
end

local function dump(data, out, indent, depth)
  local k, v = next(data)
  local t = type(k)
  if t == "number" then
    if type(v) == "table" then
      out:write("{\n")
      for i = 1, #data do
        write_indent(out, indent, depth + 1)
        dump(data[i], out, indent, depth + 1)
        out:write(";\n")
      end
      write_indent(out, indent, depth)
      out:write("}")
    else
      out:write("{")
      for i = 1, #data do
        if i % 64 == 1 then
          out:write("\n")
          write_indent(out, indent, depth + 1)
        end
        local v = data[i]
        if v == false then
          out:write("_,")
        else
          out:write(v, ",")
        end
      end
      out:write("\n")
      write_indent(out, indent, depth)
      out:write("}")
    end
  elseif t == "string" then
    local keys = {}
    for k in pairs(data) do
      keys[#keys + 1] = k
    end
    table.sort(keys)
    out:write("{\n")
    for i = 1, #keys do
      local k = keys[i]
      write_indent(out, indent, depth + 1)
      out:write(k, " = ")
      dump(data[k], out, indent, depth + 1)
      out:write(";\n")
    end
    write_indent(out, indent, depth)
    out:write("}")
  end
end

return function (data, out)
  out:write("local _ = false\nreturn ")
  dump(data, out, "  ", 0)
  out:write("\n")
  return out
end
