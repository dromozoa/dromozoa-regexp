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
  local tag = u[1]
  if tag == "[-" then
    if v:is_first_child() then
      local a = string.byte(v[2])
      local b = string.byte(v:next_sibling()[2])
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
    local id = graph:create_vertex().id
    u.uid = id
    u.vid = id
  elseif tag == "^" then
    u.condition = bitset():set(257)
  elseif tag == "$" then
    u.condition = bitset():set(256)
  elseif tag == "char" or tag == "\\" then
    u.condition = bitset():set(string.byte(u[2]))
  elseif tag == "[" then
    u.condition = bitset()
  elseif tag == "[=" then
    local v = u[2]
    error("equivalence class " .. v .. " is not supported in the current locale")
  elseif tag == "[:" then
    local v = u[2]
    local condition = locale.character_classes[v]
    if condition == nil then
      error("character class " .. v .. " is not supported in the current locale")
    end
    u.condition = condition
  elseif tag == "[." then
    local v = u[2]
    local byte = locale.collating_elements[v]
    if byte == nil then
      error("collating symbol " .. v .. " is not supported in the current locale")
    end
    u.condition = bitset():set(byte)
  elseif tag == "[char" then
    local byte = string.byte(u[2])
    u.condition = bitset():set(byte)
  end
end

function class:finish_edge(u, v)
  local graph = self.graph
  local tag = u[1]
  if tag == "|" then
    local e1 = graph:create_edge(u.uid, v.uid)
    e1.condition = bitset()
    local e2 = graph:create_edge(v.vid, u.vid)
    e2.condition = bitset()
  elseif tag == "concat" then
    local condition = v.condition
    if condition == nil then
      local e = graph:create_edge(u.vid, v.uid)
      e.condition = bitset()
      u.vid = v.vid
    else
      local id = graph:create_vertex().id
      local e = graph:create_edge(u.vid, id)
      e.condition = condition
      v.uid = u.vid
      v.vid = id
      u.vid = id
    end
  elseif tag == "+" then
    self:create_duplication(u, v, 1);
  elseif tag == "*" then
    self:create_duplication(u, v, 0);
  elseif tag == "?" then
    self:create_duplication(u, v, 0, 1);
  elseif tag == "{m" then
    local m = u[2]
    self:create_duplication(u, v, m, m)
  elseif tag == "{m," then
    self:create_duplication(u, v, u[2])
  elseif tag == "{m,n" then
    self:create_duplication(u, v, u[2], u[3])
  elseif tag == "[" then
    u.condition:union(v.condition)
  end
end

function class:finish_node(u)
  local tag = u[1]
  if tag == "[" then
    if u[2] then
      u.condition:flip(0, 255)
    end
  end
end

function class:create_duplication(u, v, m, n)
  local graph = self.graph
  u.uid = graph:create_vertex().id
  u.vid = graph:create_vertex().id
  for i = 1, m do
  end
end

function class:convert(node)
  node:dfs(self)
  return self.graph
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_)
    return setmetatable(class.new(), metatable)
  end;
})
