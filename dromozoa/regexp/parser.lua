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

local class = {}

function class.new(regexp)
  return {
    matcher = matcher(regexp);
    tree = tree();
    stack = sequence();
  }
end

function class:parse()
  local matcher = self.matcher
  local stack = self.stack
  if self:extended_reg_exp() then
    if matcher:eof() and #stack == 1 then
      return stack:pop()
    end
  end
  self:raise()
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
  local matcher = self.matcher
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
      local node = stack:pop()
      node:append_child(stack:pop())
      return stack:push(node)
    else
      return true
    end
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
  elseif self:bracket_expression() then
    return true
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
  elseif matcher:match("%{") then
    if matcher:match("(%d+)%}") then
      return stack:push(self:create_node("{m", matcher[1]))
    elseif matcher:match("(%d+),%}") then
      return stack:push(self:create_node("{m,", matcher[1]))
    elseif matcher:match("(%d+),(%d+)%}") then
      return stack:push(self:create_node("{m,n", matcher[1], matcher[2]))
    else
      self:raise()
    end
  end
end

function class:bracket_expression()
  local matcher = self.matcher
  local stack = self.stack
  if matcher:match("(%[%^?)") then
    local node = self:create_node(matcher[1])
    if self:expression_term() then
      node:append_child(stack:pop())
    else
      self:raise()
    end
    while self:expression_term() do
      node:append_child(stack:pop())
    end
    if matcher:match("%-") then
      node:append_child(self:create_node("[.", "-"))
    end
    if matcher:match("%]") then
      return stack:push(node)
    else
      self:raise("unmatched brackets")
    end
  end
end

function class:expression_term()
  local matcher = self.matcher
  local stack = self.stack
  if matcher:match("%[%=") then
    if matcher:match("(..-)%=%]") then
      return stack:push(self:create_node("[=", matcher[1]))
    else
      self:raise()
    end
  elseif matcher:match("%[%:") then
    if matcher:match("(..-)%:%]") then
      return stack:push(self:create_node("[:", matcher[1]))
    else
      self:raise()
    end
  elseif self:end_range() then
    if matcher:lookahead "%-%]" then
      return true
    elseif matcher:match("%-") then
      local node = self:create_node("[-")
      node:append_child(stack:pop())
      if matcher:match("%-") then
        node:append_child(self:create_node("[.", "-"))
      elseif self:end_range() then
        node:append_child(stack:pop())
      else
        self:raise()
      end
      return stack:push(node)
    else
      return true
    end
  end
end

function class:end_range()
  local matcher = self.matcher
  local stack = self.stack
  if matcher:match("%[%.") then
    if matcher:match("(..-)%.%]") then
      return stack:push(self:create_node("[.", matcher[1]))
    else
      self:raise()
    end
  elseif matcher:match("([^%^%-%]])") then
    return stack:push(self:create_node("[char", matcher[1]))
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, regexp)
    return setmetatable(class.new(regexp), metatable)
  end;
})
