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

local loadstring = loadstring or load

local function generate_params(format, n)
  local buffer = {}
  for i = 1, n do
    buffer[i] = string.format(format, i)
  end
  return table.concat(buffer, ", ")
end

local function generate(n)
  local params = generate_params("b%02d", n)

  local buffer = string.gsub([[
local string_byte = string.byte

return function (code, s, m, n)
  if not m then m = 1 end
  if not n then n = #s end

  local sa = code.start
  local sb
  local nonaccept_max = code.nonaccept_max
  local accept_tokens = code.accept_tokens
  local transitions = code.transitions

  for i = m + {:m:}, n, {:n:} do
    local {:params:} = string_byte(s, i - {:m:}, i)
]], "{:(.-):}", {
    m = n - 1;
    n = n;
    params = params;
  })

  for i = 1, n do
    buffer = buffer .. string.gsub([[
    {:ns:} = transitions[{:cs:} * 257 + {:b:}]
    if not {:ns:} then
      if {:cs:} > nonaccept_max then
        return accept_tokens[{:cs:} - nonaccept_max], i - {:m:}
      else
        return
      end
    end
]], "{:(.-):}", {
      cs = i % 2 == 1 and "sa" or "sb";
      ns = i % 2 == 1 and "sb" or "sa";
      b = string.format("b%02d", i);
      m = n - i + 1
    })
  end

  buffer = buffer .. string.gsub([[
  end
  local i = n + 1 - (n - m + 1) % {:n:}
  local {:params:} = string_byte(s, i, n)
]], "{:(.-):}", {
    n = n;
    params = params;
  })

  for i = 1, n do
    local m = ""
    if i == 1 then
      m = " - 1"
    elseif i > 2 then
      m = string.format(" + %d", i - 2)
    end

    buffer = buffer .. string.gsub([[
  if {:b:} then
    {:ns:} = transitions[{:cs:} * 257 + {:b:}]
    if not {:ns:} then
      if {:cs:} > nonaccept_max then
        return accept_tokens[{:cs:} - nonaccept_max], i{:m:}
      else
        return
      end
    end
  else
    {:ns:} = transitions[{:cs:} * 257 + 256]
    if not {:ns:} then
      if {:cs:} > nonaccept_max then
        return accept_tokens[{:cs:} - nonaccept_max], i{:m:}
      else
        return
      end
    end
  end
]], "{:(.-):}", {
      cs = i % 2 == 1 and "sa" or "sb";
      ns = i % 2 == 1 and "sb" or "sa";
      b = string.format("b%02d", i);
      m = m
    })
  end

  buffer = buffer .. string.gsub([[
  sb = transitions[sa * 257 + 256]
  if not sb then
    if sa > nonaccept_max then
      return accept_tokens[sa - nonaccept_max], i + {:m:}
    else
      return
    end
  end
end
]], "{:(.-):}", { m = n - 1 })

  return buffer
end

return assert(loadstring(generate(64)))()
