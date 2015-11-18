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

local sequence_writer = require "dromozoa.commons.sequence_writer"
local graphviz = require "dromozoa.regexp.graphviz"

local class = {}

function class.new()
  return {}
end

function class:graph_attributes()
  return {
    rankdir = "LR";
  }
end

function class:node_attributes(u)
  local start = u.start
  local accept = u.accept
  if start ~= nil or accept ~= nil then
    local attributes = {}
    local out = sequence_writer():write("<", u.id)
    if start ~= nil then
      attributes.style = "filled"
      attributes.fillcolor = "black"
      attributes.fontcolor = "white"
      out:write("/", start)
    end
    if accept ~= nil then
      attributes.peripheries = 2
      out:write("/", accept)
    end
    attributes.label = out:write(">"):concat()
    return attributes
  end
end

function class:edge_attributes(e)
  return {
    label = "<" .. graphviz.quote_condition(e.condition) .. ">";
  }
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
