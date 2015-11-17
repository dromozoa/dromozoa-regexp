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

local class = {}

function class.new(this)
  return {
    this = this;
  }
end

function class:apply()
  local this = self.this
  local state = 0

  for u in this:each_vertex("accept") do
    state = state + 1
    u.state = state
  end

  local u = this:start()
  if u.state == nil then
    state = state + 1
    u.state = state
  end

  for u in this:each_vertex() do
    if u.state == nil then
      state = state + 1
      u.state = state
    end
  end

  local start = u.state
  local start_assertion = 0
  local end_assertions = {}
  local transitions = {}
  local accepts = {}

  for i = 1, state do
    accepts[i] = 0
    end_assertions[i] = 0
  end

  for i = 1, state * 256 do
    transitions[i] = 0
  end

  for u in this:each_vertex("accept") do
    accepts[u.state] = u.accept
  end

  for u in this:each_vertex() do
    local cs = u.state
    local n = cs * 256 - 255
    local count = 0
    for v, e in u:each_adjacent_vertex() do
      local ns = v.state
      local condition = e.condition
      if condition:test(256) then
        assert(start == cs)
        assert(start_assertion == 0)
        start_assertion = ns
      elseif condition:test(257) then
        count = count + 1
        end_assertions[cs] = ns
      else
        for k, v in condition:each() do
          count = count + 1
          transitions[n + k] = ns
        end
      end
    end
    if start == cs and count == 0 then
      assert(start == cs)
      assert(start_assertion ~= 0)
      start = 0
    end
  end

  this:clear_vertex_properties("state")

  return {
    start = start;
    start_assertion = start_assertion;
    end_assertions = end_assertions;
    transitions = transitions;
    accepts = accepts;
  }
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
