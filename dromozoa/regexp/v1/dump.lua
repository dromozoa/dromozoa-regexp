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

return function (data, out)
  out:write(string.format([[
local _ = false
return {
  start = %d;
  accepts = {
]], data.start))
  out:write("    ")
  for i = 1, #data.accepts do
    local v = data.accepts[i]
    if v then
      out:write(v, ",")
    else
      out:write("_,")
    end
  end
  out:write("\n"):write([[
  };
  transitions = {
]])
  out:write("    ")
  for i = 1, 255 do
    out:write("_,")
  end
  for i = 256, #data.transitions do
    local v = data.transitions[i]
    if i % 256 == 0 then
      out:write("\n    ")
    end
    if v then
      out:write(v, ",")
    else
      out:write("_,")
    end
  end
  out:write("\n"):write([[
  };
  end_assertions = {
]])
  out:write("    ")
  for i = 1, #data.end_assertions do
    local v = data.end_assertions[i]
    if v then
      out:write(v, ",")
    else
      out:write("_,")
    end
  end
  out:write("\n"):write([[
  };
}
]])
  return out
end
