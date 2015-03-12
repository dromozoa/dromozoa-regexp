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

local buffer_writer = require "dromozoa.regexp.buffer_writer"
local ere_unparser = require "dromozoa.regexp.ere_unparser"
local graph = require "dromozoa.regexp.fsm.graph"

local graphviz_quote = {
  ["\""] = "&quot;";
  ["&"] = "&amp;";
  ["<"] = "&lt;";
  [">"] = "&gt;";
}

local function graphviz_label(c)
  if type(c) == "number" and c >= 0 then
    if c == 0 then
      return "<<font color=\"#CC0000\">&epsilon;</font>>"
    elseif c == 1 then
      return "<<font color=\"#CC0000\">^</font>>"
    elseif c == 2 then
      return "<<font color=\"#CC0000\">$</font>>"
    end
  else
    local out = buffer_writer()
    ere_unparser(out):one_char_or_coll_elem_ERE_or_grouping(c)
    return "<" .. out:concat():gsub("[\"&<>]", graphviz_quote) .. ">"
  end
end

return function ()
  local self = {
    _graph = graph();
    _start = {};
    _accept = {};
  }

  function self:add_edge(u, v, c)
    self._graph:add_edge(u, v, c)
  end

  function self:each_edge()
    return self._graph:each_edge()
  end

  function self:each_u_neighbor(u)
    return self._graph:each_u_neighbor(u)
  end

  function self:each_v_neighbor(v)
    return self._graph:each_v_neighbor(v)
  end

  function self:add_start(u)
    self._start[u] = true
  end

  function self:add_accept(v)
    self._accept[v] = true
  end

  function self:write_graphviz(out)
    out:write("digraph \"fsm\" {\n")
    out:write("  graph [rankdir = LR]\n")
    for k, v in pairs(self._accept) do
      out:write("  ", k, " [peripheries = 2];\n")
    end
    for i, e in self:each_edge() do
      out:write("  ", e[1], " -> ", e[2], " [label = ", graphviz_label(e[3]), "];\n")
    end
    out:write("}\n")
  end

  return self
end
