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

local function push1(t, v)
  t[#t + 1] = v
end

local function push(t, k, v)
  local a = t[k]
  if a then
    a[#a + 1] = v
  else
    t[k] = { v }
  end
end

local function merge_transition(s, color, epsilon)
  if not color[s] then
    color[s] = true
    local t = epsilon[s]
    if t then
      for i = 1, #t do
        merge_transition(t[i], color, epsilon)
      end
    end
  end
end

return function ()
  local self = {}

  function self:build(fa)
    self:build_transition_and_epsilon(fa.transition)
    self._state = {}
    self:build_state(self._state, fa.start)
    print(json.encode(self))
  end

  function self:build_transition_and_epsilon(list)
    local transition = {}
    local epsilon = {}
    for i = 1, #list do
      local v = list[i]
      local a, b, c = v[1], v[2], v[3]
      if c then
        push(transition, a, { b, c })
      else
        push(epsilon, a, b)
      end
    end
    self._transition = transition
    self._epsilon = epsilon
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
      local state = {}
      self:merge_state(state, s)
      color[s] = state
      for k, v in pairs(state) do
        local t = self._transition[k]
        if t then
          for i = 1, #t do
            self:build_state(color, t[i][1])
          end
        end
      end
    end
  end

  return self
end
