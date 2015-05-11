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
local dfs_visitor = require "dromozoa.graph.dfs_visitor"
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

local function construction(_this)
  local _that = graph()
  local _map = tree_map()
  local _color = {}

  local self = {}

  function self:get_property(keys, key)
    local token
    for i = 1, #keys do
      local v = _this:get_vertex(keys[i])[key]
      if v ~= nil then
        if token == nil or token > v then
          token = v
        end
      end
    end
    return token
  end

  function self:get_vertex(keys)
    local u = _map:find(keys)
    if not u then
      u = _that:create_vertex()
      u.accept = self:get_property(keys, "accept")
      _map:insert(keys, u)
    end
    return u
  end

  function self:create_epsilon_closure(keys)
    local data = {}
    local visitor = epsilon_closure_visitor(data)
    for i = 1, #keys do
      _this:get_vertex(keys[i]):dfs(visitor)
    end
    return data_to_keys(data)
  end

  function self:create_transition(keys)
    local dataset = {}
    for i = 0, 257 do
      dataset[i] = {}
    end
    for i = 1, #keys do
      for v, e in _this:get_vertex(keys[i]):each_adjacent_vertex() do
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
    local transition_keys = {}
    local transition_cond = {}
    for k, v in map:each() do
      transition_keys[#transition_keys + 1] = clone(k)
      transition_cond[#transition_cond + 1] = bitset_to_node(v)
    end
    return transition_keys, transition_cond
  end

  function self:visit(keys)
    local epsilon_closure = self:create_epsilon_closure(keys)
    local u = self:get_vertex(epsilon_closure)
    if not _color[u.id] then
      _color[u.id] = true
      local transition_keys, transition_cond = self:create_transition(epsilon_closure)
      for i = 1, #transition_keys do
        _that:create_edge(u, self:visit(transition_keys[i])).condition = transition_cond[i]
      end
    end
    return u
  end

  function self:construct()
    local keys = {}
    for u in _this:each_vertex("start") do
      keys[#keys + 1] = u.id
    end
    if #keys > 0 then
      table.sort(keys)
      local s = self:visit(keys)
      s.start = self:get_property(keys, "start")
    end
    return _that
  end

  return self
end

return function (g)
  return construction(g):construct()
end
