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
local powerset_construction = require "dromozoa.regexp.automaton.powerset_construction"
local product_construction = require "dromozoa.regexp.automaton.product_construction"
local tokens = require "dromozoa.regexp.automaton.tokens"

local function collect(graph, key)
  local count = graph:count_vertex(key)
  if count == 0 then
    return nil
  elseif count == 1 then
    return graph:each_vertex(key)()
  else
    local u = graph:create_vertex()
    local token
    for v in graph:each_vertex(key) do
      token = tokens.union(token, v[key])
      v[key] = nil
      if key == "start" then
        graph:create_edge(u, v)
      else
        graph:create_edge(v, u)
      end
    end
    u[key] = token
    return u
  end
end

local class = {}

function class.new(graph)
  return {
    graph = graph;
  }
end

function class:start()
  local graph = self.graph
  if graph:count_vertex("start") ~= 1 then
    error("only one start state allowed")
  end
  return graph:each_vertex("start")()
end

function class:can_minimize()
  local graph = self.graph
  local token
  for u in graph:each_vertex("accept") do
    if token == nil then
      token = u.accept
    elseif token ~= u.accept then
      return false
    end
  end
  return true
end

function class:collect_starts()
  return collect(self.graph, "start")
end

function class:collect_accepts()
  return collect(self.graph, "accept")
end

function class:reverse()
  local this = self.graph
  local that = graph()
  local map = {}
  for a in this:each_vertex() do
    local b = that:create_vertex()
    map[a.id] = b.id
    b.start = a.accept
    b.accept = a.start
  end
  for a in this:each_edge() do
    local condition = a.condition
    if condition ~= nil then
      if condition:test(256) then
        condition = bitset():set(257)
      elseif condition:test(257) then
        condition = bitset():set(256)
      end
    end
    that:create_edge(map[a.vid], map[a.uid]).condition = condition
  end
  self.graph = that
  self:collect_starts()
end

function class:branch(that)
  self.graph:merge(that.graph)
  self:collect_starts()
end

function class:concat(that)
  local graph = self.graph
  local u = self:collect_accepts()
  u.accept = nil
  local map = graph:merge(that.graph)
  local v = graph:get_vertex(map[that:start().id])
  v.start = nil
  graph:create_edge(u, v)
end

function class:powerset_construction()
  self.graph = powerset_construction(self):apply()
end

function class:product_construction(that, fn)
  self.graph = product_construction():apply(self.graph, that.graph, fn)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, graph)
    return setmetatable(class.new(graph), metatable)
  end;
})
