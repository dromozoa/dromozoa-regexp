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

return function (this)
  local state = 0
  for u in this:each_vertex("start") do
    state = state + 1
    u.state = state
  end
  if state ~= 1 then
    error("only one start state allowed")
  end
  start = state

  for u in this:each_vertex() do
    if u.start == nil then
      state = state + 1
      u.state = state
    end
  end

  local accepts = {}
  for i = 1, state do
    accepts[i] = 0
  end
  for u in this:each_vertex("accept") do
    accepts[u.state] = u.accept
  end

  local transitions = {}
  local end_assertions = {}
  for u in this:each_vertex() do
    local cs = u.state
    local offset = cs * 256 - 255

    for i = offset, offset + 255 do
      transitions[i] = 0
    end
    end_assertions[cs] = 0

    for v, e in u:each_adjacent_vertex() do
      local ns = v.state
      local condition = e.condition
      if condition:test(256) then
        end_assertions[cs] = ns
      else
        for k, v in condition:each() do
          transitions[offset + k] = ns
        end
      end
    end
  end

  return {
    start = start;
    accepts = accepts;
    transitions = transitions;
    end_assertions = end_assertions;
  }
end
