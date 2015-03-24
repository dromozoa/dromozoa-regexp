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

local unparse = require "dromozoa.regexp.unparse"

local zero_length = {
  ["epsilon"] = "<<font color=\"#CC0000\">&epsilon;</font>>";
  ["^"] = "<<font color=\"#CC0000\">^</font>>";
  ["$"] = "<<font color=\"#CC0000\">$</font>>";
}

local quote = {
  ["\""] = "&quot;";
  ["&"] = "&amp;";
  ["<"] = "&lt;";
  [">"] = "&gt;";
}

local function label(node)
  local a = zero_length[node[1]]
  if a then
    return a
  else
    return "<" .. unparse(node):gsub("[\"&<>]", quote) .. ">"
  end
end

return function (g, out)
  out:write("digraph \"fsm\" {\n  graph [rankdir = LR];\n")
  for u in g:each_vertex("start") do
    out:write("  ", u.id, " [style = filled, fillcolor = \"#CCCCCC\"];\n")
  end
  for v in g:each_vertex("accept") do
    out:write("  ", v.id, " [peripheries = 2];\n")
  end
  for e in g:each_edge() do
    out:write("  ", e.uid, " -> ", e.vid, " [label = ", label(e.condition), "];\n")
  end
  out:write("}\n")
  return out
end
