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

local matcher = require "dromozoa.commons.matcher"
local push = require "dromozoa.commons.push"
local sequence = require "dromozoa.commons.sequence"
local tree = require "dromozoa.tree"
local locale = require "dromozoa.regexp.locale"
local unparse = require "dromozoa.regexp.unparse"

local class = {}

function class.new(regexp)
  return {
    regexp = regexp;
    matcher = matcher(regexp);
    tree = tree();
    stack = sequence();
  }
end

function class:parse()
  if self:extended_reg_exp() then
    if self.matcher.position == #self.regexp + 1 and #self.stack == 1 then
      return self:pop()
    else
      self:raise()
    end
  else
    self:raise()
  end
end

function class:raise(message)
  if message == nil then
    error("parse error at position " .. self.matcher.position)
  else
    error(message .. " at position " .. self.matcher.position)
  end
end

function class:create_node(...)
  local node = self.tree:create_node()
  push(node, 0, ...)
  return node
end

function class:push(node)
  self.stack:push(node)
  return true
end

function class:pop()
  return self.stack:pop()
end

function class:extended_reg_exp()
  local matcher = self.matcher
  if self:ERE_branch() then
    local node = self:create_node("|")
    node:append_child(self:pop())
    while matcher:match("%|") do
      if self:ERE_branch() then
        node:append_child(self:pop())
      else
        self:raise()
      end
    end
    return self:push(node)
  end
end

function class:ERE_branch()
  if self:ERE_expression() then
    local node = self:create_node("concat")
    node:append_child(self:pop())
    while self:ERE_expression() do
      node:append_child(self:pop())
    end
    return self:push(node)
  end
end

function class:ERE_expression()
  local matcher = self.matcher
  if self:one_char_or_coll_elem_ERE_or_grouping() then
    if self:ERE_dupl_symbol() then
      local a = self:pop()
      local b = self:pop()
      a:append_child(b)
      self:push(a)
    end
    return true
  elseif matcher:match("([%^%$])") then
    return self:push(self:create_node(matcher[1]))
  end
end

function class:one_char_or_coll_elem_ERE_or_grouping()
  local matcher = self.matcher
  if matcher:match("([^%^%.%[%$%(%)%|%*%+%?%{%\\])") then
    return self:push(self:create_node("char", matcher[1]))
  elseif matcher:match("\\([%^%.%[%$%(%)%|%*%+%?%{%\\])") then
    return self:push(self:create_node("\\", matcher[1]))
  elseif matcher:match("%.") then
    return self:push(self:create_node("."))
  end
end

function class:ERE_dupl_symbol()
  local matcher = self.matcher
  if matcher:match("([%*%+%?])") then
    return self:push(self:create_node(matcher[1]))
  elseif matcher:match("%{") then
    if matcher:match("(%d+)%}") then
      return self:push(self:create_node("{m", tonumber(matcher[1], 10)))
    elseif matcher:match("(%d+),%}") then
      return self:push(self:create_node("{m,", tonumber(matcher[1], 10)))
    elseif matcher:match("(%d+),(%d+)%}") then
      local m = tonumber(matcher[1], 10)
      local n = tonumber(matcher[2], 10)
      if m <= n then
        return self:push(self:create_node("{m,n", m, n))
      else
        self:raise("invalid interval expression {" .. m .. "," .. n .. "}")
      end
    end
  end
end

function class:bracket_expression()
end

function class:expression_term()
end

function class:end_range()
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, regexp)
    return setmetatable(class.new(regexp), metatable)
  end;
})
