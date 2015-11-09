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

local clone = require "dromozoa.commons.clone"
local push = require "dromozoa.commons.push"
local tree = require "dromozoa.tree"
local graphviz_visitor = require "dromozoa.regexp.syntax_tree.graphviz_visitor"
local setup_condition = require "dromozoa.regexp.syntax_tree.setup_condition"

local class = clone(tree)

function class:create_node(...)
  local node = tree.create_node(self)
  push(node, 0, ...)
  return node
end

function class:setup_condition()
  setup_condition(self):apply()
  return self
end

function class:write_graphviz(out)
  return tree.write_graphviz(self, out, graphviz_visitor())
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
