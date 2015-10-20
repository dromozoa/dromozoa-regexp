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

case x$1 in
  x) lua=lua;;
  *) lua=$1;;
esac

"$lua" test/test_assertions.lua
"$lua" test/test_compile.lua
"$lua" test/test_empty.lua
"$lua" test/test_locale.lua
"$lua" test/test_match.lua
"$lua" test/test_parse.lua
"$lua" test/test_regexp.lua

"$lua" test/test.lua '[a-c]{2,}(abc|abd|acc)'
"$lua" test/test.lua '[^[:alpha:]]{2,}(abc|abd|acc)'
"$lua" test/test.lua '^[a-z]+A*$'

"$lua" test/test_branch.lua 'abb' 'abc'
"$lua" test/test_branch.lua 'else' 'elseif'
"$lua" test/test_branch.lua 'abc' '.{3}'

"$lua" test/test_concat.lua 'ab|bc|cd|e*' '(bc)+'

"$lua" test/test_product_construction.lua '[a-z]{4,4}' 'if|else|elseif|end' intersection
"$lua" test/test_product_construction.lua '[a-z]{4,4}' 'if|else|elseif|end' union
"$lua" test/test_product_construction.lua '[a-z]{4,4}' 'if|else|elseif|end' difference
"$lua" test/test_product_construction.lua '.*$' '.*a$' difference
"$lua" test/test_product_construction.lua '.*\$' '.*a\$' difference
"$lua" test/test_product_construction.lua 'a+$' 'b+$' union
"$lua" test/test_product_construction.lua '[ab]+$' '[bc]+$' intersection

"$lua" test/test_remove_assertions.lua '^abc|d^e$f|ghi$'
"$lua" test/test_remove_assertions.lua '^$'
"$lua" test/test_remove_assertions.lua '^$^$^$^$'
"$lua" test/test_remove_assertions.lua '$^$^$^$^'
"$lua" test/test_remove_assertions.lua '^^^^aaaa$$$$|bbbb$$$$'

"$lua" test/test_set_token.lua '.+'

"$lua" test/test_parser.lua
