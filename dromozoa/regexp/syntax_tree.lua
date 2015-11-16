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
local tree = require "dromozoa.tree"
local condition_to_node = require "dromozoa.regexp.syntax_tree.condition_to_node"
local denormalize = require "dromozoa.regexp.syntax_tree.denormalize"
local ere_parser = require "dromozoa.regexp.syntax_tree.ere_parser"
local ere_unparser = require "dromozoa.regexp.syntax_tree.ere_unparser"
local graphviz_visitor = require "dromozoa.regexp.syntax_tree.graphviz_visitor"
local normalize = require "dromozoa.regexp.syntax_tree.normalize"
local node_to_condition = require "dromozoa.regexp.syntax_tree.node_to_condition"
local to_nfa = require "dromozoa.regexp.syntax_tree.to_nfa"

local class = clone(tree)

function class.ere(this, token)
  return ere_parser(this, class()):apply(token)
end

function class:start()
  if self:count_node("start") ~= 1 then
    error("only one start node allowed")
  end
  return apply(self:each_node("start"))
end

function class:create_node(...)
  local node = tree.create_node(self)
  push(node, 0, ...)
  return node
end

function class:to_ere(sort)
  return ere_unparser(self, sort):apply()
end

function class:write_graphviz(out)
  return tree.write_graphviz(self, out, graphviz_visitor())
end

function class:normalize()
  normalize(self):apply()
  return self
end

function class:denormalize()
  denormalize(self):apply()
  return self
end

function class:node_to_condition()
  node_to_condition(self):apply()
  return self
end

function class:condition_to_node(condition)
  return condition_to_node(self):apply(condition)
end

function class:to_nfa(token)
  return to_nfa(self, self.super.automaton()):apply(token)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
