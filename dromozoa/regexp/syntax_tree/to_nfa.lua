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

function class:examine_edge(u, v)
  return u.condition == nil
end

function class:discover_node(u)
  local that = self.that
  local tag = u[1]
  if tag == "|" then
    u.uid = that:create_vertex().id
    u.vid = that:create_vertex().id
  elseif tag == "concat" then
    local uid = that:create_vertex().id
    u.uid = uid
    u.vid = uid
  end
end

function class:finish_edge(u, v)
  local that = self.that
  local tag = u[1]
  local uid = v.uid
  if tag == "concat" then
    if uid == nil then
      uid = that:create_vertex().id
      that:create_edge(u.vid, uid).condition = v.condition
      u.vid = uid
    else
      that:create_edge(u.vid, uid)
      u.vid = v.vid
    end
  else
    local vid = v.vid
    if uid == nil then
      uid = that:create_vertex().id
      vid = that:create_vertex().id
      that:create_edge(uid, vid).condition = v.condition
    end
    if tag == "|" then
      that:create_edge(u.uid, uid)
      that:create_edge(vid, u.vid)
    elseif tag == "*" then
      that:create_edge(vid, uid)
      u.uid = uid
      u.vid = uid
    elseif tag == "?" then
      that:create_edge(uid, vid)
      u.uid = uid
      u.vid = vid
    end
  end
end

function class:apply()
  local this = self.this
  local that = self.that
  local u = this:start()
  local token = u.start
  u:dfs(self)
  that:get_vertex(u.uid).start = token
  that:get_vertex(u.vid).accept = token
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
