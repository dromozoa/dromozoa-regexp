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

local branch = require "dromozoa.regexp.branch"
local concat = require "dromozoa.regexp.concat"
local minimize = require "dromozoa.regexp.minimize"
local node_to_nfa = require "dromozoa.regexp.node_to_nfa"
local parse = require "dromozoa.regexp.parse"
local powerset_construction = require "dromozoa.regexp.powerset_construction"
local product_construction = require "dromozoa.regexp.product_construction"
local set_token = require "dromozoa.regexp.set_token"
local write_graphviz = require "dromozoa.regexp.write_graphviz"

local function construct(_dfa)
  local self = {}

  function self:clone()
    return construct(_dfa:clone())
  end

  function self:branch(that, token)
    -- not minimize
    _dfa = powerset_construction(branch(_dfa, that:impl_get_dfa()))
    return self
  end

  function self:concat(that)
    _dfa = minimize(powerset_construction(concat(_dfa, that:impl_get_dfa())))
    return self
  end

  function self:intersection(that)
    _dfa = minimize(product_construction.intersection(_dfa, that:impl_get_dfa()))
    return self
  end

  function self:union(that)
    _dfa = minimize(product_construction.union(_dfa, that:impl_get_dfa()))
    return self
  end

  function self:difference(that)
    _dfa = minimize(product_construction.difference(_dfa, that:impl_get_dfa()))
    return self
  end

  function self:set_token(token)
    set_token(_dfa, token)
    return self
  end

  function self:write_graphviz(out)
    return write_graphviz(_dfa, out)
  end

  function self:impl_get_dfa()
    return _dfa
  end

  return self
end

return function (regexp, token)
  return construct(minimize(powerset_construction(node_to_nfa(parse(regexp), token))))
end
