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
local sequence = require "dromozoa.commons.sequence"
local graph = require "dromozoa.graph"
local tokens = require "dromozoa.regexp.automaton.tokens"

local class = {}

function class.get_start(this)
  local count = this:count_vertex("start")
  if count ~= 1 then
    error("only one start state allowed")
  end
  return this:each_vertex("start")()
end

function class.collect_starts(this)
  local count = this:count_vertex("start")
  if count == 0 then
    return nil
  elseif count == 1 then
    return this:each_vertex("start")()
  else
    local u = this:create_vertex()
    local token
    for v in this:each_vertex("start") do
      token = tokens.union(token, v.start)
      v.start = nil
      this:create_edge(u, v)
    end
    u.start = token
    return u
  end
end

function class.collect_accepts(this)
  local count = this:count_vertex("accept")
  if count == 0 then
    return nil
  elseif count == 1 then
    return this:each_vertex("accept")()
  else
    local v = this:create_vertex()
    local token
    for u in this:each_vertex("accept") do
      token = tokens.union(token, u.accept)
      u.accept = nil
      this:create_edge(u, v)
    end
    v.accept = token
    return v
  end
end

function class.reverse(this)
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
  class.collect_starts(that)
  return that
end

function class.branch(this, that)
  this:merge(that)
  class.collect_starts(this)
  return this
end

function class.concat(this, that)
  local u = class.collect_accepts(this)
  u.accept = nil
  local map = this:merge(that)
  local v = this:get_vertex(map[class.get_start(that).id])
  v.start = nil
  this:create_edge(u, v)
  return this
end

return class
