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
local empty = require "dromozoa.commons.empty"
local hash_table = require "dromozoa.commons.hash_table"
local keys = require "dromozoa.commons.keys"
local sequence = require "dromozoa.commons.sequence"
local graph = require "dromozoa.graph"
local tokens = require "dromozoa.regexp.automaton.tokens"

local class = {}

function class.new(this)
  return {
    this = this;
    that = graph();
    map = hash_table();
  }
end

function class:get_token(useq, key)
  local this = self.this
  local token
  for uid in useq:each() do
    token = tokens.union(token, this:get_vertex(uid)[key])
  end
  return token
end

function class:get_vertex(useq)
  local that = self.that
  local map = self.map
  local uid = map:get(useq)
  if uid == nil then
    local u = that:create_vertex()
    u.accept = self:get_token(useq, "accept")
    map:insert(useq, u.id)
    return u
  else
    return that:get_vertex(uid)
  end
end

function class:create_epsilon_closure(useq)
  local this = self.this
  local epsilon_closure = {}
  local visitor = {
    discover_vertex = function (self, u)
      epsilon_closure[u.id] = true
    end;
    examine_edge = function (self, e)
      return e.condition == nil
    end;
  }
  for uid in useq:each() do
    this:get_vertex(uid):dfs(visitor)
  end
  return keys(epsilon_closure):sort()
end

function class:create_transition(useq)
  local this = self.this
  local dataset = {}
  for i = 0, 257 do
    dataset[i] = {}
  end
  for uid in useq:each() do
    for v, e in this:get_vertex(uid):each_adjacent_vertex() do
      local condition = e.condition
      if condition ~= nil then
        for i in condition:each() do
          dataset[i][v.id] = true
        end
      end
    end
  end
  local map = hash_table()
  for i = 0, 257 do
    local vset = dataset[i]
    if not empty(vset) then
      local vseq = keys(vset):sort()
      local condition = map:get(vseq)
      if condition == nil then
        condition = bitset()
        map:insert(vseq, condition)
      end
      condition:set(i)
    end
  end
  return map
end

function class:visit(useq)
  local that = self.that
  local epsilon_closure = self:create_epsilon_closure(useq)
  local u = self:get_vertex(epsilon_closure)
  if not u.visited then
    u.visited = true
    local transitions = self:create_transition(epsilon_closure)
    for vseq, condition in transitions:each() do
      -- not clone condition
      that:create_edge(u, self:visit(vseq)).condition = condition
    end
  end
  return u
end

function class:apply()
  local this = self.this
  local that = self.that
  local useq = sequence()
  for u in this:each_vertex("start") do
    useq:push(u.id)
  end
  if not empty(useq) then
    useq:sort()
    self:visit(useq).start = self:get_token(useq, "start")
  end
  that:clear_vertex_properties("visited")
  return that
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
