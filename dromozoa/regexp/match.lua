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

local tmpl = assert(loadstring(template([====[
[% local function params() %]
b1[% for i = 2, n do %], b[%= i %][% end %]
[% end %]
[% local function cs(i) %]
[% if i % 2 == 1 then %]sa[% else %]sb[% end %]
[% end %]
[% local function ns(i) %]
[% if i % 2 == 1 then %]sb[% else %]sa[% end %]
[% end %]
[% local function transitions(x, y, z) %]
[% >> %]
-- [%= x %], [%= y %], [%= z +%]
if b[%= y %] then
[% for i = x, y do %]
  [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
  if not [% ns(i) %] then
    return accepts[[%= cs(i) %]], i[% if i == 1 then %] - 1[% elseif i > 2 then %] + [%= i - 2 %][% end +%]
  end
[% end %]
[% if y < z then %]
[% transitions(y + 1, math.floor((y + z + 1) / 2), z) %]
[% end %]
-- [%= x %], [%= y %], [%= z +%]
else -- b[%= y +%]
[% if x < y then %]
[% transitions(x, math.floor((x + y) / 2), y - 1) %]
[% end %]
  [% ns(y) %] = end_assertions[[% cs(y) %]]
  if not [% ns(y) %] then
    return accepts[[%= cs(y) %]], i[% if y == 1 then %] - 1[% elseif y > 2 then %] + [%= y - 2 %][% end +%]
  end
end -- b[%= y +%]
[% << %]
[% end %]
local string_byte = string.byte

return function (code, s, i, j)
  if not i then i = 1 end
  if not j then j = #s end

  local sa = code.start
  local sb
  local accepts = code.accepts
  local transitions = code.transitions
  local end_assertions = code.end_assertions

  for i = i + [%= n - 1 %], j, [%= n %] do
    local [% params() %] = string_byte(s, i - [%= n - 1 %], i)
[% for i = 1, n do %]
    [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
    if not [% ns(i) %] then
      return accepts[[% cs(i) %]], i - [%= n - i + 1 +%]
    end
[% end %]
  end

  local i = j + 1 - (j + 1 - i) % [%= n +%]
  local [% params() %] = string_byte(s, i, j)
[% transitions(1, n // 2, n) %]
end
]====])))()

tmpl({ n = 8 }, io.stdout)

return assert(loadstring(tmpl({ n = 64 }, buffer_writer()):concat()))()
