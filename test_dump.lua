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

local dump = require "dromozoa.regexp.dump"

dump({
  {
    aaa1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };
    bbb1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };
    ccc1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    ddd1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
  };
  {
    aaa2 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };
    bbb2 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };
    ccc2 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    ddd2 = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
  };
  {
    1, false, 2, false, 3
  };
}, io.stdout)
