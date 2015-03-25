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

local graph = require "dromozoa.graph"
local bitset = require "dromozoa.regexp.bitset"
local decode_condition = require "dromozoa.regexp.decode_condition"
local encode_condition = require "dromozoa.regexp.encode_condition"
local tree_map = require "dromozoa.regexp.tree_map"

local zero_vertex = {
  id = 0;
}

local function vertex(g, map, a, b)
  local key = { a.id, b.id }
  local v = map:find(key)
  if not v then
    v = g:create_vertex()
    v.a = a
    v.b = b
    map:insert(key, v)
  end
  return v
end

local function create_transition(u)
  local transition = {}
  for i = 0, 255 do
    transition[i] = zero_vertex
  end
  for v, e in u:each_adjacent_vertex() do
    local condition = decode_condition(e.condition)
    for i = 0, 255 do
      if condition:test(i) then
        transition[i] = v
      end
    end
  end
  return transition
end

local accept_rules = {
  intersection = function (u)
    return u.a.accept and u.b.accept
  end;
  union = function (u)
    return u.a.accept or u.b.accept
  end;
  difference = function (u)
    return u.a.accept or not u.b.accept
  end;
}

return function (A, B, op)
  local C = graph()
  local map = tree_map()
  for a in A:each_vertex() do
    for b in B:each_vertex() do
      local u = vertex(C, map, a, b)
      local ta = create_transition(a)
      local tb = create_transition(b)
      local tc = {}
      for i = 0, 255 do
        local vid = vertex(C, map, ta[i], tb[i]).id
        local set = tc[vid]
        if not set then
          set = bitset()
          tc[vid] = set
        end
        set:set(i)
      end
      for k, v in pairs(tc) do
        local e = C:create_edge(u, k)
        e.condition = encode_condition(v)
      end
    end
  end
  local accept_rule = accept_rules[op]
  for u in C:each_vertex() do
    if u.a.start and u.b.start then
      u.start = true
    end
    if accept_rule(u) then
      u.accept = true
    end
  end
  C:clear_vertex_properties "a"
  C:clear_vertex_properties "b"
  return C
end
