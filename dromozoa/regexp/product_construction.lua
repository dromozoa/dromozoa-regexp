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

local bitset = require "dromozoa.commons.bitset"
local graph = require "dromozoa.graph"
local node_to_bitset = require "dromozoa.regexp.node_to_bitset"
local bitset_to_node = require "dromozoa.regexp.bitset_to_node"
local tree_map = require "dromozoa.regexp.tree_map"

local dummy_vertex = {
  id = 0;
  each_adjacent_vertex = function()
    return function () end
  end
}

local function start(a, b)
  if a and b then
    if a < b then return a else return b end
  end
end

local function accept_intersection(a, b)
  if a and b then
    if a < b then return a else return b end
  end
end

local function accept_union(a, b)
  if a then
    if b then
      if a < b then return a else return b end
    end
    return a
  end
  return b
end

local function accept_difference(a, b)
  if a and not b then
    return a
  end
end

local function construction(_a, _b)
  local _that = graph()
  local _map = tree_map()

  local self = {}

  function self:each_product()
    return coroutine.wrap(function ()
      coroutine.yield(dummy_vertex, dummy_vertex)
      for b in _b:each_vertex() do
        coroutine.yield(dummy_vertex, b)
      end
      for a in _a:each_vertex() do
        coroutine.yield(a, dummy_vertex)
        for b in _b:each_vertex() do
          coroutine.yield(a, b)
        end
      end
    end)
  end

  function self:create_vertex(a, b, accept)
    local u = _that:create_vertex()
    u.start = start(a.start, b.start)
    u.accept = accept(a.accept, b.accept)
    _map:insert({ a.id, b.id }, u)
  end

  function self:create_transition(u)
    local transition = {}
    for i = 0, 256 do
      transition[i] = dummy_vertex
    end
    for v, e in u:each_adjacent_vertex() do
      for k in node_to_bitset(e.condition):each() do
        transition[k] = v
      end
    end
    return transition
  end

  function self:create_edge(a, b)
    local transition_a = self:create_transition(a)
    local transition_b = self:create_transition(b)
    local transition = {}
    for i = 0, 256 do
      local v = _map:find({ transition_a[i].id, transition_b[i].id })
      local condition = transition[v.id]
      if not condition then
        condition = bitset()
        transition[v.id] = condition
      end
      condition:set(i)
    end
    local u = _map:find({ a.id, b.id })
    for k, v in pairs(transition) do
      _that:create_edge(u, k).condition = bitset_to_node(v)
    end
  end

  function self:construct(accept)
    for a, b in self:each_product() do
      self:create_vertex(a, b, accept)
    end
    for a, b in self:each_product() do
      self:create_edge(a, b)
    end
    return _that
  end

  return self
end

return {
  intersection = function (a, b)
    return construction(a, b):construct(accept_intersection)
  end;

  union = function (a, b)
    return construction(a, b):construct(accept_union)
  end;

  difference = function (a, b)
    return construction(a, b):construct(accept_difference)
  end;
}
