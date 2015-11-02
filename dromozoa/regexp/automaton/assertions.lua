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

local class = {}

function class.remove_nonmatching_assertions(this)
  local visitor = {
    examine_edge = function (self, e)
      local condition = e.condition
      if condition:test(257) then
        e.color = "^"
      elseif condition:test(256) then
        e.color = "$"
      else
        return false
      end
    end;
  }
  for u in this:each_vertex("start") do
    u:dfs(visitor)
  end
  for v in this:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  for e in this:each_edge() do
    local condition = e.condition
    if (condition:test(257) or condition:test(256)) and e.color == nil then
      e:remove()
    end
  end
  this:clear_edge_properties("color")
  return this
end



return class
