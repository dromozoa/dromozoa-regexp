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
local dfs_visitor = require "dromozoa.graph.dfs_visitor"
local decode_condition = require "dromozoa.regexp.decode_condition"
local encode_condition = require "dromozoa.regexp.encode_condition"
local bitset = require "dromozoa.regexp.bitset"
local tree_map = require "dromozoa.regexp.tree_map"

local function seq_to_set(seq)
  local set = {}
  for i = 1, #seq do
    set[seq[i]] = true
  end
  return set
end

local function set_to_seq(set)
  local seq = {}
  for k in pairs(set) do
    seq[#seq + 1] = k
  end
  table.sort(seq)
  return seq
end

local function copy_seq(this)
  local that = {}
  for i = 1, #this do
    that[i] = this[i]
  end
  return that
end

local function make_epsilon_closure(g, useq)
  local visitor = dfs_visitor {
    vset = {};

    discover_vertex = function (self, g, u)
      self.vset[u.id] = true
    end;

    examine_edge = function (self, g, e, u, v)
      return e.condition[1] == "epsilon"
    end;
  }

  for i = 1, #useq do
    g:get_vertex(useq[i]):dfs(visitor)
  end
  return set_to_seq(visitor.vset)
end

local function make_transition(g, useq)
  local mat = {}
  for i = 0, 257 do
    mat[i] = {}
  end
  for i = 1, #useq do
    for v, e in g:get_vertex(useq[i]):each_adjacent_vertex() do
      local vid = v.id
      local condition = decode_condition(e.condition)
      for i = 0, 257 do
        if condition:test(i) then
          mat[i][vid] = true
        end
      end
    end
  end
  local map = tree_map()
  for i = 0, 257 do
    local row = mat[i]
    if next(row) ~= nil then
      map:insert(set_to_seq(row), bitset()):set(i)
    end
  end
  local transition = {}
  for k, v in map:each() do
    transition[#transition + 1] = { encode_condition(v), copy_seq(k) }
  end
  return transition
end

local function creator(nfa, dfa)
  local self = {
    _nfa = nfa;
    _dfa = dfa;
    _state = tree_map();
    _color = {};
  }

  function self:state(useq)
    local state = self._state:find(useq)
    if not state then
      local v = self._dfa:create_vertex()
      for i = 1, #useq do
        if self._nfa:get_vertex(useq[i]).accept then
          v.accept = true
          break
        end
      end
      state = v.id
      self._state:insert(useq, state)
    end
    return state
  end

  function self:visit(useq)
    local epsilon_closure = make_epsilon_closure(self._nfa, useq)
    local ustate = self:state(epsilon_closure)
    local color = self._color
    if not color[ustate] then
      color[ustate] = true
      local transition = make_transition(self._nfa, epsilon_closure)
      for i = 1, #transition do
        local t = transition[i]
        local vstate = self:visit(t[2])
        local e = self._dfa:create_edge(ustate, vstate)
        e.condition = t[1]
      end
    end
    return ustate
  end

  return self
end

return function (nfa)
  local dfa = graph()
  local c = creator(nfa, dfa)
  local uset = {}
  for v in nfa:each_vertex("start") do
    uset[v.id] = true
  end
  local s = c:visit(set_to_seq(uset))
  dfa:get_vertex(s).start = true
  return dfa
end
