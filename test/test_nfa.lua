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

local bitset = require "dromozoa.commons.bitset"
local ipairs = require "dromozoa.commons.ipairs"
local sequence = require "dromozoa.commons.sequence"
local sequence_writer = require "dromozoa.commons.sequence_writer"
local xml = require "dromozoa.commons.xml"
local parser = require "dromozoa.regexp.parser"
local node_to_nfa = require "dromozoa.regexp.node_to_nfa2"

local function bitset_to_string(bitset)
  local count = bitset:count()
  if count == 0 then
    return "epsilon"
  elseif count == 256 then
    return "0-255"
  elseif bitset:test(257) then
    return "^"
  elseif bitset:test(256) then
    return "$"
  else
    local a = sequence()
    local b = sequence()
    for i = 0, 255 do
      if bitset:test(i) then
        if b:top() == i - 1 then
          b[#b] = i
        else
          a:push(i)
          b:push(i)
        end
      end
    end
    local out = sequence_writer()
    for i, u in ipairs(a) do
      if i > 1 then
        out:write(",")
      end
      local v = b[i]
      if u == v then
        out:write(u)
      elseif u == v - 1 then
        out:write(u, ",", v)
      else
        out:write(u, "-", v)
      end
    end
    return out:concat()
  end
end

local p = parser("^[a-zA-Z[:digit:]]*[abce]+[^[. .]---]?|f(oo){1,4}|\\(b(ar|.z)$")
local root = p:parse()
local g = node_to_nfa():convert(root)
p.tree:write_graphviz(assert(io.open("test.dot", "w")), {
  node_attributes = function (_, node)
    local out = sequence_writer()
    out:write("<<table>")
    for i, v in ipairs(node) do
      out:write("<tr><td>", i, "</td><td>", xml.escape(v):gsub("%]", "&#135;"), "</td></tr>")
    end
    if node.bitset then
      out:write("<tr><td>bitset</td><td>", xml.escape(bitset_to_string(node.bitset)):gsub("%]", "&#135;"), "</td></tr>")
    end
    if node.m then
      out:write("<tr><td>m</td><td>", node.m, "</td></tr>")
    end
    if node.n then
      out:write("<tr><td>n</td><td>", node.n, "</td></tr>")
    end
    out:write("</table>>")
    return {
      shape = "plaintext";
      label = out:concat();
    }
  end;
})
