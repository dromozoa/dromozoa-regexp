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

local parse = require "dromozoa.regexp.parse"
local unparse = require "dromozoa.regexp.unparse"

print(unparse(parse "^a|b$"))
print(unparse(parse "^(a|b)$"))
print(unparse(parse "^((a|b))$"))
print(unparse(parse "^(((a|b)))$"))
print(unparse(parse "."))
print(unparse(parse "\\."))
print(unparse(parse "a*"))
print(unparse(parse "a+"))
print(unparse(parse "a?"))
print(unparse(parse "a{1}"))
print(unparse(parse "a{1,}"))
print(unparse(parse "a{1,1}"))
print(unparse(parse "a{1,2}"))
print(unparse(parse "[a]"))
print(unparse(parse "[^a]"))
print(unparse(parse "[+]"))
print(unparse(parse "[+-]"))
print(unparse(parse "[+--]"))
print(unparse(parse "[[.^.]]"))
print(unparse(parse "[[.-.]]"))
print(unparse(parse "[[.].]]"))
print(unparse(parse "[[:xdigit:]]"))

local result, message = pcall(parse, "[[.\255.]]")
assert(not result)
assert(message:find("is not supported in the current locale"))

local result, message = pcall(parse, "[[:foo:]]")
assert(not result)
assert(message:find("is not supported in the current locale"))

local result, message = pcall(parse, "[[=foo=]]")
assert(not result)
assert(message:find("is not supported in the current locale"))
