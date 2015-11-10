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
local syntax_tree = require "dromozoa.regexp.syntax_tree"

local class = {}

function class.new(this)
  if type(this) == "string" then
    this = matcher(this)
  end
  return {
    this = this;
    that = syntax_tree();
    stack = sequence();
  }
end

function class:create_node(...)
  return self.that:create_node(...)
end

function class:raise(message)
  local this = self.this
  if message == nil then
    error("parse error at position " .. this.position)
  else
    error(message .. " at position " .. this.position)
  end
end

function class:extended_reg_exp()
  local this = self.this
  local stack = self.stack
  if self:ERE_branch() then
    local node = self:create_node("|")
    node:append_child(stack:pop())
    while this:match("%|") do
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
  local this = self.this
  local stack = self.stack
  if self:one_char_or_coll_elem_ERE_or_grouping() then
    if self:ERE_dupl_symbol() then
      local node = stack:pop()
      node:append_child(stack:pop())
      return stack:push(node)
    else
      return true
    end
  elseif this:match("([%^%$])") then
    return stack:push(self:create_node(this[1]))
  end
end

function class:one_char_or_coll_elem_ERE_or_grouping()
  local this = self.this
  local stack = self.stack
  if this:match("([^%^%.%[%$%(%)%|%*%+%?%{%\\])") then
    return stack:push(self:create_node("char", this[1]))
  elseif this:match("\\([%^%.%[%$%(%)%|%*%+%?%{%\\])") then
    return stack:push(self:create_node("\\", this[1]))
  elseif this:match("%.") then
    return stack:push(self:create_node("."))
  elseif self:bracket_expression() then
    return true
  elseif this:match("%(") then
    if self:extended_reg_exp() then
      if this:match("%)") then
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
  local this = self.this
  local stack = self.stack
  if this:match("([%*%+%?])") then
    return stack:push(self:create_node(this[1]))
  elseif this:match("%{") then
    if this:match("(%d+)%}") then
      return stack:push(self:create_node("{m", tonumber(this[1], 10)))
    elseif this:match("(%d+),%}") then
      return stack:push(self:create_node("{m,", tonumber(this[1], 10)))
    elseif this:match("(%d+),(%d+)%}") then
      return stack:push(self:create_node("{m,n", tonumber(this[1], 10), tonumber(this[2], 10)))
    else
      self:raise()
    end
  end
end

function class:bracket_expression()
  local this = self.this
  local stack = self.stack
  if this:match("(%[%^?)") then
    local node = self:create_node("[", this[1] == "[^")
    if self:expression_term() then
      node:append_child(stack:pop())
      while self:expression_term() do
        node:append_child(stack:pop())
      end
      if this:match("%-") then
        node:append_child(self:create_node("[char", "-"))
      end
      if this:match("%]") then
        return stack:push(node)
      else
        self:raise("unmatched brackets")
      end
    else
      self:raise()
    end
  end
end

function class:expression_term()
  local this = self.this
  local stack = self.stack
  if this:match("%[%=") then
    if this:match("(..-)%=%]") then
      return stack:push(self:create_node("[=", this[1]))
    else
      self:raise("unclosed equivalence class")
    end
  elseif this:match("%[%:") then
    if this:match("(..-)%:%]") then
      return stack:push(self:create_node("[:", this[1]))
    else
      self:raise("unclosed character class")
    end
  elseif self:end_range() then
    if this:lookahead("%-%]") then
      return true
    elseif this:match("%-") then
      local node = self:create_node("[-")
      node:append_child(stack:pop())
      if this:match("%-") then
        node:append_child(self:create_node("[char", "-"))
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
  local this = self.this
  local stack = self.stack
  if this:match("%[%.") then
    if this:match("(..-)%.%]") then
      return stack:push(self:create_node("[.", this[1]))
    else
      self:raise("unclosed collating symbol")
    end
  elseif this:match("([^%^%-%]])") then
    return stack:push(self:create_node("[char", this[1]))
  end
end

function class:apply(token)
  if token == nil then
    token = 1
  end
  local this = self.this
  local stack = self.stack
  if self:extended_reg_exp() then
    if #stack == 1 then
      local node = stack:pop()
      node.start = token
      return self.that, this
    else
      self:raise()
    end
  else
    self:raise()
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
