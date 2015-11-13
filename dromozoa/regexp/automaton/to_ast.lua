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
  local flag
  local node3
  print(">>", u.id)
  for v, e in u:each_adjacent_vertex() do
    if u.id == v.id then
      flag = true
      node3 = e.node
      e:remove()
      break
    end
  end
  if u:count_degree() > 0 and u:count_degree("v") > 0 then
    for v4, e4 in u:each_adjacent_vertex() do
      for v2, e2 in u:each_adjacent_vertex("v") do
        local e1
        for v, e in v2:each_adjacent_vertex() do
          if v.id == v4.id then
            e1 = e
            break
          end
        end

        print(">>>>", v2.id, v4.id)
        local node = self:create_node("concat")
        if e2.node ~= nil then
          -- print("2", e2.node)
          node:append_child(e2.node)
        end
        if node3 ~= nil then
          -- print("3", node3)
          node:append_child(self:create_node("*")):append_child(node3)
        end
        if e4.node ~= nil then
          -- print("4", e4.node)
          node:append_child(e4.node)
        end
        if node:count_children() == 0 then
          node[1] = "epsilon"
        end

        if e1 == nil then
          local branch = self:create_node("|")
          branch:append_child(node)
          this:create_edge(v2, v4).node = branch
        else
          if e1.node == nil then
            local maybe = self:create_node("?")
            local branch = self:create_node("|")
            branch:append_child(node)
            maybe:append_child(branch)
            e1.node = maybe
          else
            local branch = self:create_node("|")
            branch:append_child(e1.node)
            branch:append_child(node)
            e1.node = branch
          end
        end
      end
    end

    for _, e2 in u:each_adjacent_vertex() do
      e2:remove()
    end
    for _, e4 in u:each_adjacent_vertex("v") do
      e4:remove()
    end

    u:remove()
    return true
  else
    if flag then
      this:create_edge(u, u).node = node3
    end
    return false
  end

--[====[
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
  print(b.uid, b.vid, d.uid, d.vid)
  for v, e in b.u:each_adjacent_vertex() do
    if v.id == d.vid then
      assert(a == nil)
      a = e
    end
  end
  if a ~= nil then
    print("a", a.uid, a.vid)
  end
  if c ~= nil then
    print("c", c.uid, c.vid)
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
    print("create", b.uid, d.vid)
    local e = this:create_edge(b.u, d.v)
    e.node = node
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
  b:remove()
  d:remove()
  print("remove", u.id)
  u:remove()
  return true
]====]
end

function class:apply()
  local this = self.this
  local that = self.that
  local u = this:create_vertex()
  local v = this:start()
  u.start = v.start
  v.start = nil
  this:create_edge(u, v)
  print("start", u.id)

  local u = this:collect_accepts()
  local v = this:create_vertex()
  v.accept = u.accept
  u.accept = nil
  this:create_edge(u, v)
  print("accept", v.id)

  this:write_graphviz(assert(io.open("test.dot", "w"))):close()

  for e in this:each_edge("condition") do
    e.node = that:condition_to_node(e.condition)
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
