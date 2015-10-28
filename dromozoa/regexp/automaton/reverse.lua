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

return function (this)
  local that = graph()
  local map = {}
  for a in this:each_vertex() do
    local b = that:create_vertex()
    map[a.id] = b.id
    b.start = a.accept
    b.accept = a.start
  end
  for a in this:each_edge() do
    local b = that:create_edge(map[a.vid], map[a.uid])
    -- not clone
    b.condition = a.condition
  end
  return that
end
