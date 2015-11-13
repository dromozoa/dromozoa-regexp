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
local clone = require "dromozoa.commons.clone"
local push = require "dromozoa.commons.push"

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

function class:create_node(...)
  local node = self.that:create_node()
  push(node, 0, ...)
  return node
end

function class:eliminate(this, u)
  local a, b, c, d
  for v, e in u:each_adjacent_vertex() do
    if u.id == v.id then
      c = e
    elseif d == nil then
      d = e
    else
      return
    end
  end
  for v, e in u:each_adjacent_vertex("v") do
    if u.id ~= v.id then
      if b == nil then
        b = e
      else
        return
      end
    end
  end
  if b == nil or d == nil then
    return
  end
  for v, e in b.u:each_adjacent_vertex() do
    if v.id == d.vid then
      a = e
    end
  end
  local node = self:create_node("concat")
  if b.node ~= nil then
    node:append_child(b.node)
  end
  if c ~= nil and c.node ~= nil then
    local node = node:append_child(self:create_node("*"))
    node:append_child(c.node)
    c:remove()
  end
  if d.node ~= nil then
    node:append_child(d.node)
  end
  if a == nil then
    this:create_edge(b.u, d.v).node = node
  else
    if a.node == nil then
      local maybe = self:create_node("?")
      maybe:append_child(node)
      a.node = maybe
    else
      local branch = self:create_node("|")
      branch:append_child(a.node)
      branch:append_child(node)
      a.node = branch
    end
  end
  local v = b.v
  b:remove()
  d:remove()
  v:remove()
  return true
end

function class:apply()
  local this = self.this
  local u = this:create_vertex()
  local v = this:start()
  u.start = v.start
  v.start = nil
  this:create_edge(u, v)

  local u = this:collect_accepts()
  local v = this:create_vertex()
  v.accept = u.accept
  u.accept = nil
  this:create_edge(u, v)

  for e in this:each_edge("condition") do
    local condition = e.condition
    if condition:test(256) then
      e.node = self:create_node("^")
    elseif condition:test(257) then
      e.node = self:create_node("$")
    else
      local count = condition:count()
      if count == 1 then
        e.node = self:create_node("char", string.char((apply(condition:each()))))
      elseif count == 256 then
        e.node = self:create_node(".")
      else
        local node = self:create_node("[", false)
        if count > 127 then
          condition = clone(condition):flip(0, 255)
          node[2] = true
        end
        for range in condition:ranges():each() do
          local a, b = range[1], range[2]
          if a == b then
            node:append_child(self:create_node("[char", string.char(a)))
          elseif a == b - 1 then
            node:append_child(self:create_node("[char", string.char(a)))
            node:append_child(self:create_node("[char", string.char(b)))
          else
            local node = node:append_child(self:create_node("[-"))
            node:append_child(self:create_node("[char", string.char(a)))
            node:append_child(self:create_node("[char", string.char(b)))
          end
        end
        e.node = node
      end
    end
  end
  local done
  repeat
    done = true
    for u in this:each_vertex() do
      if self:eliminate(this, u) then
        done = false
      end
    end
  until done
  local edge
  for e in this:each_edge() do
    -- assert(edge == nil)
    edge = e
  end
  -- assert(edge.u.start ~= nil)
  -- assert(edge.v.start ~= nil)

  edge.node.start = 1

  return self.that, this
end

return setmetatable(class, {
  __call = function (_, this, that)
    return setmetatable(class.new(this, that), metatable)
  end;
})
