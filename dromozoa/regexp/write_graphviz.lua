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

local graphviz = require "dromozoa.graph.graphviz"
local graphviz_attributes_adapter = require "dromozoa.graph.graphviz_attributes_adapter"
local unparse = require "dromozoa.regexp.unparse"

local zero_length = {
  ["epsilon"] = "<<font color=\"#CC0000\">&epsilon;</font>>";
  ["^"] = "<<font color=\"#CC0000\">^</font>>";
  ["$"] = "<<font color=\"#CC0000\">$</font>>";
}

local function label(node)
  local a = zero_length[node[1]]
  if a then
    return a
  else
    return "<" .. graphviz.escape_html(unparse(node)) .. ">"
  end
end

local function attributes()
  local self = {}

  function self:graph_attributes(g)
    return {
      rankdir = "LR";
    }
  end

  function self:node_attributes(g, u)
    if u.accept then
      return {
        peripheries = 2;
      }
    end
  end

  function self:edge_attributes(g, e)
    return {
      label = label(e.condition);
    }
  end

  return self
end

return function (g, out)
  g:write_graphviz(out, graphviz_attributes_adapter(attributes()))
  return out
end
