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

  local cs = code.start
  local ns
  local accept_offset = code.accept_min - 1
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
    buffer = buffer .. string.format([[
    if b%02d then
      ns = transitions[cs * 257 + b%02d + 1]
    else
      ns = transitions[cs * 257 + 257]
    end
    if ns == 0 then
      if cs > accept_offset then
        return accept_tokens[cs - accept_offset], i - 1
      else
        return
      end
    end
    i = i + 1
    cs = ns
]], i, i)
  end

  buffer = buffer .. [[
  end
end
]]

  return buffer
end

return assert(loadstring(generate(32)))()

--[====[
local string_byte = string.byte

return function (code, s, i, j)
  if not i then i = 1 end
  if not j then j = #s end

  local cs = code.start
  local ns
  local accept_offset = code.accept_min - 1
  local accept_tokens = code.accept_tokens
  local transitions = code.transitions

  while true do
    local k = i
    if k > j then k = j end

    local b01 = string_byte(s, i, k)
    if b01 then
      ns = transitions[cs * 257 + b01 + 1]
    else
      ns = transitions[cs * 257 + 257]
    end
    if ns == 0 then
      if cs > accept_offset then
        return accept_tokens[cs - accept_offset], i - 1
      else
        return
      end
    end
    i = i + 1
    cs = ns
  end
end
]====]
