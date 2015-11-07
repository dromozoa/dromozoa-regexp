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

local function escape_range_char(value)
  if value:match("^[%^%-%]]$") then
    return "[." .. value .. ".]"
  else
    return value
  end
end

local class = {}

local metatable = {
  __index = class;
}

function class.new()
  return {}
end

function class:examine_edge(u, v)
  if u[1] == "[-" then
    if v:is_first_child() then
      local w = v:next_sibling()
      u.regexp = escape_range_char(v[2]) .. "-" .. escape_range_char(w[2])
    end
    return false
  end
end

function class:discover_node(u)
  local tag = u[1]
  if tag == "|" or tag =="concat" or tag =="[" then
    u.regexp = sequence()
  elseif tag == "^" or tag == "$" or tag == "." then
    u.regexp = tag
  elseif tag == "char" or tag == "\\" then
    local value = u[2]
    if value:match("^[%^%.%[%$%(%)%|%*%+%?%{%\\]$") then
      u.regexp = "\\" .. value
    else
      u.regexp = value
    end
  elseif tag == "[char" or tag == "[." then
    u.regexp = escape_range_char(u[2])
  end
  print("discover_node", tag, u.regexp)
end

function class:finish_edge(u, v)
  local tag = u[1]
  if tag == "|" or tag == "concat" or tag == "[" then
    u.regexp:push(v.regexp)
  elseif tag == "*" then
    u.regexp = v.regexp .. "*"
  elseif tag == "?" then
    u.regexp = v.regexp .. "?"
  end
  print("finish_edge", tag, u.regexp, v.regexp)
end

function class:finish_node(u)
  local tag = u[1]
  if tag == "|" then
    u.regexp = "(" .. u.regexp:concat("|") .. ")"
  elseif tag == "concat" then
    u.regexp = "(" .. u.regexp:concat() .. ")"
  elseif tag == "[" then
    if u[2] then
      u.regexp = "[^" .. u.regexp:concat() .. "]"
    else
      u.regexp = "[" .. u.regexp:concat() .. "]"
    end
  end
  print("finish_node", tag, u.regexp)
end

function class:apply(this)
  this:dfs(self)
  return this.regexp
end

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
