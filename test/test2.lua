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
local parser = require "dromozoa.regexp.ere_parser"
local node_to_nfa = require "dromozoa.regexp.node_to_nfa2"
local powerset_construction = require "dromozoa.regexp.powerset_construction2"

local function condition_to_string(condition)
  local count = condition:count()
  if count == 0 then
    return "epsilon"
  elseif count == 256 then
    return "0-255"
  elseif condition:test(257) then
    return "^"
  elseif condition:test(256) then
    return "$"
  else
    local a = sequence()
    local b = sequence()
    for i = 0, 255 do
      if condition:test(i) then
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
-- local p = parser("(def|ghi)abc")
-- local p = parser("abc[z-a](def|ghi){1,3}jkl")
-- local p = parser("[ --]+")
-- local p = parser("(abc)+d+e{1,3}")
-- local p = parser("x(abc)*y")
local root = p:parse()
local to_nfa = node_to_nfa()
to_nfa:apply(root)
local powerset = powerset_construction(to_nfa.graph)
powerset:apply()

p.tree:write_graphviz(assert(io.open("test.dot", "w")), {
  node_attributes = function (self, node)
    local out = sequence_writer()
    out:write("<<table>")
    for i, v in ipairs(node) do
      out:write("<tr><td>", i, "</td><td>", xml.escape(v):gsub("%]", "&#135;"), "</td></tr>")
    end
    if node.condition then
      out:write("<tr><td>condition</td><td>", xml.escape(condition_to_string(node.condition)):gsub("%]", "&#135;"), "</td></tr>")
    end
    if node.uid then
      out:write("<tr><td>uid</td><td>", node.uid, "</td></tr>")
    end
    if node.vid then
      out:write("<tr><td>vid</td><td>", node.vid, "</td></tr>")
    end
    out:write("</table>>")
    return {
      shape = "plaintext";
      label = out:concat();
    }
  end;
}):close()

powerset.dfa:write_graphviz(assert(io.open("test-graph.dot", "w")), {
  graph_attributes = function (self)
    return {
      rankdir = "LR";
    }
  end;
  node_attributes = function (self, u)
    local attributes = {}
    if u.start then
      attributes.style = "filled"
      attributes.fontcolor = "white"
      attributes.fillcolor = "black"
    end
    if u.accept then
      attributes.peripheries = 2
    end
    return attributes
  end;
  edge_attributes = function (self, e)
    if e.condition then
      return {
        label = "<" .. xml.escape(condition_to_string(e.condition)):gsub("%]", "&#135;") .. ">";
      }
    end
  end;
}):close()
