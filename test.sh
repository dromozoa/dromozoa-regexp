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
lua test_dfa.lua
lua test_compile.lua

lua test.lua '[a-c]{2,}(abc|abd|acc)'
lua test.lua '[^[:alpha:]]{2,}(abc|abd|acc)'
lua test.lua '^[a-z]+A*$'

lua test_set_token.lua '.+'

lua test_concat.lua 'ab|bc|cd|e*' '(bc)+'

lua test_branch.lua 'abb' 'abc'
lua test_branch.lua 'else' 'elseif'
lua test_branch.lua 'abc' '.{3}'

lua test_product.lua '[a-z]{4,4}' 'if|else|elseif|end' intersection
lua test_product.lua '[a-z]{4,4}' 'if|else|elseif|end' union
lua test_product.lua '[a-z]{4,4}' 'if|else|elseif|end' difference

lua test_remove_assertions.lua '^abc|d^e$f|ghi$'
lua test_remove_assertions.lua '^$'
lua test_remove_assertions.lua '^$^$^$^$'
lua test_remove_assertions.lua '$^$^$^$^'
lua test_remove_assertions.lua '^^^^aaaa$$$$|bbbb$$$$'
