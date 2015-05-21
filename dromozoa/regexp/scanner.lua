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

local template = require "dromozoa.regexp.template"

local loadstring = loadstring or load

local tmpl = assert(loadstring(template[====[
[% local function params() %]
b1[% for i = 2, n do %], b[%= i %][% end %]
[% end %]
[% local function cs(i) %]
[% if i % 2 == 1 then %]sa[% else %]sb[% end %]
[% end %]
[% local function ns(i) %]
[% if i % 2 == 1 then %]sb[% else %]sa[% end %]
[% end %]
[% local function generate_action(i, indent) %]
[% out:add(indent) %]
action = actions[token]
a = b + 1
b = i[% if i < 2 then %] - [%= 2 - i %][% elseif i > 2 then %] + [%= i - 2 %][% end +%]
if action > -2 then
  n = n + 1
  tokens[n] = token
  begins[n] = a
  ends[n] = b
  if action > -1 then
    if action == 0 then
      data = stack[m]
      m = m - 1
    else
      m = m + 1
      stack[m] = data
      data = dataset[action]
    end
    start = data.start
    accepts = data.accepts
    transitions = data.transitions
    end_assertions = data.end_assertions
  end
end
[% out:sub(indent) %]
[% end %]
[% local function generate_transition(x, y, z) %]
[% >> %]
if b[%= y %] then
[% for i = x, y do %]
  [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
  if not [% ns(i) %] then
    token = accepts[[%= cs(i) %]]
    if token then
[% generate_action(i, 3) %]
      [% ns(i) %] = transitions[start * 256 + b[%= i %]]
      if not [% ns(i) %] then
        error("scanner error at position " .. (b + 1))
      end
    else
      error("scanner error at position " .. (b + 1))
    end
  end
[% end %]
[% if y < z then %]
[% generate_transition(y + 1, math.floor((y + z + 1) / 2), z) %]
[% end %]
else
[% if x < y then %]
[% generate_transition(x, math.floor((x + y) / 2), y - 1) %]
[% end %]
  [% ns(y) %] = end_assertions[[% cs(y) %]]
  if [% ns(y) %] then
    token = accepts[[%= ns(y) %]]
  else
    token = accepts[[%= cs(y) %]]
  end
  if token then
[% generate_action(y, 2) %]
    return tokens, begins, ends
  else
    error("scanner error at eof")
  end
end
[% << %]
[% end %]
local string_byte = string.byte

return function (dataset, actions, s, i, j)
  if not i then i = 1 end
  if not j then j = #s end

  local data = dataset[1]
  local start = data.start
  local accepts = data.accepts
  local transitions = data.transitions
  local end_assertions = data.end_assertions

  local sa = start
  local sb
  local token
  local action
  local a
  local b = 0
  local m = 0
  local n = 0

  local tokens = {}
  local begins = {}
  local ends = {}
  local stack = {}

  for i = i, j - [%= n - 1 %], [%= n %] do
    local [% params() %] = string_byte(s, i, i + [%= n - 1 %])
[% for i = 1, n do %]
    [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
    if not [% ns(i) %] then
      token = accepts[[%= cs(i) %]]
      if token then
[% generate_action(i, 4) %]
        [% ns(i) %] = transitions[start * 256 + b[%= i %]]
        if not [% ns(i) %] then
          error("scanner error at position " .. (b + 1))
        end
      else
        error("scanner error at position " .. (b + 1))
      end
    end
[% end %]
  end

  local i = j + 1 - (j + 1 - i) % [%= n +%]
  local [% params() %] = string_byte(s, i, j)
[% generate_transition(1, math.floor(n / 2), n) %]
end
]====]))()

return {
  SKIP = -2;
  PUSH = -1;
  RETURN = 0;
  CALL = function (i) return i end;

  generate = function (n, out)
    return tmpl({ n = n }, out)
  end;
}
