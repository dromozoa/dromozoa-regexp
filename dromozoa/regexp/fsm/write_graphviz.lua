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

local ere_unparser = require "dromozoa.regexp.ere_unparser"
local buffer_writer = require "dromozoa.regexp.buffer_writer"

local zero_length = {
  [0] = "<<font color=\"#CC0000\">&epsilon;</font>>";
  [1] = "<<font color=\"#CC0000\">^</font>>";
  [2] = "<<font color=\"#CC0000\">$</font>>";
}

local quote = {
  ["\""] = "&quot;";
  ["&"] = "&amp;";
  ["<"] = "&lt;";
  [">"] = "&gt;";
}

local function label(c)
  if type(c) == "number" and c >= 0 then
    return zero_length[c]
  else
    local out = buffer_writer()
    ere_unparser(out):one_char_or_coll_elem_ERE_or_grouping(c)
    return "<" .. out:concat():gsub("[\"&<>]", quote) .. ">"
  end
end

return function (fsm, out)
  out:write("digraph \"fsm\" {\n  graph [rankdir = LR];\n")
  for u in fsm:each_start() do
    out:write("  ", u, " [style = filled, fillcolor = \"#CCCCCC\"];\n")
  end
  for v in fsm:each_accept() do
    out:write("  ", v, " [peripheries = 2];\n")
  end
  for i, e in fsm:each_edge() do
    out:write("  ", e[2], " -> ", e[3], " [label = ", label(e[4]), "];\n")
  end
  out:write("}\n")
end
