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
local xml = require "dromozoa.commons.xml"
local parser = require "dromozoa.regexp.parser"

local p = parser([[a|^fo+|\..|x{2}|bar$]])
p:parse()
p.tree:write_graphviz(assert(io.open("test.dot", "w")), {
  node_attributes = function (_, node)
    local out = sequence_writer()
    out:write("<<table><tr><td>tag</td><td>", xml.escape(node.tag), "</td></tr>")
    if node.m ~= nil then
      out:write("<tr><td>m</td><td>", xml.escape(node.m), "</td></tr>")
    end
    if node.n ~= nil then
      out:write("<tr><td>n</td><td>", xml.escape(node.n), "</td></tr>")
    end
    if node.value ~= nil then
      out:write("<tr><td>value</td><td>", xml.escape(node.value), "</td></tr>")
    end
    out:write("</table>>")
    return {
      shape = "plaintext";
      label = out:concat();
    }
  end;
})
