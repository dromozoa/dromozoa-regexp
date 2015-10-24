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
local graph = require "dromozoa.graph"
local locale = require "dromozoa.regexp.locale"

local class = {}

function class.new()
  return {
    graph = graph();
  }
end

function class:examine_edge(u, v)
  if u[1] == "[-" then
    if v:is_first_child() then
      local w = v:next_sibling()
      local a = string.byte(v[2])
      local b = string.byte(w[2])
      if a > b then
        error("invalid range expression [" .. v[2] .. "-" .. w[2] .. "]")
      end
      u.condition = bitset():set(a, b)
    end
    return false
  end
end

function class:discover_node(u)
  local graph = self.graph
  local tag = u[1]
  if tag == "|" then
    u.uid = graph:create_vertex().id
    u.vid = graph:create_vertex().id
  elseif tag == "concat" then
    local uid = graph:create_vertex().id
    u.uid = uid
    u.vid = uid
  elseif tag == "^" then
    u.condition = bitset():set(257)
  elseif tag == "$" then
    u.condition = bitset():set(256)
  elseif tag == "char" or tag == "\\" then
    u.condition = bitset():set(string.byte(u[2]))
  elseif tag == "." then
    u.condition = bitset():set(0, 255)
  elseif tag == "[" then
    u.condition = bitset()
  elseif tag == "[=" then
    error("equivalence class " .. u[2] .. " is not supported in the current locale")
  elseif tag == "[:" then
    local value = u[2]
    local condition = locale.character_classes[value]
    if condition == nil then
      error("character class " .. value .. " is not supported in the current locale")
    end
    u.condition = condition
  elseif tag == "[." then
    local value = u[2]
    local byte = locale.collating_elements[value]
    if byte == nil then
      error("collating symbol " .. value .. " is not supported in the current locale")
    end
    u.condition = bitset():set(byte)
  elseif tag == "[char" then
    u.condition = bitset():set(string.byte(u[2]))
  end
end

function class:finish_edge(u, v)
  local graph = self.graph
  local tag = u[1]
  if tag == "|" then
    graph:create_edge(u.uid, v.uid)
    graph:create_edge(v.vid, u.vid)
  elseif tag == "concat" then
    local uid = v.uid
    if uid == nil then
      uid = graph:create_vertex().id
      graph:create_edge(u.vid, uid).condition = v.condition
      u.vid = uid
    else
      graph:create_edge(u.vid, uid)
      u.vid = v.vid
    end
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
  elseif tag == "[" then
    u.condition:union(v.condition)
  end
end

function class:finish_node(u)
  if u[1] == "[" and u[2] then
    u.condition:flip(0, 255)
  end
end

function class:create_duplication(u, v, m, n)
  local graph = self.graph
  local uid = graph:create_vertex().id
  local vid = v.uid
  local wid = v.vid
  if vid == nil then
    vid = graph:create_vertex().id
    wid = graph:create_vertex().id
    graph:create_edge(vid, wid).condition = v.condition
  end
  u.uid = uid
  if n == nil then
    for i = 1, m do
      local a, map = graph:get_vertex(vid):duplicate()
      local aid = a.id
      local bid = map[wid]
      graph:create_edge(uid, aid)
      uid = bid
    end
    graph:create_edge(uid, vid)
    graph:create_edge(wid, vid)
    uid = vid
    u.vid = vid
  else
    for i = 1, n do
      local aid = vid
      local bid = wid
      if i < n then
        local a, map = graph:get_vertex(vid):duplicate()
        aid = a.id
        bid = map[wid]
      end
      graph:create_edge(uid, aid)
      if i > m then
        graph:create_edge(uid, bid)
      end
      uid = bid
    end
    u.vid = uid
  end
end

function class:convert(node, token)
  if token == nil then
    token = 1
  end
  local graph = self.graph
  node:dfs(self)
  local u = graph:get_vertex(node.uid)
  local v = graph:get_vertex(node.vid)
  u.start = token
  v.accept = token
  return u, v
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
