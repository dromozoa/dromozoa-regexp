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
local operations = require "dromozoa.regexp.automaton.operations"
local tokens = require "dromozoa.regexp.automaton.tokens"

local function normalize(this)
  for e in this:each_edge("condition") do
    local condition = e.condition
    if condition:test(256) then
      e.assertion = "^"
    elseif condition:test(257) then
      e.assertion = "$"
    end
  end
  local visitor = {
    examine_edge = function (self, e)
      if e.condition == nil or e.assertion ~= nil then
        e.color = true
      else
        return false
      end
    end;
  }
  operations.get_start(this):dfs(visitor)
  for u in this:each_vertex("accept") do
    u:dfs(visitor, "v")
  end
  for e in this:each_edge("condition") do
    if e.assertion ~= nil and e.color == nil then
      e:remove()
    end
  end
  this:clear_edge_properties("assertion")
  this:clear_edge_properties("color")
end

local class = {}

local function color_assertions(this, key, start)
  local visitor = {
    examine_edge = function (self, e)
      local condition = e.condition
      if condition == nil or condition:test(256) or condition:test(257) then
        e.color = true
      else
        return false
      end
    end;
  }
  for u in this:each_vertex(key) do
    u:dfs(visitor, start)
  end
end

function class.remove_nonmatching_assertions(this)
  for e in this:each_edge("condition") do
    local condition = e.condition
    if condition:test(256) then
      e.assertion = "^"
    elseif condition:test(257) then
      e.assertion = "$"
    end
  end
  color_assertions(this, "start", "u")
  color_assertions(this, "accept", "v")
  for e in this:each_edge("assertion") do
    if not e.color then
      e:remove()
    end
  end

  local that = clone(this)

  for e in this:each_edge("assertion") do
    if e.assertion == "^" then
      e:remove()
    elseif e.v.accept == nil then
      e:collapse()
    end
  end
  for e in that:each_edge("assertion") do
    if e.assertion == "^" then
      e.u.accept = e.v.accept
      e:collapse()
    elseif e.v.accept == nil then
      e:collapse()
    end
  end

  local token
  local u = this:create_vertex()
  for v in this:each_vertex("start") do
    token = tokens.union(token, v.start)
    v.start = nil
    this:create_edge(u, v)
  end
  u.start = token

  local map = this:merge(that)
  for v in that:each_vertex("start") do
    local vid = map[v.id]
    this:get_vertex(vid).start = nil
    this:create_edge(u, vid).condition = bitset():set(256)
  end

  return this
end

return class
