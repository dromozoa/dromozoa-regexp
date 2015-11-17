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

local sequence = require "dromozoa.commons.sequence"

local class = {}

local metatable = {
  __index = class;
}

function class.new(this, normalization)
  return {
    this = this;
    normalization = normalization;
  }
end

function class:discover_node(u)
  local tag = u[1]
  if tag == "|" or tag =="concat" or tag =="[" or tag == "[-" then
    u.regexp = sequence()
  elseif tag == "^" or tag == "$" or tag == "." then
    u.regexp = tag
  elseif tag == "char" or tag == "[char" then
    u.regexp = u[2]
  elseif tag == "\\" then
    u.regexp = "\\" .. u[2]
  elseif tag == "[=" then
    u.regexp = "[=" .. u[2] .. "=]"
  elseif tag == "[:" then
    u.regexp = "[:" .. u[2] .. ":]"
  elseif tag == "[." then
    u.regexp = "[." .. u[2] .. ".]"
  elseif tag == "epsilon" then
    u.regexp = ".{0}"
  end
end

function class:finish_edge(u, v)
  local tag = u[1]
  if tag == "|" or tag == "concat" or tag == "[" or tag == "[-" then
    u.regexp:push(v.regexp)
  elseif tag == "+" or tag == "*" or tag == "?" then
    u.regexp = v.regexp .. tag
  elseif tag == "{m" then
    u.regexp = v.regexp .. "{" .. u[2] .. "}"
  elseif tag == "{m," then
    u.regexp = v.regexp .. "{" .. u[2] .. ",}"
  elseif tag == "{m,n" then
    u.regexp = v.regexp .. "{" .. u[2] .. "," .. u[3] .. "}"
  end
end

function class:finish_node(u)
  local tag = u[1]
  if tag == "|" then
    local regexp
    if self.normalization then
      regexp = u.regexp:sort():concat("|")
    else
      regexp = u.regexp:concat("|")
    end
    if u:is_root() then
      u.regexp = regexp
    else
      u.regexp = "(" .. regexp .. ")"
    end
  elseif tag == "concat" then
    u.regexp = u.regexp:concat()
  elseif tag == "[" then
    if u[2] then
      u.regexp = "[^" .. u.regexp:concat() .. "]"
    else
      u.regexp = "[" .. u.regexp:concat() .. "]"
    end
  elseif tag == "[-" then
    u.regexp = u.regexp:concat("-")
  end
end

function class:apply()
  self.this:dfs(self)
  return self.this:start().regexp
end

return setmetatable(class, {
  __call = function (_, this, normalization)
    return setmetatable(class.new(this, normalization), metatable)
  end;
})
