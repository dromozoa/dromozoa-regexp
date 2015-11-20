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

local apply = require "dromozoa.commons.apply"
local bitset = require "dromozoa.commons.bitset"
local clone = require "dromozoa.commons.clone"
local graph = require "dromozoa.graph"
local locale = require "dromozoa.regexp.locale"
local compile = require "dromozoa.regexp.automaton.compile"
local decompile = require "dromozoa.regexp.automaton.decompile"
local graphviz_visitor = require "dromozoa.regexp.automaton.graphviz_visitor"
local normalize_assertions = require "dromozoa.regexp.automaton.normalize_assertions"
local powerset_construction = require "dromozoa.regexp.automaton.powerset_construction"
local product_construction = require "dromozoa.regexp.automaton.product_construction"
local tokens = require "dromozoa.regexp.automaton.tokens"
local to_ast = require "dromozoa.regexp.automaton.to_ast"

local function collect(self, key)
  local count = self:count_vertex(key)
  if count == 0 then
    return nil
  elseif count == 1 then
    return apply(self:each_vertex(key))
  else
    local u = self:create_vertex()
    local token
    for v in self:each_vertex(key) do
      token = tokens.union(token, v[key])
      v[key] = nil
      if key == "start" then
        self:create_edge(u, v)
      else
        self:create_edge(v, u)
      end
    end
    u[key] = token
    return u
  end
end

local class = clone(graph)

local metatable = {
  __index = class;
}

function class.decompile(data)
  return decompile(data, class())
end

function class:start()
  if self:count_vertex("start") > 1 then
    error("only one start state allowed")
  end
  return apply(self:each_vertex("start"))
end

function class:can_minimize()
  local token
  for u in self:each_vertex("accept") do
    if token == nil then
      token = u.accept
    elseif token ~= u.accept then
      return false
    end
  end
  return true
end

function class:collect_starts()
  return collect(self, "start")
end

function class:collect_accepts()
  return collect(self, "accept")
end

function class:reverse()
  local that = class()
  local map = {}
  for a in self:each_vertex() do
    local b = that:create_vertex()
    map[a.id] = b.id
    b.start = a.accept
    b.accept = a.start
  end
  for a in self:each_edge() do
    that:create_edge(map[a.vid], map[a.uid]).condition = a.condition
  end
  that:collect_starts()
  return that
end

function class:remove_unreachables()
  local visitor = {
    finish_edge = function (_, e)
      if e.color == nil then
        e.color = 1
      else
        e.color = 2
      end
    end;
  }
  self:start():dfs(visitor)
  for v in self:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  for e in self:each_edge() do
    if e.color ~= 2 then
      e:remove()
    end
  end
  for u in self:each_vertex() do
    if u:is_isolated() then
      u:remove()
    end
  end
  self:clear_edge_properties("color")
  return self
end

function class:ignore_case()
  local that = clone(self)
  for e in that:each_edge("condition") do
    local condition = bitset()
    for k in e.condition:each() do
      condition:set(locale.toupper(k)):set(locale.tolower(k))
    end
    e.condition = condition
  end
  return that:optimize()
end

function class:normalize_assertions()
  return normalize_assertions(self):apply()
end

function class:to_dfa()
  return powerset_construction(self, class()):apply()
end

function class:minimize()
  return self:reverse():to_dfa():reverse():to_dfa()
end

function class:optimize()
  if self:can_minimize() then
    return self:minimize()
  else
    return self:remove_unreachables():to_dfa()
  end
end

function class:branch(that)
  self:merge(that)
  self:collect_starts()
  return self:optimize()
end

function class:concat(that)
  local u = self:collect_accepts()
  u.accept = nil
  local map = self:merge(that)
  local v = self:get_vertex(map[that:start().id])
  v.start = nil
  self:create_edge(u, v)
  return self:optimize()
end

function class:set_intersection(that)
  return product_construction(class()):apply(self, that, tokens.intersection):optimize()
end

function class:set_union(that)
  return product_construction(class()):apply(self, that, tokens.union):optimize()
end

function class:set_difference(that)
  return product_construction(class()):apply(self, that, tokens.difference):optimize()
end

function class:compile()
  return compile(self)
end

function class:to_ast()
  return to_ast(clone(self), class.super.syntax_tree()):apply()
end

function class:to_ere()
  return self:to_ast():denormalize():to_ere(true)
end

function class:write_graphviz(out)
  return graph.write_graphviz(self, out, graphviz_visitor())
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
