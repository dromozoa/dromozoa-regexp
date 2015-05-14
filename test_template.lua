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
local template = require "dromozoa.regexp.template"

local loadstring = loadstring or load

local code = template([[
[% assert(n == 8) %]
[% local function f(i) %]
macro [%= i +%]
[% if i > 1 then f(i - 1) end %]
[% end %]
[% for i = 1, n do %]
repeat ( [%= i %] )
[% end %]
[% f(n) %]
]])

local out = assert(io.open("test-template.lua", "w"))
out:write(code)
out:close()

local tmpl = assert(loadstring(code))()

assert(n == nil)
tmpl({
  n = 8;
}, assert(io.open("test-template.txt", "w"))):close()
assert(n == nil)

local result = assert(loadstring(template([[
[%= "foo" %]
[%= "bar" +%]
[%= "baz" %] [%= "qux" %]
]])))()({}, buffer_writer()):concat()
assert(result == "foobar\nbaz qux")
