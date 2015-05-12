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

function generate(n)
  local buffer = string.format([[
local string_byte = string.byte

return function (code, s, i, j)
  if not i then i = 1 end
  if not j then j = #s end

  local sa = code.start
  local sb
  local nonaccept_max = code.nonaccept_max
  local accept_tokens = code.accept_tokens
  local transitions = code.transitions

  while true do
    local k = i + %d
    if k > j then k = j end
    local b01]], n - 1)

  for i = 2, n do
    buffer = buffer .. string.format(", b%02d", i)
  end
  buffer = buffer .. [[
 = string_byte(s, i, k)
]]

  for i = 1, n do
    local s
    local n
    local j = ""
    if i % 2 == 1 then
      s = "sa"
      n = "sb"
    else
      s = "sb"
      n = "sa"
    end
    if i == 1 then
      j = " - 1"
    elseif i > 2 then
      j = " + " .. (i - 2)
    end

    buffer = buffer .. string.format([[
    if b%02d then
      ]]..n..[[ = transitions[ ]]..s..[[ * 257 + b%02d]
    else
      ]]..n..[[ = transitions[ ]]..s..[[ * 257 + 256]
    end
    if not ]]..n..[[ then
      if ]]..s..[[ > nonaccept_max then
        return accept_tokens[ ]]..s..[[ - nonaccept_max], i%s
      else
        return
      end
    end
]], i, i, j)
  end

  buffer = buffer .. string.format("i = i + %d\n", n)

  buffer = buffer .. [[
  end
end
]]

  return buffer
end

-- print(generate(4))
--[====[
return assert(loadstring(generate(32)))()
]====]

local string_byte = string.byte

return function (code, s, m, n)
  if not m then m = 1 end
  if not n then n = #s end

  local sa = code.start
  local sb
  local nonaccept_max = code.nonaccept_max
  local accept_tokens = code.accept_tokens
  local transitions = code.transitions

  local x = n - m + 1
  x = x - x % 4

  for i = m, x - 1, 4 do
    local b01, b02, b03, b04 = string_byte(s, i, i + 3)

    sb = transitions[sa * 257 + b01]
    if not sb then
      if sa > nonaccept_max then
        return accept_tokens[sa - nonaccept_max], i - 1
      else
        return
      end
    end

    sa = transitions[sb * 257 + b02]
    if not sa then
      if sb > nonaccept_max then
        return accept_tokens[sb - nonaccept_max], i
      else
        return
      end
    end

    sb = transitions[sa * 257 + b03]
    if not sb then
      if sa > nonaccept_max then
        return accept_tokens[sa - nonaccept_max], i + 1
      else
        return
      end
    end

    sa = transitions[sb * 257 + b04]
    if not sa then
      if sb > nonaccept_max then
        return accept_tokens[sb - nonaccept_max], i + 2
      else
        return
      end
    end
  end

  local i = x
  local b01, b02, b03, b04 = string_byte(s, i, i + 3)

  if b01 then
    sb = transitions[sa * 257 + b01]
  else
    sb = transitions[sa * 257 + 256]
  end
  if not sb then
    if sa > nonaccept_max then
      return accept_tokens[sa - nonaccept_max], i - 1
    else
      return
    end
  end

  if b02 then
    sa = transitions[sb * 257 + b02]
  else
    sa = transitions[sb * 257 + 256]
  end
  if not sa then
    if sb > nonaccept_max then
      return accept_tokens[sb - nonaccept_max], i
    else
      return
    end
  end

  if b03 then
    sb = transitions[sa * 257 + b03]
  else
    sb = transitions[sa * 257 + 256]
  end
  if not sb then
    if sa > nonaccept_max then
      return accept_tokens[sa - nonaccept_max], i + 1
    else
      return
    end
  end

  if b04 then
    sa = transitions[sb * 257 + b04]
  else
    sa = transitions[sb * 257 + 256]
  end
  if not sa then
    if sb > nonaccept_max then
      return accept_tokens[sb - nonaccept_max], i + 2
    else
      return
    end
  end

  sb = transitions[sa * 257 + 256]
  if not sb then
    if sa > nonaccept_max then
      return accept_tokens[sa - nonaccept_max], i + 3
    else
      return
    end
  end
end
