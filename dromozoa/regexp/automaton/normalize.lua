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

local function color_reachable_assertions(this, key, start)
  local visitor = {
    examine_edge = function (self, e)
      local condition = e.condition
      if condition == nil or condition:test(256) or condition:test(257) then
        e.color = true
      else
        return false
      end
    end;
  }
  for u in this:each_vertex(key) do
    u:dfs(visitor, start)
  end
end

function class:apply()
  local this = self.this
  color_assertions(this, "start")
  color_assertions(this, "accept", "v")
  for e in this:each_edge("condition") do
    if (condition:test(256) or condition:test(257)) and e.color == nil  then
      e:remove()
    end
  end
  this:clear_edge_properties("color")
  return this
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this, that)
    return setmetatable(class.new(this, that), metatable)
  end;
})
