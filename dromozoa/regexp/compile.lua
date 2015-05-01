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

local node_to_condition = require "dromozoa.regexp.node_to_condition"

return function (G)
  local program = {
    transition = {};
    accept = {};
  }

  for u in G:each_vertex() do
    local transition = {}
    for i = 0, 256 do
      transition[i + 1] = 0
    end
    for v, e in u:each_adjacent_vertex() do
      for k in node_to_condition(e.condition):each() do
        transition[k + 1] = v.id
      end
    end
    program.transition[u.id] = transition
    if u.start then
      program.start = u.id
    end
    if u.accept then
      program.accept[u.id] = true
    end
  end

  return program
end
