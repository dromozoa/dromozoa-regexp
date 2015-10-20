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

local class = {}

function class.new(out)
  return {
    out = out;
  }
end

function class:discover_node(node)
  local out = self.out
  local tag = node[1]
  if tag == "|" then
    if not node:is_root() then
      out:write("(")
    end
  elseif tag == "^" or tag == "$" or tag == "." then
    out:write(tag)
  elseif tag == "char" or tag == "\\" then
    local char = node[2]
    if char:match("^[%^%.%[%$%(%)%|%*%+%?%{%\\]$") then
      out:write("\\", char)
    else
      out:write(char)
    end
  elseif tag == "[" then
    out:write("[")
    if node[2] then
      out:write("^")
    end
  elseif tag == "[=" then
    out:write("[=", node[2], "=]")
  elseif tag == "[:" then
    out:write("[:", node[2], ":]")
  elseif tag == "[." or tag == "[char" then
    local char = node[2]
    if char:match("^[%^%-%]]$") then
      out:write("[.", char, ".]")
    else
      out:write(char)
    end
  end
end

function class:examine_edge(u, v)
  local out = self.out
  local tag = u[1]
  if tag == "|" then
    if not v:is_first_child() then
      out:write("|")
    end
  elseif tag == "[-" then
    if v:is_last_child() then
      out:write("-")
    end
  end
end

function class:finish_node(node)
  local out = self.out
  local tag = node[1]
  if tag == "|" then
    if not node:is_root() then
      out:write(")")
    end
  elseif tag == "*" or tag == "+" or tag == "?" then
    out:write(tag)
  elseif tag == "{m" then
    out:write("{", node[2], "}")
  elseif tag == "{m," then
    out:write("{", node[2], ",}")
  elseif tag == "{m,n" then
    out:write("{", node[2], ",", node[3], "}")
  elseif tag == "[" then
    out:write("]")
  end
end

function class:unparse(node)
  node:dfs(self)
  return self.out
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, out)
    return setmetatable(class.new(out), metatable)
  end;
})
