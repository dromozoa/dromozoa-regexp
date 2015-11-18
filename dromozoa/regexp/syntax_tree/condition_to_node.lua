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
local clone = require "dromozoa.commons.clone"
local push = require "dromozoa.commons.push"

local class = {}

function class.new(this)
  return {
    this = this;
  }
end

function class:create_range_char_node(byte)
  local this = self.this
  local char = string.char(byte)
  if char:match("^[%^%-%]]$") then
    return this:create_node("[.", char)
  else
    return this:create_node("[char", char)
  end
end

function class:apply(condition)
  local this = self.this
  if condition == nil then
    return this:create_node("epsilon")
  elseif condition:test(256) then
    return this:create_node("^")
  elseif condition:test(257) then
    return this:create_node("$")
  else
    local count = condition:count()
    if count == 1 then
      local char = string.char((apply(condition:each())))
      if char:match("^[%^%.%[%$%(%)%|%*%+%?%{%\\]$") then
        return this:create_node("\\", char)
      else
        return this:create_node("char", char)
      end
    elseif count == 256 then
      return this:create_node(".")
    else
      local u = this:create_node("[", false)
      if count > 127 then
        condition = clone(condition):flip(0, 255)
        u[2] = true
      end
      for range in condition:ranges():each() do
        local a, b = range[1], range[2]
        if a == b then
          u:append_child(self:create_range_char_node(a))
        elseif a == b - 1 then
          u:append_child(self:create_range_char_node(a))
          u:append_child(self:create_range_char_node(b))
        else
          local v = u:append_child(this:create_node("[-"))
          v:append_child(self:create_range_char_node(a))
          v:append_child(self:create_range_char_node(b))
        end
      end
      return u
    end
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
