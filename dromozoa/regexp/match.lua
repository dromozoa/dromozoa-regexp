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
local string_byte = string.byte

return function (code, s, m, n)
  if not m then m = 1 end
  if not n then n = #s end

  local sa = code.start
  local sb
  local accepts = code.accepts
  local transitions = code.transitions
  local end_assertions = code.end_assertions

  for i = m + [%= n - 1 %], n, [%= n %] do
    local [% params() %] = string_byte(s, i - [%= n - 1 %], i)
[% for i = 1, n do %]
    [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
    if not [% ns(i) %] then
      return accepts[[% cs(i) %]], i - [%= n - i + 1 +%]
    end
[% end %]
  end

  local i = n + 1 - (n - m + 1) % [%= n +%]
  local [% params() %] = string_byte(s, i, n)

if b32 then

[% for i = 1, 32 do %]
  [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
  if not [% ns(i) %] then
    return accepts[[%= cs(i) %]], i[% if i == 1 then %] - 1[% elseif i > 2 then %] + [%= i - 2 %][% end +%]
  end
[% end %]

[% for i = 33, n do %]
  if b[%= i %] then
    [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
  else
    [% ns(i) %] = end_assertions[[% cs(i) %]]
  end
  if not [% ns(i) %] then
    return accepts[[%= cs(i) %]], i[% if i == 1 then %] - 1[% elseif i > 2 then %] + [%= i - 2 %][% end +%]
  end
[% end %]

else

[% for i = 1, 32 do %]
  if b[%= i %] then
    [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
  else
    [% ns(i) %] = end_assertions[[% cs(i) %]]
  end
  if not [% ns(i) %] then
    return accepts[[%= cs(i) %]], i[% if i == 1 then %] - 1[% elseif i > 2 then %] + [%= i - 2 %][% end +%]
  end
[% end %]

end

  sb = transitions[sa]
  if not sb then
    return accepts[sa], i + [%= n - 1 +%]
  end
end

[% local function binary(x, y) %]
  -- [%= x %], [%= y +%]
  if b[%= y %] then
[% for i = x, x + y - 1 do %]
    [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
    if not [% ns(i) %] then
      return accepts[[%= cs(i) %]], i[% if i == 1 then %] - 1[% elseif i > 2 then %] + [%= i - 2 %][% end +%]
    end
[% end %]
  else
[% if y >= 4 then %]
[% binary(x, y / 2) %]
[% binary(x + y / 2, y / 2) %]
[% else %]
[% end %]
  end
[% end %]

--[==[
[% binary(1, 4) %]
]==]
]====])))()

-- tmpl({ n = 8 }, io.stdout)

return assert(loadstring(tmpl({ n = 64 }, buffer_writer()):concat()))()
