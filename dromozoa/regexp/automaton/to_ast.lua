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
local sequence = require "dromozoa.commons.sequence"

local class = {}

local metatable = {
  __index = class;
}

function class.new(this, that)
  return {
    this = this;
    that = that;
  }
end

function class:eliminate(u)
  local this = self.this
  local that = self.that

  local count = 0
  local e3
  local n3
  for v, e in u:each_adjacent_vertex() do
    if u.id == v.id then
      count = 1
      e3 = e
      n3 = e.node
      break
    end
  end

  if u:count_degree("v") > count and u:count_degree() > count then
    if e3 ~= nil then
      e3:remove()
    end

    for v2, e2 in u:each_adjacent_vertex("v") do
      local n2 = e2.node
      for v4, e4 in u:each_adjacent_vertex() do
        local n4 = e4.node

        local nodes = sequence()
        if n2 ~= nil then
          nodes:push((n2:duplicate()))
        end
        if n3 ~= nil then
          local star = that:create_node("*")
          star:append_child(n3:duplicate())
          nodes:push(star)
        end
        if n4 ~= nil then
          nodes:push((n4:duplicate()))
        end

        local node
        local n = #nodes
        if n == 0 then
          node = that:create_node("epsilon")
        elseif n == 1 then
          node = nodes[1]
        else
          local branch = that:create_node("|")
          local concat = branch:append_child(that:create_node("concat"))
          for v in nodes:each() do
            concat:append_child(v)
          end
          node = branch
        end

        local e1
        local n1
        for v, e in v2:each_adjacent_vertex() do
          if v.id == v4.id then
            e1 = e
            n1 = e.node
            break
          end
        end

        if e1 == nil then
          this:create_edge(v2, v4).node = node
        else
          if n1 == nil then
            n1 = that:create_node("epsilon")
          end
          local branch = that:create_node("|")
          branch:append_child(n1)
          branch:append_child(node)
          e1.node = branch
        end
      end
    end

    for _, e2 in u:each_adjacent_vertex("v") do
      local n2 = e2.node
      if n2 ~= nil then
        n2:delete(true)
      end
      e2:remove()
    end
    if n3 ~= nil then
      n3:delete(true)
    end
    for _, e4 in u:each_adjacent_vertex() do
      local n4 = e4.node
      if n4 ~= nil then
        n4:delete(true)
      end
      e4:remove()
    end
    u:remove()
  end
end

function class:apply()
  local this = self.this
  local that = self.that

  local u = this:create_vertex()
  local v = this:start()
  u.start = v.start
  v.start = nil
  this:create_edge(u, v)

  local u = this:collect_accepts()
  local v = this:create_vertex()
  local token = u.accept
  v.accept = token
  u.accept = nil
  this:create_edge(u, v)

  for e in this:each_edge("condition") do
    e.node = that:condition_to_node(e.condition)
  end
  for u in this:each_vertex() do
    self:eliminate(u)
  end

  assert(this:count_edge() == 1)
  apply(this:each_edge()).node.start = token
  return that, this
end

return setmetatable(class, {
  __call = function (_, this, that)
    return setmetatable(class.new(this, that), metatable)
  end;
})
