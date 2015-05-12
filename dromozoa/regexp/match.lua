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
  local vars = "b01"
  for i = 2, n do
    vars = vars .. string.format(", b%02d", i)
  end

  local buffer = string.format([[
local string_byte = string.byte

return function (code, s, m, n)
  if not m then m = 1 end
  if not n then n = #s end

  local sa = code.start
  local sb
  local nonaccept_max = code.nonaccept_max
  local accept_tokens = code.accept_tokens
  local transitions = code.transitions

  for i = m + %d, n, %d do
    local %s = string_byte(s, i - %d, i)
]], n - 1, n, vars, n - 1)

  for i = 1, n do
    local s
    local n
    local j = string.format(" - %d", 5 - i)
    if i % 2 == 1 then
      s = "sa"
      n = "sb"
    else
      s = "sb"
      n = "sa"
    end

    buffer = buffer .. string.format([[
    ]]..n..[[ = transitions[]]..s..[[ * 257 + b%02d]
    if not ]]..n..[[ then if ]]..s..[[ > nonaccept_max then return accept_tokens[]]..s..[[ - nonaccept_max], i]]..j..[[ else return end end
]], i)
  end

  buffer = buffer .. string.format([[
  end
  local i = n + 1 - (n - m + 1) %% %d
  local %s = string_byte(s, i, n)
]], n, vars)

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
      j = string.format(" + %d", i - 2)
    end

    buffer = buffer .. string.format([[
  if b%02d then
    ]]..n..[[ = transitions[]]..s..[[ * 257 + b%02d]
  else
    ]]..n..[[ = transitions[]]..s..[[ * 257 + 256]
  end
  if not ]]..n..[[ then if ]]..s..[[ > nonaccept_max then return accept_tokens[]]..s..[[ - nonaccept_max], i]]..j..[[ else return end end
]], i, i)
  end

  buffer = buffer .. [[
  sb = transitions[sa * 257 + 256]
  if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 3 else return end end
end
]]

  return buffer
end

-- print(generate(4))
return assert(loadstring(generate(64)))()

--[====[
local string_byte = string.byte

return function (code, s, m, n)
  if not m then m = 1 end
  if not n then n = #s end

  local sa = code.start
  local sb
  local nonaccept_max = code.nonaccept_max
  local accept_tokens = code.accept_tokens
  local transitions = code.transitions

  -- 1,1  n=1  0 1,0    x=1   4,-3
  -- 1,2  n=2  0 1,0    x=1   4,-3
  -- 1,3  n=3  0 1,0    x=1   4,-3
  -- 1,4  n=4  1 1,1-3  x=5   4,4-7
  -- 1,5  n=5  1 1,1-3  x=5   4,4-7
  -- 1,6  n=6  1 1,1-3  x=5   4,4-7
  -- 1,7  n=7  1 1,1-3  x=5   4,4-7
  -- 1,8  n=8  2 1,4-7  x=9   4,8-11
  -- 1,9  n=9  2 1,4-7  x=9   4,8-11
  -- 1,10 n=10 2 1,4-7  x=9   4,8-11
  -- 1,11 n=11 2 1,4-7  x=9   4,8-11
  -- 1,12 n=12 3 1,8-11 x=13  5,12-15

  for i = m + 3, n, 4 do
    local b01, b02, b03, b04 = string_byte(s, i - 3, i)
    sb = transitions[sa * 257 + b01]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i - 4 else return end end
    sa = transitions[sb * 257 + b02]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i - 3 else return end end
    sb = transitions[sa * 257 + b03]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i - 2 else return end end
    sa = transitions[sb * 257 + b04]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i - 1 else return end end
  end

  local i = n + 1 - (n - m + 1) % 4
  local b01, b02, b03, b04 = string_byte(s, i, n)

  if b01 then
    sb = transitions[sa * 257 + b01]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i - 1 else return end end
  else
    sb = transitions[sa * 257 + 256]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i - 1 else return end end
  end

  if b02 then
    sa = transitions[sb * 257 + b02]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i else return end end
  else
    sa = transitions[sb * 257 + 256]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i else return end end
  end

  if b03 then
    sb = transitions[sa * 257 + b03]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 1 else return end end
  else
    sb = transitions[sa * 257 + 256]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 1 else return end end
  end

  if b04 then
    sa = transitions[sb * 257 + b04]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i + 2 else return end end
  else
    sa = transitions[sb * 257 + 256]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i + 2 else return end end
  end

  sb = transitions[sa * 257 + 256]
  if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 3 else return end end

--[[
  if b02 then
    sb = transitions[sa * 257 + b01]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i - 1 else return end end
    sa = transitions[sb * 257 + b02]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i else return end end
  else
    if b01 then
      sb = transitions[sa * 257 + b01]
      if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i - 1 else return end end
    else
      sb = transitions[sa * 257 + 256]
      if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i - 1 else return end end
    end
    sa = transitions[sb * 257 + 256]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i else return end end
  end

  if b04 then
    sb = transitions[sa * 257 + b03]
    if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 1 else return end end
    sa = transitions[sb * 257 + b04]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i + 2 else return end end
  else
    if b03 then
      sb = transitions[sa * 257 + b03]
      if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 1 else return end end
    else
      sb = transitions[sa * 257 + 256]
      if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 1 else return end end
    end
    sa = transitions[sb * 257 + 256]
    if not sa then if sb > nonaccept_max then return accept_tokens[sb - nonaccept_max], i + 2 else return end end
  end

  sb = transitions[sa * 257 + 256]
  if not sb then if sa > nonaccept_max then return accept_tokens[sa - nonaccept_max], i + 3 else return end end
]]
end
]====]
