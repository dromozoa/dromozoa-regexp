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

local function build_epsilon_reachable(fsm, u, color)
  if not color[u] then
    color[u] = true
    for i, e in fsm:each_u_neighbor(u) do
      if e[4] == 0 then
        build_epsilon_reachable(fsm, e[3], color)
      end
    end
  end
end

local function build_powerset(source, u, target, color)
  if not color[u] then
    color[u] = true

    local epsilon_reachable = {}
    build_epsilon_reachable(source, u, epsilon_reachable)

    for v in pairs(epsilon_reachable) do
      for i, e in source:each_u_neighbor(v) do
        local w, c = e[3], e[4]
        if c ~= 0 then
          target:add_edge(u, w, c)
          build_powerset(source, w, target, color)
        end
      end
    end

    for v in pairs(epsilon_reachable) do
      if source:is_start(v) then
        target:add_start(u)
        break
      end
    end

    for v in pairs(epsilon_reachable) do
      if source:is_accept(v) then
        target:add_accept(u)
        break
      end
    end
  end
end

return function (source, target)
  local color = {}
  for u in source:each_start() do
    build_powerset(source, u, target, color)
  end
  return target
end
