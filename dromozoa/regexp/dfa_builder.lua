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

local json = require "dromozoa.json"

local function push(table, value)
  local n = #table + 1
  table[n] = value
  return n
end

local function push2(table, key, value)
  local x = table[key]
  if x then
    x[#x + 1] = value
  else
    table[key] = { value }
  end
end

return function ()
  local self = {}

  function self:build(fa)
    self:build_transition_and_epsilon(fa.transition)
    self:build_accept(fa.accept)
    self._merged_state = {}
    self._merged_transition = {}
    self._merged_accept = {}
    self:build_state({}, fa.start)
    return {
      transition = self._merged_transition;
      start = 1;
      accept = self._merged_accept;
    }
  end

  function self:build_transition_and_epsilon(list)
    local transition = {}
    local epsilon = {}
    for i = 1, #list do
      local x = list[i]
      local a, b, c = x[1], x[2], x[3]
      if c then
        push2(transition, a, { b, c })
      else
        push2(epsilon, a, b)
      end
    end
    self._transition = transition
    self._epsilon = epsilon
  end

  function self:build_accept(list)
    local accept = {}
    for i = 1, #list do
      accept[list[i]] = true
    end
    self._accept = accept
  end

  function self:merge_state(color, s)
    if not color[s] then
      color[s] = true
      local t = self._epsilon[s]
      if t then
        for i = 1, #t do
          self:merge_state(color, t[i])
        end
      end
    end
  end

  function self:build_state(color, s)
    if not color[s] then
      local merged_state = self._merged_state
      local merged_transition = self._merged_transition
      local merged_accept = self._merged_accept
      local merged_color = {}
      self:merge_state(merged_color, s)
      local u = push(merged_state, merged_color)
      color[s] = u

      for k, v in pairs(merged_color) do
        if self._accept[k] then
          push(merged_accept, u)
          break
        end
      end

      local transition = self._transition
      for k, v in pairs(merged_color) do
        local x = self._transition[k]
        if x then
          for i = 1, #x do
            local y = x[i]
            local v = self:build_state(color, y[1])
            push(merged_transition, { u, v, y[2] })
          end
        end
      end
      return u
    end
    return color[s]
  end

  return self
end
