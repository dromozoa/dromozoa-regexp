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

local buffer = require "dromozoa.regexp.buffer"
local ere_parser = require "dromozoa.regexp.ere_parser"
local ere_unparser = require "dromozoa.regexp.ere_unparser"

return {
  ere_to_ast = function (text)
    local this = ere_parser()
    local a, b = pcall(this.parse, this, text)
    if a then
      return b
    else
      return nil, b
    end
  end;

  ast_to_ere = function (node)
    local this = ere_unparser()
    local a, b = pcall(this.unparse, this, node, buffer())
    if a then
      return b:close()()
    else
      return nil, b
    end
  end;
}
