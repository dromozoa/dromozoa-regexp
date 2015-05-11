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

local graph = require "dromozoa.graph"
local merge = require "dromozoa.regexp.merge"

local function get_property(g, key, min)
  for u in g:each_vertex(key) do
    local v = u[key]
    if min == nil or min > v then
      min = v
    end
  end
  return min
end

return function (a, b)
  local result = graph()
  local s = result:create_vertex()
  s.start = get_property(b, "start", get_property(a, "start"))
  return merge.start(b, merge.start(a, result, s), s)
end
