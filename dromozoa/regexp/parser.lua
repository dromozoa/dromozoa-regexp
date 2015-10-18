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
  local stack = self.stack
  if self:extended_reg_exp() then
    if self.matcher.position == #self.regexp + 1 and #stack == 1 then
      return stack:pop()
    else
      self:raise()
    end
  else
    self:raise()
  end
end

function class:raise(message)
  local matcher = self.matcher
  if message == nil then
    error("parse error at position " .. matcher.position)
  else
    error(message .. " at position " .. matcher.position)
  end
end

function class:create_node(...)
  local node = self.tree:create_node()
  push(node, 0, ...)
  return node
end

function class:extended_reg_exp()
  local matcher = self.matcher
  local stack = self.stack
  if self:ERE_branch() then
    local node = self:create_node("|")
    node:append_child(stack:pop())
    while matcher:match("%|") do
      if self:ERE_branch() then
        node:append_child(stack:pop())
      else
        self:raise()
      end
    end
    return stack:push(node)
  end
end

function class:ERE_branch()
  local stack = self.stack
  if self:ERE_expression() then
    local node = self:create_node("concat")
    node:append_child(stack:pop())
    while self:ERE_expression() do
      node:append_child(stack:pop())
    end
    return stack:push(node)
  end
end

function class:ERE_expression()
  local matcher = self.matcher
  local stack = self.stack
  if self:one_char_or_coll_elem_ERE_or_grouping() then
    if self:ERE_dupl_symbol() then
      local a = stack:pop()
      local b = stack:pop()
      a:append_child(b)
      stack:push(a)
    end
    return true
  elseif matcher:match("([%^%$])") then
    return stack:push(self:create_node(matcher[1]))
  end
end

function class:one_char_or_coll_elem_ERE_or_grouping()
  local matcher = self.matcher
  local stack = self.stack
  if matcher:match("([^%^%.%[%$%(%)%|%*%+%?%{%\\])") then
    return stack:push(self:create_node("char", matcher[1]))
  elseif matcher:match("\\([%^%.%[%$%(%)%|%*%+%?%{%\\])") then
    return stack:push(self:create_node("\\", matcher[1]))
  elseif matcher:match("%.") then
    return stack:push(self:create_node("."))
  elseif matcher:match("%(") then
    if self:extended_reg_exp() then
      if matcher:match("%)") then
        return true
      else
        self:raise("unmatched parentheses")
      end
    else
      self:raise()
    end
  end
end

function class:ERE_dupl_symbol()
  local matcher = self.matcher
  local stack = self.stack
  if matcher:match("([%*%+%?])") then
    return stack:push(self:create_node(matcher[1]))
  elseif matcher:match("%{(%d+)") then
    local m = tonumber(matcher[1], 10)
    local a = self:create_node("{")
    if matcher:match("%,") then
      b = self:create_node(",")
      b:append_child(self:create_node("m", m))
      if matcher:match("(%d+)") then
        b:append_child(self:create_node("n", tonumber(matcher[1], 10)))
      end
      a:append_child(b)
    else
      a:append_child(self:create_node("m", m))
    end
    if matcher:match("%}") then
      return stack:push(a)
    else
      self:raise()
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
