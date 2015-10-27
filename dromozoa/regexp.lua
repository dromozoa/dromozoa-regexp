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

local matcher = require "dromozoa.commons.matcher"
local ast_to_nfa = require "dromozoa.regexp.ast_to_nfa"
local automaton = require "dromozoa.regexp.automaton"
local ere_parser = require "dromozoa.regexp.ere_parser"

local class = {}

function class.ere(this)
  local ast = ere_parser(this):apply()
  local nfa = ast_to_nfa():apply(ast)
  return automaton(nfa)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, regexp)
    return setmetatable(class.new(regexp), metatable)
  end;
})
