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

local dummy_vertex = {
  id = 0;
  each_adjacent_vertex = function()
    return function () end
  end
}

local function create_vertex(g, map, a, b, accept)
  local v = g:create_vertex()
  if a.start and b.start then
    v.start = true
  end
  if accept(a.accept, b.accept) then
    v.accept = true
  end
  v.a = a
  v.b = b
  map:insert({ a.id, b.id }, v)
end

local function create_transition(u)
  local transition = {}
  for i = 0, 255 do
    transition[i] = dummy_vertex
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

local function visit(g, map, a, b)
  local u = map:find { a.id, b.id }
  local A = create_transition(a)
  local B = create_transition(b)
  local transition = {}
  for i = 0, 255 do
    local v = map:find { A[i].id, B[i].id }
    local vid = v.id
    local set = transition[vid]
    if not set then
      set = bitset()
      transition[vid] = set
    end
    set:set(i)
  end
  for k, v in pairs(transition) do
    g:create_edge(u, k).condition = encode_condition(v)
  end
end

local function construct(A, B, accept)
  local C = graph()
  local map = tree_map()
  create_vertex(C, map, dummy_vertex, dummy_vertex, accept)
  for a in A:each_vertex() do
    create_vertex(C, map, a, dummy_vertex, accept)
  end
  for b in B:each_vertex() do
    create_vertex(C, map, dummy_vertex, b, accept)
  end
  for a in A:each_vertex() do
    for b in B:each_vertex() do
      create_vertex(C, map, a, b, accept)
    end
  end
  for v in C:each_vertex() do
    visit(C, map, v.a, v.b)
  end
  C:clear_vertex_properties "a"
  C:clear_vertex_properties "b"
  return C
end

local function accept_intersection(a, b)
  return a and b
end

local function accept_union(a, b)
  return a or b
end

local function accept_difference(a, b)
  return a and not b
end

return {
  intersection = function (A, B)
    return construct(A, B, accept_intersection)
  end;

  union = function (A, B)
    return construct(A, B, accept_union)
  end;

  difference = function (A, B)
    return construct(A, B, accept_difference)
  end;
}
