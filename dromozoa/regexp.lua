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

local translate_range = require "dromozoa.commons.translate_range"
local automaton = require "dromozoa.regexp.automaton"
local match = require "dromozoa.regexp.match"
local syntax_tree = require "dromozoa.regexp.syntax_tree"

local class = {
  automaton = automaton;
  syntax_tree = syntax_tree;
}

function class.ere(this, token)
  return syntax_tree.ere(this, token):normalize():node_to_condition():to_nfa():normalize_assertions():optimize()
end

function class.match(data, s, i, j)
  local min, max = translate_range(#s, i, j)
  local start = data.start_assertion
  if start == 0 then
    start = data.start
  end
  local token, j = match(data, start, s, min, max)
  if token ~= 0 then
    return token, j
  end
end

function class.find(data, s, i, j)
  local min, max = translate_range(#s, i, j)
  local start = data.start_assertion
  if start == 0 then
    start = data.start
  end
  local token, j = match(data, start, s, min, max)
  if token ~= 0 then
    return min, j, token
  end
  local start = data.start
  if start ~= 0 then
    for i = min + 1, max + 1 do
      local token, j = match(data, start, s, i, max)
      if token ~= 0 then
        return i, j, token
      end
    end
  end
end

automaton.super = class
syntax_tree.super = class

return class
