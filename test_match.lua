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

local dfa = require "dromozoa.regexp.dfa"
local match = require "dromozoa.regexp.match"

-- matcher():match("foobarbaz")
local head = dfa("^[0-9]+")
local tail = head:remove_assertions()
local code = head:compile()

for i = 1, 99 do
  local s = string.rep("0", i)
  local _, j = match(code, s)
  local _, k = s:find("^[0-9]+")
  assert(j == k)
end
