#! /bin/sh -e

# Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
#
# This file is part of dromozoa-regexp.
#
# dromozoa-regexp is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dromozoa-regexp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-regexp.  If not, see <http://www.gnu.org/licenses/>.

lua test_bitset.lua
lua test_buffer_writer.lua
lua test_character_class.lua
lua test_empty.lua
lua test_parse.lua
lua test_tree_map.lua

lua test.lua '[a-c]{2,}(abc|abd|acc)'
lua test.lua '[^[:alpha:]]{2,}(abc|abd|acc)'
lua test.lua '^[a-z]+A*$'

lua test_assertion.lua '^abc|d^e$f|ghi$'
