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

function class:normalize_duplication(u, v, m, n)
  local this = self.this
  if n == 0 then
    u[1] = "epsilon"
  else
    u[1] = "concat"
  end
  u[2] = nil
  u[3] = nil
  for i = 1, m do
    v:insert_sibling(v:duplicate())
  end
  if n == nil then
    v:insert_sibling(this:create_node("*")):append_child(v:duplicate())
  else
    for i = m + 1, n do
      v:insert_sibling(this:create_node("?")):append_child(v:duplicate())
    end
  end
  v:delete(true)
end

function class:finish_edge(u, v)
  local tag = u[1]
  if tag == "+" then
    self:normalize_duplication(u, v, 1)
  elseif tag == "{m" then
    local m = u[2]
    self:normalize_duplication(u, v, m, m)
  elseif tag == "{m," then
    local m = u[2]
    self:normalize_duplication(u, v, m)
  elseif tag == "{m,n" then
    local m = u[2]
    local n = u[3]
    if m > n then
      error("invalid interval expression {" .. m .. "," .. n .. "}")
    end
    self:normalize_duplication(u, v, m, n)
  end
end

function class:apply()
  local this = self.this
  this:dfs(self)
  return this
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
