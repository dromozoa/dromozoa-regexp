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
local string_byte = string.byte

local _ = false

local codes = {
[% for i = 1, #codes do %]
[% local code = codes[i] %]
  {
    start = [%= code.start %];
    accepts = {
      [% for i = 1, #code.accepts do %]
[% local v = code.accepts[i] %]
[% if v then %][%= v %],[% else %]_,[% end %]
[% end +%]
    };
    transitions = {
      [% for i = 1, 255 do %]_,[% end %]
[% for i = 256, #code.transitions do %]
[% local v = code.transitions[i] %]
[% if i % 256 == 0 then +%]
      [% end %]
[% if v then %][%= v %],[% else %]_,[% end %]
[% end +%]
    };
    end_assertions = {
      [% for i = 1, #code.end_assertions do %]
[% local v = code.end_assertions[i] %]
[% if v then %][%= v %],[% else %]_,[% end %]
[% end +%]
    };
  };
[% end %]
}

local actions = {
  [% for i = 1, #actions do %]
[% local v = actions[i] %]
[% if v then %][%= v %],[% else %]_,[% end %]
[% end +%]
}

return function (s, i, j)
  if not i then i = 1 end
  if not j then j = #s end

  local code_stack = {}
  local token_stack = {}
  local state_stack = {}

  local code = codes[1]
  local sa = code.start
  local sb
  local accepts = code.accepts
  local transitions = code.transitions
  local end_assertions = code.end_assertions
  local _token
  local _i
  local _j = 0
  local action

  for i = i, #s, [%= n %] do
    local [% params() %] = string_byte(s, i, i + [%= n - 1 %])
[% for i = 1, n do %]
    if b[%= i %] then
      [% ns(i) %] = transitions[[% cs(i) %] * 256 + b[%= i %]]
      if not [% ns(i) %] then
        _token = accepts[[%= cs(i) %]]
        _i = _j + 1
        _j = i[% if i < 2 then %] - [%= 2 - i %][% elseif i > 2 then %] + [%= i - 2 %][% end +%]
        action = actions[_token]
        if action == -2 then
          token_stack[#token_stack + 1] = { _token, _i, _j, s:sub(_i, _j) }
          [% ns(i) %] = transitions[code.start * 256 + b[%= i %]]
        elseif action == -1 then
          [% ns(i) %] = transitions[code.start * 256 + b[%= i %]]
        elseif action == 0 then
          token_stack[#token_stack + 1] = { _token, _i, _j, s:sub(_i, _j) }
          code = code_stack[#code_stack]
          code_stack[#code_stack] = nil
          accepts = code.accepts
          transitions = code.transitions
          end_assertions = code.end_assertions
          [% ns(i) %] = transitions[code.start * 256 + b[%= i %]]
        else
          token_stack[#token_stack + 1] = { _token, _i, _j, s:sub(_i, _j) }
          code_stack[#code_stack + 1] = code
          code = codes[action]
          accepts = code.accepts
          transitions = code.transitions
          end_assertions = code.end_assertions
          [% ns(i) %] = transitions[code.start * 256 + b[%= i %]]
        end
      end
    else
      [% ns(i) %] = end_assertions[[% cs(i) %]]
      if [% ns(i) %] then
        _token = accepts[[%= ns(i) %]]
        _i = _j + 1
        _j = i[% if i < 2 then %] - [%= 2 - i %][% elseif i > 2 then %] + [%= i - 2 %][% end +%]
        token_stack[#token_stack + 1] = { _token, _i, _j, s:sub(_i, _j) }
      else
        _token = accepts[[%= cs(i) %]]
        _i = _j + 1
        _j = i[% if i < 2 then %] - [%= 2 - i %][% elseif i > 2 then %] + [%= i - 2 %][% end +%]
        token_stack[#token_stack + 1] = { _token, _i, _j, s:sub(_i, _j) }
      end
      break
    end
[% end %]
  end

  return token_stack
end
]====]))()

return {
  IGNORE = -2;
  PUSH = -1;
  RETURN = 0;
  CALL = function (i)
    return i
  end;
  generate = function (codes, actions, out)
    return tmpl({ codes = codes, actions = actions, n = 32 }, out)
  end;
}
