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

local ipais = require "dromozoa.commons.ipairs"
local sequence_writer = require "dromozoa.commons.sequence_writer"
local xml = require "dromozoa.commons.xml"
local parser = require "dromozoa.regexp.parser"
local tree_to_graph = require "dromozoa.regexp.tree_to_graph"

local p = parser("^[a-zA-Z[:digit:]][abc][^[.d.]--]|foo{4,1}|\\(b(ar|az)$")
local root = p:parse()
local g = tree_to_graph():convert(root)
p.tree:write_graphviz(assert(io.open("test.dot", "w")), {
  node_attributes = function (_, node)
    local out = sequence_writer()
    out:write("<<table>")
    for i, v in ipairs(node) do
      out:write("<tr><td>", i, "</td><td>", xml.escape(v):gsub("%]", "&#135;"), "</td></tr>")
    end
    out:write("</table>>")
    return {
      shape = "plaintext";
      label = out:concat();
    }
  end;
})
