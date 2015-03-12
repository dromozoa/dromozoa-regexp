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

local quote_impl = {
  ["&"] = "&amp;";
  ["\""] = "\\\"";
  ["\\"] = "\\\\";
  ["\n"] = "\\n";
}

local function quote(v)
  return "\"" .. v:gsub("[&\"\\\n]", quote_impl) .. "\""
end

return function (out)
  local self = { _out = out }

  function self:write(...)
    self._out:write(...)
  end

  function self:fsm(fsm)
    self:write("digraph \"fsm\" {\n")
    self:write("  graph [rankdir = LR]\n")
    self:accept(fsm.accept)
    self:transition(fsm.transition)
    self:write("}\n")
  end

  function self:accept(list)
    for i = 1, #list do
      self:write("  ", list[i], " [peripheries = 2];\n")
    end
  end

  function self:transition(list)
    for i = 1, #list do
      local v = list[i]
      local a, b, c = v[1], v[2], v[3]
      self:write("  ", a, " -> ", b, " [label = ")
      if type(c) == "number" and c >= 0 then
        self:write("<<font color=\"#CC0000\">")
        if c == 0 then
          self:write("&epsilon;")
        elseif c == 1 then
          self:write("^")
        elseif c == 2 then
          self:write("$")
        end
        self:write("</font>>")
      else
        local out = buffer_writer()
        ere_unparser(out):one_char_or_coll_elem_ERE_or_grouping(c)
        self:write(quote(out:concat()))
      end
      self:write("];\n")
    end
  end

  return self
end
