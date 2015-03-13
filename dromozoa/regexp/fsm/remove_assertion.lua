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

local function build_assertion_reachable_u_neighbor(fsm, u, color)
  if not color[u] then
    color[u] = true
    for i, e in fsm:each_u_neighbor(u) do
      local c = e[4]
      if c == 1 or c == 2 then
        build_assertion_reachable_u_neighbor(fsm, e[3], color)
      end
    end
  end
end

local function build_assertion_reachable_v_neighbor(fsm, v, color)
  if not color[v] then
    color[v] = true
    for i, e in fsm:each_v_neighbor(v) do
      local c = e[4]
      if c == 1 or c == 2 then
        build_assertion_reachable_v_neighbor(fsm, e[2], color)
      end
    end
  end
end

return function (fsm)
  local assertion_reachable_u_neighbor = {}
  for u in fsm:each_start() do
    build_assertion_reachable_u_neighbor(fsm, u, assertion_reachable_u_neighbor)
  end

  local assertion_reachable_v_neighbor = {}
  for v in fsm:each_accept() do
    build_assertion_reachable_v_neighbor(fsm, v, assertion_reachable_v_neighbor)
  end

  for i, e in fsm:each_edge() do
    local u, v, c = e[2], e[3], e[4]
    if c == 1 then
      if not assertion_reachable_u_neighbor[u] then
        fsm:remove_edge(e)
      end
    elseif c == 2 then
      if not assertion_reachable_v_neighbor[v] then
        fsm:remove_edge(e)
      end
    end
  end
end
