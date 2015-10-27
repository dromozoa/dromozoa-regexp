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
local graph = require "dromozoa.graph"
local powerset_construction = require "dromozoa.regexp.automaton.powerset_construction"

local function escape_range_char(byte)
  local char = string.char(byte)
  if char:match("^[%^%-%]]$") then
    return "[" .. char .. "]"
  else
    return char
  end
end

local function reverse(this)
  local that = graph()
  local map = {}
  for a in this:each_vertex() do
    local b = that:create_vertex()
    map[a.id] = b.id
    b.start = a.accept
    b.accept = a.start
  end
  for a in this:each_edge() do
    local b = that:create_edge(map[a.vid], map[a.uid])
    -- not clone
    b.condition = a.condition
  end
  return that
end

local class = {}

function class.new(this)
  return {
    this = this;
  }
end

function class:powerset_construction(token)
  self.this = powerset_construction(self.this, token):apply()
  return self
end

function class:reverse()
  self.this = reverse(self.this)
  return self
end

function class:minimize()
  -- Brzozowski's algorithm
  return self:reverse():powerset_construction():reverse():powerset_construction()
end

function class:write_graphviz(out)
  return self.this:write_graphviz(out, {
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
        if start ~= nil then
          attributes.style = "filled"
          attributes.fontcolor = "white"
          attributes.fillcolor = "black"
        end
        if accept ~= nil then
          attributes.peripheries = 2
          attributes.label = "<" .. u.id .. " / " .. accept .. ">"
        end
        return attributes
      end
    end;
    edge_attributes = function (self, e)
      local condition = e.condition
      if condition ~= nil then
        if condition:test(257) then
          return {
            label = "<^>";
          }
        elseif condition:test(256) then
          return {
            label = "<$>";
          }
        else
          local out = sequence_writer()
          out:write("[")
          for range in condition:ranges():each() do
            local a, b = range[1], range[2]
            if a == b then
              out:write(escape_range_char(a))
            elseif a == b - 1 then
              out:write(escape_range_char(a), escape_range_char(b))
            else
              out:write(escape_range_char(a), "-", escape_range_char(b))
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

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
