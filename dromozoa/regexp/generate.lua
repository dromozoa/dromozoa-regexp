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

local tmpl = assert(loadstring(template([====[
local _ = false
return {
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
}
]====])))()

return function (code, out)
  return tmpl({ code = code }, out)
end
