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
local ipairs = require "dromozoa.commons.ipairs"
local pairs = require "dromozoa.commons.pairs"
local tokens = require "dromozoa.regexp.automaton.tokens"

return function (this, that)
  local start = this.start
  local start_assertion = this.start_assertion
  local end_assertions = this.end_assertions
  local transitions = this.transitions
  local accepts = this.accepts

  local state = #transitions / 256
  for cs = 1, state do
    that:create_vertex()
  end

  for cs = 1, state do
    local n = cs * 256 - 255
    local map = {}
    for j = n, n + 255 do
      local ns = transitions[j]
      if ns ~= 0 then
        local condition = map[ns]
        if condition == nil then
          condition = bitset()
          map[ns] = condition
        end
        condition:set(j - n)
      end
      for ns, condition in pairs(map) do
        that:create_edge(cs, ns).condition = condition
      end
    end
  end

  local token
  for cs = 1, #accepts do
    local accept = accepts[cs]
    if accept ~= 0 then
      that:get_vertex(cs).accept = accept
      token = tokens.union(token, accept)
    end
  end

  local u
  if start == 0 then
    u = that:create_vertex()
  else
    u = that:get_vertex(start)
  end
  u.start = token

  if start_assertion ~= 0 then
    that:create_edge(u, start_assertion).condition = bitset():set(256)
  end

  for cs = 1, #end_assertions do
    local ns = end_assertions[cs]
    if ns ~= 0 then
      that:create_edge(cs, ns).condition = bitset():set(257)
    end
  end

  return that
end
