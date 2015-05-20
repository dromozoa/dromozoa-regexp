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
local indent_writer = require "dromozoa.regexp.indent_writer"

local out = buffer_writer()
out:write("foo"):write(42)
out:write("bar", "baz")
out:write()
assert(out:concat() == "foo42barbaz")

local out = indent_writer(buffer_writer(), "  ")
out:write("foo\nb")
out:add():write("ar\nb"):sub()
out:write("az\n\n")
out:write("\n\nqux"):flush()
assert(out:flush():concat() == "foo\n  bar\nbaz\n\n\n\nqux")
