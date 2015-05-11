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
  out:write("return {\n")
  out:write(string.format("start = %d;\n", code.start))
  out:write(string.format("accept_min = %d;\n", code.accept_min))
  out:write(string.format("accept_max = %d;\n", code.accept_max))
  out:write("accept_tokens = {")
  local accept_tokens = code.accept_tokens
  for i = 1, #accept_tokens do
    out:write(string.format("%d,", accept_tokens[i]))
  end
  out:write("};\n")
  out:write("transitions = {\n")
  local transitions = code.transitions
  for i = 1, #transitions do
    out:write(string.format("%d,", transitions[i]))
    if i % 257 == 0 then
      out:write("\n")
    end
  end
  out:write("};\n")
  out:write("}\n")
  return out
end
