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

local xml = require "dromozoa.commons.xml"
local unparse = require "dromozoa.regexp.unparse"

local zero_width = {
  ["epsilon"] = {
    fontcolor = "red";
    label = "<&epsilon;>";
  };

  ["^"] = {
    fontcolor = "red";
    label = "<^>";
  };

  ["$"] = {
    fontcolor = "red";
    label = "<$>";
  };
}

local function attributes_visitor()
  local self = {}

  function self:graph_attributes()
    return {
      rankdir = "LR";
    }
  end

  function self:node_attributes(u)
    local start = u.start
    local accept = u.accept
    if start or accept then
      local attributes = {}
      if start then
        attributes.style = "filled"
        attributes.fontcolor = "white"
        attributes.fillcolor = "black"
      end
      if accept then
        attributes.peripheries = 2
        attributes.label = "<" .. xml.escape(u.id .. " / " .. accept) .. ">"
      end
      return attributes
    end
  end

  function self:edge_attributes(e)
    local node = e.condition
    local attributes = zero_width[node[1]]
    if attributes then
      return attributes
    else
      return {
        label = "<" .. xml.escape(unparse(node)) .. ">";
      }
    end
  end

  return self
end

local visitor = attributes_visitor()

return function (g, out)
  return g:write_graphviz(out, visitor)
end
