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

local powerset_construction = require "dromozoa.regexp.automaton.powerset_construction"
local product_construction = require "dromozoa.regexp.automaton.product_construction"
local tokens = require "dromozoa.regexp.automaton.tokens"
local operations = require "dromozoa.regexp.automaton.operations"
local write_graphviz = require "dromozoa.regexp.automaton.write_graphviz"

local class = {}

function class.new(this)
  return {
    this = this;
  }
end

function class:to_dfa()
  self.this = powerset_construction(self.this):apply()
  return self
end

function class:reverse()
  self.this = operations.reverse(self.this)
  return self
end

function class:minimize()
  -- Brzozowski's algorithm
  return self:reverse():to_dfa():reverse():to_dfa()
end

function class:branch(that)
  self.this = operations.branch(self.this, that.this)
  -- not minimize
  return self:to_dfa()
end

function class:concat(that)
  self.this = operations.concat(self.this, that.this)
  return self:minimize()
end

function class:product_construction(that, fn)
  self.this = product_construction():apply(self.this, that.this, fn)
  return self:minimize()
end

function class:set_intersection(that)
  return self:product_construction(that, tokens.intersection)
end

function class:set_union(that)
  return self:product_construction(that, tokens.union)
end

function class:set_difference(that)
  return self:product_construction(that, tokens.difference)
end

function class:write_graphviz(out)
  return write_graphviz(self.this, out)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
