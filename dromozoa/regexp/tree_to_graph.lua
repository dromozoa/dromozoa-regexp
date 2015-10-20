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

function class:finish_node(node)
  local tag, value = node[1], node[2]
  if tag == "[." then
    local byte = locale.collating_elements[value]
    if byte == nil then
      error("collating symbol " .. value .. " is not supported in the current locale")
    end
    node[3] = byte
  elseif tag == "[char" or tag == "char" or tag == "\\" then
    local byte = string.byte(value)
    node[3] = byte
  end
end

function class:convert(root)
  root:dfs(self)
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
