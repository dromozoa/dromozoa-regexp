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

return function (data, s, i, j)
  local min, max = translate_range(#s, i, j)

  local accepts = data.accepts
  local transitions = data.transitions
  local end_assertions = data.end_assertions

  local sa = data.start
  for i = min + 3, max, 4 do
    local a, b, c, d = string.byte(s, i - 3, i)
    local sd = transitions[sa * 256 + a]
    if not sd then
      return accepts[sa], i - 4
    end
    local sc = transitions[sd * 256 + b]
    if not sc then
      return accepts[sd], i - 3
    end
    local sb = transitions[sc * 256 + c]
    if not sb then
      return accepts[sc], i - 2
    end
    sa = transitions[sb * 256 + d]
    if not sa then
      return accepts[sb], i - 1
    end
  end

  local i = max + 1
  local m = i - (i - min) % 4
  if m < i then
    local a, b, c = string.byte(s, m, max)
    local sb
    if c then
      local sd = transitions[sa * 256 + a]
      if not sd then
        return accepts[sa], i - 4
      end
      local sc = transitions[sd * 256 + b]
      if not sc then
        return accepts[sd], i - 3
      end
      sb = transitions[sc * 256 + c]
      if not sb then
        return accepts[sc], i - 2
      end
    elseif b then
      local sc = transitions[sa * 256 + a]
      if not sc then
        return accepts[sa], i - 3
      end
      sb = transitions[sc * 256 + b]
      if not sb then
        return accepts[sc], i - 2
      end
    else
      sb = transitions[sa * 256 + a]
      if not sb then
        return accepts[sa], i - 2
      end
    end
    sa = end_assertions[sb]
    if sa then
      return accepts[sa], i - 1
    else
      return accepts[sb], i - 1
    end
  else
    local sb = end_assertions[sa]
    if sb then
      return accepts[sb], i - 1
    else
      return accepts[sa], i - 1
    end
  end
end
