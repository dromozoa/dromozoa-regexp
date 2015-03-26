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

return function (P, text, i)
  local transition = P.transition
  local start = P.start
  local accept = P.accept

  local b
  local u = P.start
  while true do
    local c = text:byte(i)
    if c == nil then
      c = 256
    else
      c = c + 1
    end
    local v = transition[u][c]
    if v == 0 then
      if accept[u] then
        return u, string.char(b - 1)
      else
        return
      end
      return accept[u]
    end
    b = c
    u = v
    i = i + 1
  end
end
