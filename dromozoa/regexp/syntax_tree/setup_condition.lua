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
local bitset = require "dromozoa.commons.bitset"
local locale = require "dromozoa.regexp.locale"

local class = {}

function class.new(this)
  return {
    this = this;
  }
end

function class:discover_node(u)
  local tag = u[1]
  if tag == "char" or tag == "\\" or tag == "[char" or tag == "[." then
    u.condition = bitset():set(string.byte(u[2]))
  elseif tag == "^" then
    u.condition = bitset():set(256)
  elseif tag == "$" then
    u.condition = bitset():set(257)
  elseif tag == "." then
    u.condition = bitset():set(0, 255)
  elseif tag == "[" then
    u.condition = bitset()
  elseif tag == "[=" then
    error("equivalence class " .. u[2] .. " is not supported in the current locale")
  elseif tag == "[:" then
    local condition = locale.character_classes[u[2]]
    if condition == nil then
      error("character class " .. u[2] .. " is not supported in the current locale")
    end
    u.condition = condition
  elseif tag == "[." then
    local byte = locale.collating_elements[u[2]]
    if byte == nil then
      error("collating symbol " .. u[2] .. " is not supported in the current locale")
    end
    u.condition = bitset():set(byte)
  end
end

function class:finish_edge(u, v)
  local tag = u[1]
  if tag == "[" then
    u.condition:union(v.condition)
  end
end

function class:finish_node(u)
  local tag = u[1]
  if tag == "[" then
    if u[2] then
      u.condition:flip(0, 255)
    end
  elseif tag == "[-" then
    local children = u:children()
    if #children ~= 2 then
      error("only two children allowed")
    end
    local a = apply(children[1].condition:each())
    local b = apply(children[2].condition:each())
    if a > b then
      error("invalid range expression " .. a .. "-" .. b)
    end
    u.condition = bitset():set(a, b)
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
