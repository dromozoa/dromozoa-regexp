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

local regexp = require "dromozoa.regexp"
local match = require "dromozoa.regexp.match"
local scan = require "dromozoa.regexp.scan"
local scanner = require "dromozoa.regexp.scanner"

local string_byte = string.byte

local head = regexp("^[0-9]+")
local tail = head:remove_assertions()
local code = head:compile()
local s = string.rep("0123456789", 10)

local codes = { code }
local actions = { scanner.PUSH }

return {
  { "dromozoa.regexp.match", function () match(code, s) end };
  { "dromozoa.regexp.scan", function () scan(codes, actions, s) end };
  { "string.find", function () s:find("^[0-9]+") end };
  { "empty", function () end };
}

