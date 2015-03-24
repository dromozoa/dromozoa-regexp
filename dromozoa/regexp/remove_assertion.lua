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

local dfs_visitor = require "dromozoa.graph.dfs_visitor"

local is_assertion = {
  ["^"] = true;
  ["$"] = true;
}

local function remove_nonmatching_assertion(A, key, mode, assertion)
  local visitor = dfs_visitor {
    color = {};

    examine_edge = function (self, g, e, u, v)
      if is_assertion[e.condition[1]] then
        self.color[e.id] = true
      else
        return false
      end
    end;
  }

  for u in A:each_vertex(key) do
    u:dfs(visitor, mode)
  end
  local color = visitor.color
  for e in A:each_edge() do
    if e.condition[1] == assertion and not color[e.id] then
      e:remove()
    end
  end
end

return function (A)
  remove_nonmatching_assertion(A, "start", "u", "^")
  remove_nonmatching_assertion(A, "accept", "v", "$")

  return A
end
