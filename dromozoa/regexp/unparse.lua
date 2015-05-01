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

local function unparser(_out)
  local self = {
    ["|"] = function (self, node, a, b)
      if b then
        self:write("(")
        self:visit(a)
        for i = 3, #node do
          self:write("|")
          self:visit(node[i])
        end
        self:write(")")
      else
        self:visit(a)
      end
    end;

    ["concat"] = function (self, node)
      for i = 2, #node do
        self:visit(node[i])
      end
    end;

    ["^"] = function (self)
      self:write("^")
    end;

    ["$"] = function (self)
      self:write("$")
    end;

    ["char"] = function (self, node, a)
      if a:match "^[%^%.%[%$%(%)%|%*%+%?%{%\\]$" then
        self:write("\\")
      end
      self:write(a)
    end;

    ["\\"] = function (self, node, a)
      self:write("\\", a)
    end;

    ["."] = function (self)
      self:write(".")
    end;

    ["+"] = function (self, node, a)
      self:visit(a)
      self:write("+")
    end;

    ["*"] = function (self, node, a)
      self:visit(a)
      self:write("*")
    end;

    ["?"] = function (self, node, a)
      self:visit(a)
      self:write("?")
    end;

    ["{m"] = function (self, node, a, b)
      self:visit(a)
      self:write("{", b, "}")
    end;

    ["{m,"] = function (self, node, a, b)
      self:visit(a)
      self:write("{", b, ",}")
    end;

    ["{m,n"] = function (self, node, a, b, c)
      self:visit(a)
      self:write("{", b, ",", c, "}")
    end;

    ["["] = function (self, node)
      self:write("[")
      for i = 2, #node do
        self:visit(node[i])
      end
      self:write("]")
    end;

    ["[^"] = function (self, node)
      self:write("[^")
      for i = 2, #node do
        self:visit(node[i])
      end
      self:write("]")
    end;

    ["[="] = function (self, node, a)
      self:write("[=", a, "=]")
    end;

    ["[:"] = function (self, node, a)
      self:write("[:", a, ":]")
    end;

    ["[-"] = function (self, node, a, b)
      self:visit(a)
      self:write("-")
      self:visit(b)
    end;

    ["[."] = function (self, node, a)
      self:write("[.", a, ".]")
    end;

    ["[char"] = function (self, node, a)
      if a:match "^[%^%-%]]$" then
        self:write("[.", a, ".]")
      else
        self:write(a)
      end
    end;
  }

  function self:write(...)
    _out:write(...)
  end

  function self:visit(node)
    self[node[1]](self, node, node[2], node[3], node[4]);
  end

  function self:unparse(node)
    self:visit(node)
    return _out
  end

  return self
end

return function (node)
  return unparser(buffer_writer()):unparse(node):concat()
end
