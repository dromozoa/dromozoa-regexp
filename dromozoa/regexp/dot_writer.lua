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
  ["\""] = "\\\"";
  ["\\"] = "\\\\";
  ["\n"] = "\\n";
}

local function quote(v)
  return "\"" .. v:gsub("[\"\\\n]", quote_impl) .. "\""
end

return function (out)
  local self = { _out = out }

  function self:write(...)
    self._out:write(...)
    return self
  end

  function self:nfa(nfa)
    self:write("digraph \"nfa\" {\n")
    self:write("graph [rankdir = LR]\n")
    self:accept(nfa.accept)
    self:transition(nfa.transition)
    self:write("}\n")
  end

  function self:accept(accept)
    for i = 1, #accept do
      self:write(accept[i], " [peripheries = 2];\n")
    end
  end

  function self:transition(list)
    for i = 1, #list do
      local v = list[i]
      local a, b, c = v[1], v[2], v[3]
      self:write(a, " -> ", b, "[label = ")
      if c then
        local out = buffer_writer()
        ere_unparser(out):one_char_or_coll_elem_ERE_or_grouping(c)
        self:write(quote(out:concat()))
      else
        self:write("\"&epsilon;\"")
      end
      self:write("];\n")
    end
  end

  return self
end
