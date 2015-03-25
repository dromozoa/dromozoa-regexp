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

return function (A, B, op)
  local C = graph()
  local map = tree_map()

  local a_fail = A:create_vertex()
  local b_fail = B:create_vertex()

  for a in A:each_vertex() do
    for b in B:each_vertex() do
      local v = C:create_vertex()
      v.a = a
      v.b = b
      map:insert({ a.id, b.id }, v)
    end
  end

  for u in C:each_vertex() do
    local A = {}
    for v, e in u.a:each_adjacent_vertex() do
      A[#A + 1] = { decode_condition(e.condition), v.id }
    end
    local B = {}
    for v, e in u.b:each_adjacent_vertex() do
      B[#B + 1] = { decode_condition(e.condition), v.id }
    end
    local transition = {}
    for i = 0, 257 do
      local av = a_fail.id
      local bv = b_fail.id
      for j = 1, #A do
        local a = A[j]
        if a[1]:test(i) then
          av = a[2]
          break
        end
      end
      for j = 1, #B do
        local b = B[j]
        if b[1]:test(i) then
          bv = b[2]
          break
        end
      end
      local v = map:find { av, bv }
      print(v, av, bv)
      local t = transition[v.id]
      if not t then
        t = bitset()
        transition[v.id] = t
      end
      t:set(i)
    end
    for k, v in pairs(transition) do
      local e = C:create_edge(u, C:get_vertex(k))
      e.condition = encode_condition(v)
    end
  end
  for u in C:each_vertex() do
    if u.a.start and u.b.start then
      u.start = true
    end
  end
  if op == "intersection" then
    for u in C:each_vertex() do
      if u.a.accept and u.b.accept then
        u.accept = true
      end
    end
  elseif op == "union" then
    for u in C:each_vertex() do
      if u.a.accept or u.b.accept then
        u.accept = true
      end
    end
  elseif op == "difference" then
    for u in C:each_vertex() do
      if u.a.accept and not u.b.accept then
        u.accept = true
      end
    end
  end
  C:clear_vertex_properties "a"
  C:clear_vertex_properties "b"
  return C
end
