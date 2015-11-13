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
local graphviz = require "dromozoa.regexp.graphviz"

local function write_property(out, u, k)
  local v = u[k]
  if v ~= nil then
    out:write("<tr><td>", k, "</td><td>", xml.escape(v, "%W"), "</td></tr>")
  end
end

local class = {}

function class.new()
  return {}
end

function class:node_attributes(u)
  local out = sequence_writer():write("<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\">")
  out:write("<tr><td>id</td><td>", u.id, "</td></tr>")
  for i, v in ipairs(u) do
    out:write("<tr><td>", i, "</td><td>", xml.escape(v, "%W"), "</td></tr>")
  end
  out:write("<tr><td>condition</td><td>", graphviz.quote_condition(u.condition), "</td></tr>")
  write_property(out, u, "regexp")
  write_property(out, u, "uid")
  write_property(out, u, "vid")
  return {
    shape = "plaintext";
    label = out:write("</table>>"):concat();
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
