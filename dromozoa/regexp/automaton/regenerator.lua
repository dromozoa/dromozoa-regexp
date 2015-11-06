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
local push = require "dromozoa.commons.push"
local tree = require "dromozoa.tree"

local class = {}

local metatable = {
  __index = class;
}

function class.new()
  return {
    that = tree();
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
  node:append_child(b.node)
  if c ~= nil then
    local node = node:append_child(self:create_node("*"))
    node:append_child(c.node)
    c:remove()
  end
  node:append_child(d.node)
  if a == nil then
    this:create_edge(b.u, d.v).node = node
  else
    local branch = self:create_node("|")
    branch:append_child(a.node)
    branch:append_child(node)
    a.node = branch
  end
  local v = b.v
  b:remove()
  d:remove()
  v:remove()
  return true
end

function class:apply(this)
  for e in this:each_edge("condition") do
    local condition = e.condition
    if condition:test(256) then
      e.node = self:create_node("^")
    elseif condition:test(257) then
      e.node = self:create_node("$")
    else
      local count = condition:count()
      if count == 1 then
        for byte in condition:each() do
          e.node = self:create_node("char", string.char(byte))
          break
        end
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
  return edge.node, this
end

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
