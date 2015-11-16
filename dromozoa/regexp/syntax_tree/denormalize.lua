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
  local utag = u[1]
  local vtag = v[1]
  if utag == "|" then
    if vtag == "|" then
      v:collapse():delete()
    elseif vtag == "epsilon" then
      u.maybe = true
      v:remove():delete()
    end
  elseif utag == "concat" then
    if vtag == "|" then
      if v:count_children() == 1 then
        local w = apply(v:each_child())
        if w[1] == "concat" then
          w:collapse():delete()
          v:collapse():delete()
        end
      end
    elseif vtag == "epsilon" then
      v:remove():delete()
    end
  end
end

function class:finish_node(u)
  local this = self.this
  local utag = u[1]
  if utag == "|" then
    if u.maybe then
      u.maybe = nil
      local count = u:count_children()
      if count == 0 then
        u[1] = "epsilon"
      else
        u[1] = "?"
        if count > 1 or apply(u:each_child())[1] == "concat" then
          local v = this:create_node("|")
          for w in u:each_child() do
            v:append_child(w:remove())
          end
          u:append_child(v)
        end
      end
    end
  elseif utag == "concat" then
    if u:count_children() == 0 then
      u[1] = "epsilon"
    end
  end
end

function class:apply()
  local this = self.this

  local u = this:create_node("|")
  local v = this:start()
  u.start = v.start
  v.start = nil
  u:append_child(v)

  this:dfs(self)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
