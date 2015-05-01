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
local bitset = require "dromozoa.regexp.bitset"
local node_to_bitset = require "dromozoa.regexp.node_to_bitset"
local bitset_to_node = require "dromozoa.regexp.bitset_to_node"
local tree_map = require "dromozoa.regexp.tree_map"

local function set_to_seq(A)
  local B = {}
  for k in pairs(A) do
    B[#B + 1] = k
  end
  table.sort(B)
  return B
end

local function copy_seq(A)
  local B = {}
  for i = 1, #A do
    B[i] = A[i]
  end
  return B
end

local function constructor(_a, _b)
  local self = {
    _map = tree_map();
    _color = {};
  }

  function self:vertex(U)
    local map = self._map
    local v = map:find(U)
    if not v then
      v = _b:create_vertex()
      for i = 1, #U do
        if _a:get_vertex(U[i]).accept then
          v.accept = true
          break
        end
      end
      map:insert(U, v)
    end
    return v
  end

  function self:create_epsilon_closure(U)
    local visitor = dfs_visitor {
      set = {};
      discover_vertex = function (self, g, u)
        self.set[u.id] = true
      end;
      examine_edge = function (self, g, e, u, v)
        return e.condition[1] == "epsilon"
      end;
    }
    for i = 1, #U do
      _a:get_vertex(U[i]):dfs(visitor)
    end
    return set_to_seq(visitor.set)
  end

  function self:create_transition(U)
    local matrix = {}
    for i = 0, 257 do
      matrix[i] = {}
    end
    for i = 1, #U do
      for v, e in _a:get_vertex(U[i]):each_adjacent_vertex() do
        local vid = v.id
        for k in node_to_bitset(e.condition):each() do
          matrix[k][vid] = true
        end
      end
    end
    local map = tree_map()
    for i = 0, 257 do
      local row = matrix[i]
      if next(row) ~= nil then
        map:insert(set_to_seq(row), bitset()):set(i)
      end
    end
    local transition = {}
    for k, v in map:each() do
      transition[#transition + 1] = { bitset_to_node(v), copy_seq(k) }
    end
    return transition
  end

  function self:visit(U)
    local E = self:create_epsilon_closure(U)
    local u = self:vertex(E)
    local color = self._color
    local uid = u.id
    if not color[uid] then
      color[uid] = true
      local transition = self:create_transition(E)
      for i = 1, #transition do
        local t = transition[i]
        _b:create_edge(u, self:visit(t[2])).condition = t[1]
      end
    end
    return u
  end

  function self:construct()
    local start = {}
    for u in _a:each_vertex("start") do
      start[#start + 1] = u.id
    end
    if #start > 0 then
      local s = self:visit(start)
      s.start = true
    end
    return _b
  end

  return self
end

return function (a)
  return constructor(a, graph()):construct()
end
