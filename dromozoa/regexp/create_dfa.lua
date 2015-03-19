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

local dfs_visitor = require "dromozoa.graph.dfs_visitor"
local graph = require "dromozoa.graph"
local json = require "dromozoa.json"
local decode_condition = require "dromozoa.regexp.decode_condition"
local encode_condition = require "dromozoa.regexp.encode_condition"
local bitset = require "dromozoa.regexp.bitset"

local function epsilon_closure(g, uset)
  local visitor = dfs_visitor {
    vset = {};

    discover_vertex = function (self, g, u)
      self.vset[u.id] = true
    end;

    examine_edge = function (self, g, e, u, v)
      return e.condition[1] == "epsilon"
    end;
  }

  for k in pairs(uset) do
    g:get_vertex(k):dfs(visitor)
  end

  return visitor.vset
end

local function set_to_seq(set)
  local seq = {}
  for k in pairs(set) do
    seq[#seq + 1] = k
  end
  table.sort(seq)
  return seq
end

local function seq_eq(a, b)
  local m = #a
  local n = #b
  if m ~= n then
    return false
  end
  for i = 1, m do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end

local function seq_lt(a, b)
  local m = #a
  local n = #b
  if m ~= n then
    return m < n
  else
    for i = 1, m do
      local u = a[i]
      local v = b[i]
      if u ~= v then
        return u < v
      end
    end
  end
end

local function move1(g, uset)
  local vmat = {}
  for i = 0, 257 do
    vmat[i] = {}
  end
  for k in pairs(uset) do
    for v, e in g:get_vertex(k):each_adjacent_vertex() do
      local condition = decode_condition(e.condition)
      for i = 0, 257 do
        if condition:test(i) then
          vmat[i][v.id] = true
        end
      end
    end
  end
  return vmat
end

local function move2(umat)
  local vmat = {}
  for i = 0, 257 do
    local row = umat[i]
    if next(row) ~= nil then
      vmat[#vmat + 1] = { i, set_to_seq(row) }
    end
  end
  table.sort(vmat, function (a, b)
    return seq_lt(a[2], b[2])
  end)
  return vmat
end

local function move3(umat)
  local vmat = {}
  for i = 1, #umat do
    local u = umat[i]
    local v = vmat[#vmat]
    if v and seq_eq(u[2], v[2]) then
      v[1]:set(u[1])
    else
      vmat[#vmat + 1] = { bitset():set(u[1]), u[2] }
    end
  end
  for i = 1, #vmat do
    local v = vmat[i]
    v[1] = encode_condition(v[1])
  end
  return vmat
end

local function move(g, uset)
  return move3(move2(move1(g, uset)))
end

local function main(nfa, dfa, uset)
  local vset = epsilon_closure(nfa, uset)
  local wmat = move(nfa, vset)
end

return main
