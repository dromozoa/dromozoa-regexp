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
        _out:write("(")
        self:visit(a)
        for i = 3, #node do
          _out:write("|")
          self:visit(node[i])
        end
        _out:write(")")
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
      _out:write("^")
    end;

    ["$"] = function (self)
      _out:write("$")
    end;

    ["char"] = function (self, node, a)
      if a:match "^[%^%.%[%$%(%)%|%*%+%?%{%\\]$" then
        _out:write("\\")
      end
      _out:write(a)
    end;

    ["\\"] = function (self, node, a)
      _out:write("\\", a)
    end;

    ["."] = function (self)
      _out:write(".")
    end;

    ["+"] = function (self, node, a)
      self:visit(a)
      _out:write("+")
    end;

    ["*"] = function (self, node, a)
      self:visit(a)
      _out:write("*")
    end;

    ["?"] = function (self, node, a)
      self:visit(a)
      _out:write("?")
    end;

    ["{m"] = function (self, node, a, b)
      self:visit(a)
      _out:write("{", b, "}")
    end;

    ["{m,"] = function (self, node, a, b)
      self:visit(a)
      _out:write("{", b, ",}")
    end;

    ["{m,n"] = function (self, node, a, b, c)
      self:visit(a)
      _out:write("{", b, ",", c, "}")
    end;

    ["["] = function (self, node)
      _out:write("[")
      for i = 2, #node do
        self:visit(node[i])
      end
      _out:write("]")
    end;

    ["[^"] = function (self, node)
      _out:write("[^")
      for i = 2, #node do
        self:visit(node[i])
      end
      _out:write("]")
    end;

    ["[="] = function (self, node, a)
      _out:write("[=", a, "=]")
    end;

    ["[:"] = function (self, node, a)
      _out:write("[:", a, ":]")
    end;

    ["[-"] = function (self, node, a, b)
      self:visit(a)
      _out:write("-")
      self:visit(b)
    end;

    ["[."] = function (self, node, a)
      _out:write("[.", a, ".]")
    end;

    ["[char"] = function (self, node, a)
      if a:match "^[%^%-%]]$" then
        _out:write("[.", a, ".]")
      else
        _out:write(a)
      end
    end;
  }

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
