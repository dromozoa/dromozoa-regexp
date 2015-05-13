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

return function (code, out)
  out:write("local f = false\n")
  out:write("return {\n")
  out:write(string.format("start = %d;\n", code.start))
  out:write("accepts = {")
  local accepts = code.accepts
  for i = 1, #accepts do
    local v = accepts[i]
    if v == false then
      out:write("f,")
    else
      out:write(string.format("%d,", accepts[i]))
    end
  end
  out:write("};\n")
  out:write("transitions = {\n")
  local transitions = code.transitions
  for i = 1, 255 do
    local v = transitions[i]
    if v == false then
      out:write("f,")
    else
      out:write(string.format("%d,", v))
    end
  end
  out:write("\n")
  for i = 256, #transitions do
    local v = transitions[i]
    if v == false then
      out:write("f,")
    else
      -- print(i, v, #transitions)
      out:write(string.format("%d,", v))
    end
    if i % 256 == 255 then
      out:write("\n")
    end
  end
  out:write("};\n")
  out:write("end_assertions = {")
  local end_assertions = code.end_assertions
  for i = 1, #end_assertions do
    local v = end_assertions[i]
    if v == false then
      out:write("f,")
    else
      out:write(string.format("%d,", v))
    end
  end
  out:write("};\n")
  out:write("}\n")
  return out
end
