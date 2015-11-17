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
  local found = false
  local visitor = {
    examine_edge = function (_, e)
      local condition = e.condition
      if condition ~= nil then
        if condition:test(256) or condition:test(257) then
          e.color = true
        else
          return false
        end
      end
    end;
  }
  for u in this:each_vertex("start") do
    u:dfs(visitor)
  end
  for v in this:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  local count = 0
  for e in this:each_edge("condition") do
    local condition = e.condition
    if condition:test(256) or condition:test(257) then
      count = count + 1
      if e.color == nil then
        e:remove()
      end
    end
  end
  this:clear_edge_properties("color")
  return count > 0
end

local function collapse_start_assertions(this)
  for e in this:each_edge("condition") do
    local condition = e.condition
    if condition:test(256) then
      e.u.accept = e.v.accept
      e:collapse()
    end
  end
end

local function remove_start_assertions(this)
  for e in this:each_edge("condition") do
    local condition = e.condition
    if condition:test(256) then
      e:remove()
    end
  end
end

local function normalize_end_assertions(this)
  local visitor = {
    examine_edge = function (_, e)
      local condition = e.condition
      if condition ~= nil then
        if condition:test(257) then
          e.color = 1
        else
          return false
        end
      end
    end;
  }
  for v in this:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  local visitor = {
    examine_edge = function (_, e)
      local condition = e.condition
      if condition ~= nil then
        if condition:test(257) then
          e.color = 2
        end
        return false
      end
    end;
  }
  for v in this:each_vertex("accept") do
    v:dfs(visitor, "v")
  end
  for e in this:each_edge("condition") do
    if e.condition:test(257) then
      if e.color == nil then
        e:remove()
      elseif e.color == 1 then
        e:collapse()
      end
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

  if remove_unreachable_assertions(this) then
    this:remove_unreachables()

    local that = clone(this)
    collapse_start_assertions(that)
    normalize_end_assertions(that)
    that:remove_unreachables()

    remove_start_assertions(this)
    normalize_end_assertions(this)
    this:remove_unreachables()

    local u = this:start()
    if u == nil then
      if that:empty() then
        return this
      end
      u = this:create_vertex()
    end

    local map = this:merge(that)
    local v = this:get_vertex(map[that:start().id])
    u.start = v.start
    v.start = nil
    this:create_edge(u, v).condition = bitset():set(256)
  end

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
