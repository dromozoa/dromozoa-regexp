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
local hash_table = require "dromozoa.commons.hash_table"
local graph = require "dromozoa.graph"
local tokens = require "dromozoa.regexp.automaton.tokens"

local dummy = {
  id = 0;
  each_adjacent_vertex = function ()
    return function () end
  end;
}

local function each_product(a, b)
  return coroutine.wrap(function ()
    coroutine.yield(dummy, dummy)
    for b in b:each_vertex() do
      coroutine.yield(dummy, b)
    end
    for a in a:each_vertex() do
      coroutine.yield(a, dummy)
      for b in b:each_vertex() do
        coroutine.yield(a, b)
      end
    end
  end)
end

local function create_transitions(u)
  local transitions = {}
  for i = 0, 255 do
    transitions[i] = 0
  end
  for v, e in u:each_adjacent_vertex() do
    for k in e.condition:each() do
      transitions[k] = v.id
    end
  end
  return transitions
end

local class = {}

function class.new()
  return {
    that = graph();
    map = hash_table();
  }
end

function class:create_vertex(a, b, fn)
  local u = self.that:create_vertex()
  u.start = tokens.intersection(a.start, b.start)
  u.accept = fn(a.accept, b.accept)
  self.map:insert({ a.id, b.id }, u.id)
end

function class:create_edge(a, b)
  local that = self.that
  local map = self.map
  local transitions_a = create_transitions(a)
  local transitions_b = create_transitions(b)
  local transitions = {}
  for i = 0, 255 do
    local vid = map:get({ transitions_a[i], transitions_b[i] })
    local condition = transitions[vid]
    if condition == nil then
      condition = bitset()
      transitions[vid] = condition
    end
    condition:set(i)
  end
  local u = that:get_vertex(map:get({ a.id, b.id }))
  for k, v in pairs(transitions) do
    that:create_edge(u, that:get_vertex(k)).condition = v
  end
end

function class:apply(a, b, fn)
  for a, b in each_product(a, b) do
    self:create_vertex(a, b, fn)
  end
  for a, b in each_product(a, b) do
    self:create_edge(a, b)
  end
  return self.that
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
