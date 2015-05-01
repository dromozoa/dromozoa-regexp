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

local clone = require "dromozoa.graph.clone"
local dfs_visitor = require "dromozoa.graph.dfs_visitor"
local graph = require "dromozoa.graph"

local bitset = require "dromozoa.regexp.bitset"
local bitset_to_node = require "dromozoa.regexp.bitset_to_node"
local node_to_bitset = require "dromozoa.regexp.node_to_bitset"
local tree_map = require "dromozoa.regexp.tree_map"

local function data_to_keys(data)
  local keys = {}
  for k in pairs(data) do
    keys[#keys + 1] = k
  end
  table.sort(keys)
  return keys
end

local function epsilon_closure_visitor(_result)
  local self = {}

  function self:discover_vertex(g, u)
    _result[u.id] = true
  end;

  function self:examine_edge(g, e, u, v)
    return e.condition[1] == "epsilon"
  end;

  return dfs_visitor(self)
end

local function constructor(_a, _b)
  local _map = tree_map()
  local _color = {}

  local self = {}

  function self:get_property(keys, key)
    local min
    for i = 1, #keys do
      local v = _a:get_vertex(keys[i])[key]
      if v ~= nil then
        if min == nil or min > v then
          min = v
        end
      end
    end
    return min
  end

  function self:get_vertex(keys)
    local b = _map:find(keys)
    if not b then
      b = _b:create_vertex()
      b.accept = self:get_property(keys, "accept")
      _map:insert(keys, b)
    end
    return b
  end

  function self:create_epsilon_closure(keys)
    local result = {}
    local visitor = epsilon_closure_visitor(result)
    for i = 1, #keys do
      _a:get_vertex(keys[i]):dfs(visitor)
    end
    return data_to_keys(result)
  end

  function self:create_transition(keys)
    local dataset = {}
    for i = 0, 257 do
      dataset[i] = {}
    end
    for i = 1, #keys do
      for v, e in _a:get_vertex(keys[i]):each_adjacent_vertex() do
        for k in node_to_bitset(e.condition):each() do
          dataset[k][v.id] = true
        end
      end
    end
    local map = tree_map()
    for i = 0, 257 do
      local data = dataset[i]
      if next(data) then
        map:insert(data_to_keys(data), bitset()):set(i)
      end
    end
    local transition = {}
    for k, v in map:each() do
      transition[#transition + 1] = { bitset_to_node(v), clone(k) }
    end
    return transition
  end

  function self:visit(keys)
    local epsilon_closure = self:create_epsilon_closure(keys)
    local b = self:get_vertex(epsilon_closure)
    if not _color[b.id] then
      _color[b.id] = true
      local transition = self:create_transition(epsilon_closure)
      for i = 1, #transition do
        local t = transition[i]
        _b:create_edge(b, self:visit(t[2])).condition = t[1]
      end
    end
    return b
  end

  function self:construct()
    local keys = {}
    for a in _a:each_vertex("start") do
      keys[#keys + 1] = a.id
    end
    table.sort(keys)
    local b = self:visit(keys)
    b.start = self:get_property(keys, "start")
    return _b
  end

  return self
end

return function (a)
  return constructor(a, graph()):construct()
end
