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

local clone = require "dromozoa.commons.clone"
local graph = require "dromozoa.graph"

local function remove_assertion(g, op, color)
  if color then
    for e in g:each_edge() do
      if e.condition[1] == op and not color[e.id] then
        e:remove()
      end
    end
  else
    for e in g:each_edge() do
      if e.condition[1] == op then
        e:remove()
      end
    end
  end
end

local function collapse_assertion(g, op, color)
  if color then
    for e in g:each_edge() do
      if e.condition[1] == op and not color[e.id] then
        e.u.accept = e.v.accept
        e:collapse()
      end
    end
  else
    for e in g:each_edge() do
      if e.condition[1] == op then
        e.u.accept = e.v.accept
        e:collapse()
      end
    end
  end
end

local function assertion_visitor(_result)
  local self = {}

  function self:examine_edge(g, e, u, v)
    local op = e.condition[1]
    if op == "^" or op == "$" then
      _result[e.id] = true
    else
      return false
    end
  end

  return self
end

local function remove_nonmatching_assertion(g, key, mode, op)
  local color = {}
  local visitor = assertion_visitor(color)
  for v in g:each_vertex(key) do
    v:dfs(visitor, mode)
  end
  remove_assertion(g, op, color)
end

local function collapse_end_assertion(g)
  local color = {}
  for v in g:each_vertex("accept") do
    for _, e in v:each_adjacent_vertex("v") do
      color[e.id] = true
    end
  end
  collapse_assertion(g, "$", color)
end

return function (a)
  remove_nonmatching_assertion(a, "start", "u", "^")
  remove_nonmatching_assertion(a, "accept", "v", "$")
  local b = clone(a)

  collapse_assertion(a, "^")
  collapse_end_assertion(a)

  remove_assertion(b, "^")
  collapse_end_assertion(b)

  return b
end
