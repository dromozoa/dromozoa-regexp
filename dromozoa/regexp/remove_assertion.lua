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
local dfs_visitor = require "dromozoa.graph.dfs_visitor"

local is_assertion = {
  ["^"] = true;
  ["$"] = true;
}

local function examine_edge(self, g, e, u, v)
  if is_assertion[e.condition[1]] then
    self.color[e.id] = true
  else
    return false
  end
end

local function remove_nonmatching_begin_assertion(g)
  local visitor = dfs_visitor {
    color = {};
    examine_edge = examine_edge;
  }
  for v in g:each_vertex "start" do
    v:dfs(visitor)
  end
  local color = visitor.color
  for e in g:each_edge() do
    if e.condition[1] == "^" and not color[e.id] then
      e:remove()
    end
  end
end

local function remove_nonmatching_end_assertion(g)
  local visitor = dfs_visitor {
    color = {};
    examine_edge = examine_edge;
  }
  for v in g:each_vertex "accept" do
    v:dfs(visitor, "v")
  end
  local color = visitor.color
  for e in g:each_edge() do
    if e.condition[1] == "$" and not color[e.id] then
      e:remove()
    end
  end
end

local function collapse_begin_assertion(g)
  for e in g:each_edge() do
    if e.condition[1] == "^" then
      if e.v.accept then
        e.u.accept = true
      end
      e:collapse()
    end
  end
end

local function remove_begin_assertion(g)
  for e in g:each_edge() do
    if e.condition[1] == "^" then
      e:remove()
    end
  end
end

local function collapse_end_assertion(g)
  local color = {}
  for v in g:each_vertex "accept" do
    for u, e in v:each_adjacent_vertex "v" do
      color[e.id] = true
    end
  end
  for e in g:each_edge() do
    if e.condition[1] == "$" and not color[e.id] then
      if e.v.accept then
        e.u.accept = true
      end
      e:collapse()
    end
  end
end

return function (A)
  local B = A:clone()
  remove_nonmatching_begin_assertion(B)
  remove_nonmatching_end_assertion(B)
  local C = B:clone()
  collapse_begin_assertion(B)
  collapse_end_assertion(B)
  remove_begin_assertion(C)
  collapse_end_assertion(C)
  return B, C
end
