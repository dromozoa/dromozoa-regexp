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

local graph = require "dromozoa.graph"
local branch = require "dromozoa.regexp.branch"
local compile = require "dromozoa.regexp.compile"
local concat = require "dromozoa.regexp.concat"
local has_assertion = require "dromozoa.regexp.has_assertion"
local minimize = require "dromozoa.regexp.minimize"
local node_to_nfa = require "dromozoa.regexp.node_to_nfa"
local parse = require "dromozoa.regexp.parse"
local powerset_construction = require "dromozoa.regexp.powerset_construction"
local product_construction = require "dromozoa.regexp.product_construction"
local remove_assertions = require "dromozoa.regexp.remove_assertions"
local set_token = require "dromozoa.regexp.set_token"
local write_graphviz = require "dromozoa.regexp.write_graphviz"

local function convert(regexp, token)
  return minimize(powerset_construction(node_to_nfa(parse(regexp), token)))
end

local function construct(_g)
  local self = {}

  function self:clone()
    return construct(_g:clone())
  end

  function self:minimize()
    _g = minimize(_g)
    return self
  end

  function self:branch(that, token)
    if type(that) == "string" then that = construct(convert(that, token)) end
    -- not minimize
    _g = powerset_construction(branch(_g, that:impl_get()))
    return self
  end

  function self:concat(that, token)
    if type(that) == "string" then that = construct(convert(that, token)) end
    _g = minimize(powerset_construction(concat(_g, that:impl_get())))
    return self
  end

  function self:intersection(that, token)
    if type(that) == "string" then that = construct(convert(that, token)) end
    _g = minimize(product_construction.intersection(_g, that:impl_get()))
    return self
  end

  function self:union(that, token)
    if type(that) == "string" then that = construct(convert(that, token)) end
    _g = minimize(product_construction.union(_g, that:impl_get()))
    return self
  end

  function self:difference(that, token)
    if type(that) == "string" then that = construct(convert(that, token)) end
    _g = minimize(product_construction.difference(_g, that:impl_get()))
    return self
  end

  function self:remove_assertions()
    local g = remove_assertions(_g)
    _g = minimize(_g)
    return construct(minimize(g))
  end

  function self:set_token(token)
    set_token(_g, token)
    return self
  end

  function self:write_graphviz(out)
    return write_graphviz(_g, out)
  end

  function self:compile()
    return compile(_g)
  end

  function self:empty()
    return _g:empty()
  end

  function self:has_start_assertion()
    return has_assertion(_g, "^")
  end

  function self:has_end_assertion()
    return has_assertion(_g, "$")
  end

  function self:impl_get()
    return _g
  end

  return self
end

return function (that, token)
  if type(that) == "string" then
    return construct(convert(that, token))
  else
    return construct(that)
  end
end
