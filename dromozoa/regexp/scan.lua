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
      code = stack[m]
      m = m - 1
    else
      m = m + 1
      stack[m] = code
      code = codes[action]
    end
    start = code.start
    accepts = code.accepts
    transitions = code.transitions
    end_assertions = code.end_assertions
  end
end
[% out:sub(indent) %]
[% end %]
local string_byte = string.byte

return function (codes, actions, s, i, j)
  if not i then i = 1 end
  if not j then j = #s end

  local code = codes[1]
  local start = code.start
  local accepts = code.accepts
  local transitions = code.transitions
  local end_assertions = code.end_assertions

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

  for i = i, j, [%= n %] do
    local [% params() %] = string_byte(s, i, i + [%= n - 1 %])
[% for i = 1, n do %]
    if b[%= i %] then
      [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
      if not [% ns(i) %] then
        token = accepts[[%= cs(i) %]]
        if token then
[% generate_action(i, 5) %]
          [% ns(i) %] = transitions[start * 256 + b[%= i %]]
          if not [% ns(i) %] then
            error("scanner error at position " .. (b + 1))
          end
        else
          error("scanner error at position " .. (b + 1))
        end
      end
    else
      [% ns(i) %] = end_assertions[[% cs(i) %]]
      if [% ns(i) %] then
        token = accepts[[%= ns(i) %]]
      else
        token = accepts[[%= cs(i) %]]
      end
      if token then
[% generate_action(i, 4) %]
        break
      else
        error("unexpected eof")
      end
    end
[% end %]
  end
  return tokens, begins, ends
end
]====]))()

tmpl({ n = 4 }, io.stdout)

return assert(loadstring(tmpl({ n = 4 }, buffer_writer()):concat()))()
