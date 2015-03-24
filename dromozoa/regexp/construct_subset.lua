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
local decode_condition = require "dromozoa.regexp.decode_condition"
local encode_condition = require "dromozoa.regexp.encode_condition"
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

local function create_epsilon_closure(A, U)
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
    A:get_vertex(U[i]):dfs(visitor)
  end
  return set_to_seq(visitor.set)
end

local function create_transition(A, U)
  local matrix = {}
  for i = 0, 257 do
    matrix[i] = {}
  end
  for i = 1, #U do
    for v, e in A:get_vertex(U[i]):each_adjacent_vertex() do
      local vid = v.id
      local condition = decode_condition(e.condition)
      for i = 0, 257 do
        if condition:test(i) then
          matrix[i][vid] = true
        end
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
    transition[#transition + 1] = { encode_condition(v), copy_seq(k) }
  end
  return transition
end

local function creator()
  local self = {
    _map = tree_map();
    _color = {};
  }

  function self:vertex(A, B, U)
    local map = self._map
    local v = map:find(U)
    if not v then
      v = B:create_vertex()
      for i = 1, #U do
        if A:get_vertex(U[i]).accept then
          v.accept = true
          break
        end
      end
      map:insert(U, v)
    end
    return v
  end

  function self:visit(A, B, U)
    local E = create_epsilon_closure(A, U)
    local u = self:vertex(A, B, E)
    local color = self._color
    local uid = u.id
    if not color[uid] then
      color[uid] = true
      local transition = create_transition(A, E)
      for i = 1, #transition do
        local t = transition[i]
        B:create_edge(u, self:visit(A, B, t[2])).condition = t[1]
      end
    end
    return u
  end

  function self:create(A, B)
    local S = {}
    for u in A:each_vertex "start" do
      S[#S + 1] = u.id
    end
    local s = self:visit(A, B, S)
    s.start = true
    return B
  end

  return self
end

return function (A, B)
  return creator():create(A, B or graph())
end
