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

local apply = require "dromozoa.commons.apply"

local class = {}

function class.new(this)
  return {
    this = this;
  }
end

function class:finish_edge(u, v)
  local tag = u[1]
  if tag == "|" then
    if v[1] == "|" then
      v:collapse():delete()
    end
  elseif tag == "concat" then
    if v[1] == "|" and v:count_children() == 1 then
      local w = apply(v:each_child())
      if w[1] == "concat" then
        w:collapse():delete()
        v:collapse():delete()
      end
    end
  end
end

function class:apply()
  self.this:dfs(self)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
