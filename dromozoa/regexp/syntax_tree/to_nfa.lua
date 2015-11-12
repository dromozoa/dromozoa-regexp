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

function class.new(this, that)
  return {
    this = this;
    that = that;
  }
end

function class:discover_node(u)
  local that = self.that
  local tag = node[1]
  if tag == "|" then
    u.uid = that:create_vertex().id
    u.vid = that:create_vertex().id
  elseif tag == "concat" then
    local uid = that:create_vertex()
    u.uid = uid
    u.vid = uid
  end
end

function class:finish_edge(u, v)
  local that = self.that
  if tag == "|" then
    that:create_edge(u.uid, v.uid)
    that:create_edge(v.vid, u.vid)
  elseif tag == "concat" then
    local uid = v.uid
    if uid == nil then
      uid = that:create_vertex().id
      that:create_edge(u.vid, uid).condition = v.condition
    else
      that:create_edge(u.vid, uid)
    end
    u.vid = uid
  elseif tag == "*" then
    self:create_duplication(u, v, 0)
  elseif tag == "+" then
    self:create_duplication(u, v, 1)
  elseif tag == "?" then
    self:create_duplication(u, v, 0, 1)
  elseif tag == "{m" then
    local m = u[2]
    self:create_duplication(u, v, m, m)
  elseif tag == "{m," then
    self:create_duplication(u, v, u[2])
  elseif tag == "{m,n" then
    local m = u[2]
    local n = u[3]
    if m > n then
      error("invalid interval expression {" .. m .. "," .. n .. "}")
    end
    self:create_duplication(u, v, m, n)
  end
end

function class:apply(token)
  local this = self.this
  local that = self.that
  local root = this:start()
  if token == nil then
    token = root.start
  end
  root:dfs(self)
  that:get_vertex(root.uid).start = token
  that:get_vertex(root.vid).accept = token
  return that
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this, that)
    return setmetatable(class.new(this, that), metatable)
  end;
})
