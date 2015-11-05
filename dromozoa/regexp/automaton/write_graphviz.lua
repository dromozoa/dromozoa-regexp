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

local function escape_range_char(byte)
  local char = string.char(byte)
  if char:match("^[%^%-%]]$") then
    return "[" .. char .. "]"
  else
    return char
  end
end

return function (this, out)
  return this:write_graphviz(out, {
    graph_attributes = function ()
      return {
        rankdir = "LR";
      }
    end;
    node_attributes = function (self, u)
      local start = u.start
      local accept = u.accept
      if start ~= nil or accept ~= nil then
        local attributes = {}
        local label = "<" .. u.id
        if start ~= nil then
          attributes.style = "filled"
          attributes.fontcolor = "white"
          attributes.fillcolor = "black"
          label = label .. " / " .. start
        end
        if accept ~= nil then
          attributes.peripheries = 2
          label = label .. " / " .. accept
        end
        attributes.label = label .. ">"
        return attributes
      end
    end;
    edge_attributes = function (self, e)
      local condition = e.condition
      if condition ~= nil then
        if condition:test(256) then
          return {
            label = "<^>";
          }
        elseif condition:test(257) then
          return {
            label = "<$>";
          }
        else
          local out = sequence_writer()
          out:write("[")
          local count = 0
          for range in condition:ranges():each() do
            count = count + 1
            if count > 1 then
              out:write(",")
            end
            local a, b = range[1], range[2]
            if a == b then
              -- out:write(escape_range_char(a))
              out:write(a)
            elseif a == b - 1 then
              out:write(a, b)
            else
              out:write(a, "-", b)
            end
          end
          out:write("]")
          return {
            label = "<" .. xml.escape(out:concat(), "%W") .. ">";
          }
        end
      end
    end;
  })
end
