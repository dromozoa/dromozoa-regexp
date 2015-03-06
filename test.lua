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

local json = require "dromozoa.json"
local regexp = require "dromozoa.regexp"
local character_class = require "dromozoa.regexp.character_class"

local a, b = regexp.ere_to_ast(arg[1])
if a then
  print(json.encode(a))
  -- print(regexp.ast_to_ere(a))
  local a = character_class(a[1][1][1])
  -- print(json.encode(a))
  local b = a:encode()
  -- print(json.encode(b))
  print(regexp.ast_to_ere({{{b}}}))
else
  print(b)
end
