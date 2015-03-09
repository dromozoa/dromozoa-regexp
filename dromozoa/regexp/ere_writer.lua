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

return function (out)
  local self = {
    _out = out;
  }

  function self:write(...)
    self._out:write(...)
  end

  function self:extended_reg_exp(node)
    self:ERE_branch(node[1])
    for i = 2, #node do
      self:write("|")
      self:ERE_branch(node[i])
    end
  end

  function self:ERE_branch(node)
    for i = 1, #node do
      self:ERE_expression(node[i])
    end
  end

  function self:ERE_expression(node)
    local nodetype = type(node)
    if nodetype == "table" then
      local a, b = node[1], node[2]
      self:one_char_or_coll_elem_ERE_or_grouping(a)
      if b then
        self:ERE_dupl_symbol(b)
      end
    elseif nodetype == "string" then
      self:write(node)
    end
  end

  function self:one_char_or_coll_elem_ERE_or_grouping(node)
    local nodetype = type(node)
    if nodetype == "string" then
      if node:match "^[%^%.%[%$%(%)%|%*%+%?%{%\\]$" then
        self:write("\\")
      end
      self:write(node)
    elseif nodetype == "number" then
      self:write(".")
    elseif nodetype == "table" then
      if type(node[1]) == "boolean" then
        self:bracket_expression(node)
      else
        self:write("(")
        self:extended_reg_exp(node)
        self:write(")")
      end
    end
  end

  function self:ERE_dupl_symbol(node)
    local nodetype = type(node)
    if nodetype == "string" then
      self:write(node)
    elseif nodetype == "number" then
      self:write("{", node, "}")
    elseif nodetype == "table" then
      local a, b = node[1], node[2]
      self:write("{", a, ",")
      if b then
        self:write(b)
      end
      self:write("}")
    end
  end

  function self:bracket_expression(node)
    self:write("[")
    if not node[1] then
      self:write("^")
    end
    for i = 2, #node do
      self:expression_term(node[i])
    end
    self:write("]")
  end

  function self:expression_term(node)
    local nodetype = type(node)
    if nodetype == "table" then
      local a, b = node[1], node[2]
      if b then
        self:end_range(a)
        self:write("-")
        self:end_range(b)
      else
        self:write("[:", a, ":]")
      end
    elseif nodetype == "string" then
      self:end_range(node)
    end
  end

  function self:end_range(node)
    if node:match "^[%^%-%]]$" then
      self:write("[.", node, ".]")
    else
      self:write(node)
    end
  end

  return self
end
