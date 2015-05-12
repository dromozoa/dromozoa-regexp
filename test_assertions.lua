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
local generate = require "dromozoa.regexp.generate"

local head = dfa("^abc|d^e$f|ghi$")
assert(head:has_start_assertion())
assert(head:has_end_assertion())

local tail = head:remove_assertions()
assert(not head:has_start_assertion())
assert(head:has_end_assertion())
assert(not tail:has_start_assertion())
assert(tail:has_end_assertion())

head:write_graphviz(assert(io.open("test-head.dot", "w"))):close()
tail:write_graphviz(assert(io.open("test-tail.dot", "w"))):close()

generate(head:compile(), assert(io.open("test-head.lua", "w"))):close()
generate(tail:compile(), assert(io.open("test-tail.lua", "w"))):close()

local head = dfa("abc")
assert(not head:has_start_assertion())
assert(not head:has_end_assertion())

local tail = head:remove_assertions()
assert(not head:has_start_assertion())
assert(not head:has_end_assertion())
assert(not tail:has_start_assertion())
assert(not tail:has_end_assertion())

head:write_graphviz(assert(io.open("test-head2.dot", "w"))):close()
tail:write_graphviz(assert(io.open("test-tail2.dot", "w"))):close()

generate(head:compile(), assert(io.open("test-head2.lua", "w"))):close()
generate(tail:compile(), assert(io.open("test-tail2.lua", "w"))):close()

local head = dfa("^abc")
assert(head:has_start_assertion())
assert(not head:has_end_assertion())

local tail = head:remove_assertions()
assert(not head:has_start_assertion())
assert(not head:has_end_assertion())
assert(not tail:has_start_assertion())
assert(not tail:has_end_assertion())

head:write_graphviz(assert(io.open("test-head3.dot", "w"))):close()
tail:write_graphviz(assert(io.open("test-tail3.dot", "w"))):close()

generate(head:compile(), assert(io.open("test-head3.lua", "w"))):close()
assert(tail:empty())
