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
  out:write("accept_token = {")
  local accept_token = code.accept_token
  for i = 1, #accept_token do
    out:write(string.format("%d,", accept_token[i]))
  end
  out:write("};\n")
  out:write("transition = {\n")
  local transition = code.transition
  for i = 1, #transition do
    out:write(string.format("%d,", transition[i]))
    if i % 257 == 0 then
      out:write("\n")
    end
  end
  out:write("};\n")
  out:write("}\n")
  return out
end
