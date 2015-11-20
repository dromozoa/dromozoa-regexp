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

local locale = require "dromozoa.regexp.locale"

local X = string.byte("X")
local x = string.byte("x")

assert(locale.isupper(X))
assert(locale.islower(x))
assert(locale.toupper(0) == 0)
assert(locale.toupper(X) == X)
assert(locale.toupper(x) == X)
assert(locale.tolower(0) == 0)
assert(locale.tolower(X) == x)
assert(locale.tolower(x) == x)
