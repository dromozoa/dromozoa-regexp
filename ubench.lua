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

local match = require "dromozoa.regexp.match"

local string_byte = string.byte

local s = string.rep("0123456789", 100)

local function tailcall1(x, s, i, j, n, v, ...)
  if v then
    return tailcall1(x + v, s, i + 1, j, n, ...)
  elseif i <= j then
    return tailcall1(x, s, i, j, n, string_byte(s, i, i + n))
  else
    return x
  end
end

local function generate_loop(n)
  local code = {}
  code[#code + 1] = [[
return function (x, s, i, j)
  local string_byte = string.byte
  while i <= j do
  local r01]]

  for i = 2, n do
    code[#code + 1] = string.format(", r%02d", i)
  end
  code[#code + 1] = string.format(" = string_byte(s, i, i + %d)\n", n - 1)
  for i = 1, n do
    code[#code + 1] = string.format("if r%02d then x = x + r%02d i = i + 1 else break end\n", i, i)
  end
  code[#code + 1] = "end return x end"
  return table.concat(code)
end

local loadstring = loadstring or load

local loop4 = assert(loadstring(generate_loop(4)))()
local loop8 = assert(loadstring(generate_loop(8)))()
local loop12 = assert(loadstring(generate_loop(12)))()
local loop16 = assert(loadstring(generate_loop(16)))()
local loop32 = assert(loadstring(generate_loop(32)))()
local loop48 = assert(loadstring(generate_loop(48)))()
local loop64 = assert(loadstring(generate_loop(64)))()

return {
  { "tailcall/2", function () tailcall1(0, s, 1, #s, 1) end };
  { "tailcall/4", function () tailcall1(0, s, 1, #s, 3) end };
  { "tailcall/6", function () tailcall1(0, s, 1, #s, 5) end };
  { "tailcall/8", function () tailcall1(0, s, 1, #s, 7) end };
  { "tailcall/10", function () tailcall1(0, s, 1, #s, 9) end };
  { "tailcall/12", function () tailcall1(0, s, 1, #s, 11) end };
  { "tailcall/14", function () tailcall1(0, s, 1, #s, 13) end };
  { "tailcall/16", function () tailcall1(0, s, 1, #s, 15) end };
  { "tailcall/18", function () tailcall1(0, s, 1, #s, 17) end };
  { "tailcall/20", function () tailcall1(0, s, 1, #s, 19) end };
  { "tailcall/22", function () tailcall1(0, s, 1, #s, 21) end };
  { "tailcall/24", function () tailcall1(0, s, 1, #s, 23) end };
  { "tailcall/26", function () tailcall1(0, s, 1, #s, 25) end };
  { "tailcall/28", function () tailcall1(0, s, 1, #s, 27) end };
  { "tailcall/30", function () tailcall1(0, s, 1, #s, 29) end };
  { "tailcall/32", function () tailcall1(0, s, 1, #s, 31) end };
  { "loop/4", function () loop4(0, s, 1, #s) end };
  { "loop/8", function () loop8(0, s, 1, #s) end };
  { "loop/12", function () loop12(0, s, 1, #s) end };
  { "loop/16", function () loop16(0, s, 1, #s) end };
  { "loop/32", function () loop32(0, s, 1, #s) end };
  { "loop/48", function () loop48(0, s, 1, #s) end };
  { "loop/64", function () loop64(0, s, 1, #s) end };
}
