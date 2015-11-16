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
local clone = require "dromozoa.commons.clone"

local function remove_unreachable_assertions(this)
  local visitor = {
    examine_edge = function (_, e)
      local condition = e.condition
      if condition == nil or condition:test(256) or condition:test(257) then
        e.color = true
      else
        return false
      end
    end;
  }
  for u in this:each_vertex("start") do
    u:dfs(visitor)
  end
  for v in this:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  for e in this:each_edge("condition") do
    local condition = e.condition
    if (condition:test(256) or condition:test(257)) and e.color == nil  then
      e:remove()
    end
  end
  this:clear_edge_properties("color")
end

local function remove_unreachables(this)
  local visitor = {
    examine_edge = function (_, e)
      if e.color == nil then
        e.color = 1
      else
        e.color = 2
      end
    end;
  }
  for u in this:each_vertex("start") do
    u:dfs(visitor)
  end
  for v in this:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  for e in this:each_edge() do
    if e.color ~= 2 then
      e:remove()
    end
  end
  for u in this:each_vertex() do
    if u:is_isolated() then
      u:remove()
    end
  end
  this:clear_edge_properties("color")
end

local function collapse_start_assertions(this)
  for e in this:each_edge("condition") do
    if e.condition:test(256) then
      e.u.accept = e.v.accept
      e:collapse()
    end
  end
end

local function remove_start_assertions(this)
  for e in this:each_edge("condition") do
    if e.condition:test(256) then
      e:remove()
    end
  end
end

local function collapse_end_assertions(this)
  local visitor = {
    examine_edge = function (_, e)
      local condition = e.condition
      if condition ~= nil then
        if condition:test(257) then
          e.color = true
        end
        return false
      end
    end;
  }
  for v in this:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  for e in this:each_edge("condition") do
    if e.condition:test(257) and e.color == nil then
      e:collapse()
    end
  end
  this:clear_edge_properties("color")
end

local class = {}

function class.new(this)
  return {
    this = this;
  }
end

function class:apply()
  local this = self.this
  remove_unreachable_assertions(this)
  this:remove_unreachables()

  local that = clone(this)
  collapse_start_assertions(that)
  collapse_end_assertions(that)

  remove_start_assertions(this)
  collapse_end_assertions(this)
  this:remove_unreachables()

  local u = this:start()
  local map = this:merge(that)
  local v = this:get_vertex(map[that:start().id])
  v.start = nil
  this:create_edge(u, v).condition = bitset():set(256)

  return this
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
