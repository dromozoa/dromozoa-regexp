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

local character_class = require "dromozoa.regexp.character_class"
local unparse_ere = require "dromozoa.regexp.unparse_ere"

local function parser(text)
  local self = {
    _t = text;
    _i = 1;
    _s = {};
  }

  function self:parse()
    if self:extended_reg_exp() then
      if self._i == #self._t + 1 and #self._s == 1 then
        return self:pop()
      else
        self:raise()
      end
    else
      self:raise()
    end
  end

  function self:push(v)
    local s = self._s
    s[#s + 1] = v
    return true
  end

  function self:pop()
    local s = self._s
    local n = #s
    local v = s[n]
    s[n] = nil
    return v
  end

  function self:match(pattern)
    local t = self._t
    local a, b, c, d = text:find("^" .. pattern, self._i)
    if b then
      self._i = b + 1
      if c then
        self:push(c)
        if d then
          self:push(d)
        end
      end
      return true
    end
  end

  function self:raise(message)
    if message then
      error(message .. " at position " .. self._i)
    else
      error("parse error at position " .. self._i)
    end
  end

  function self:extended_reg_exp()
    if self:ERE_branch() then
      local a = { "|", self:pop() }
      while self:match "%|" do
        if self:ERE_branch() then
          a[#a + 1] = self:pop()
        else
          self:raise()
        end
      end
      return self:push(a)
    end
  end

  function self:ERE_branch()
    if self:ERE_expression() then
      local a = { "concat", self:pop() }
      while self:ERE_expression() do
        a[#a + 1] = self:pop()
      end
      return self:push(a)
    end
  end

  function self:ERE_expression()
    if self:one_char_or_coll_elem_ERE_or_grouping() then
      self:ERE_dupl_symbol()
      return true
    elseif self:match "([%^%$])" then
      return self:push { self:pop() }
    end
  end

  function self:one_char_or_coll_elem_ERE_or_grouping()
    if self:match "([^%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return self:push { "char", self:pop() }
    elseif self:match "\\([%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return self:push { "\\", self:pop() }
    elseif self:match "%." then
      return self:push { "." }
    elseif self:bracket_expression() then
      return true
    elseif self:match "%(" then
      if self:extended_reg_exp() then
        if self:match "%)" then
          return true
        else
          self:raise "unmatched parentheses"
        end
      else
        self:raise()
      end
    end
  end

  function self:ERE_dupl_symbol()
    if self:match "([%*%+%?])" then
      local a = self:pop()
      return self:push { a, self:pop() }
    elseif self:match "%{" then
      if self:match "(%d+)}" then
        local m = tonumber(self:pop(), 10)
        return self:push { "{m", self:pop(), m }
      elseif self:match "(%d+),}" then
        local m = tonumber(self:pop())
        return self:push { "{m,", self:pop(), m }
      elseif self:match "(%d+),(%d+)}" then
        local n = tonumber(self:pop(), 10)
        local m = tonumber(self:pop(), 10)
        if m <= n then
          return self:push { "{m,n", self:pop(), m, n }
        else
          self:raise("invalid interval expression {" .. m .. "," .. n .. "}")
        end
      else
        self:raise()
      end
    end
  end

  function self:bracket_expression()
    if self:match "%[" then
      local a = {}
      if self:match "%^" then
        a[1] = "[^"
      else
        a[1] = "["
      end
      if self:expression_term() then
        a[2] = self:pop()
      else
        self:raise()
      end
      while self:expression_term() do
        a[#a + 1] = self:pop()
      end
      if self:match "%-" then
        a[#a + 1] = { "[.", "-" }
      end
      if self:match "%]" then
        return self:push(a)
      else
        self:raise "unmatched brackets"
      end
    end
  end

  function self:expression_term()
    if self:match "%[%=" then
      if self:match "(..-)%=%]" then
        self:raise("equivalence class " .. self:pop() .. " is not supported in the current locale")
      else
        self:raise()
      end
    elseif self:match "%[%:" then
      if self:match "(..-)%:%]" then
        local a = self:pop()
        if character_class[a] then
          return self:push { "[:", a }
        else
          self:raise("character class " .. a .. " is not supported in the current locale")
        end
      else
        self:raise()
      end
    elseif self:end_range() then
      local a = self:pop()
      local i = self._i
      if self:match "%-%]" then
        self._i = i
        return self:push(a)
      elseif self:match "%-%-" then
        if string.byte(a[2]) <= 45 then
          return self:push { "[-", a, { "[.", "-" } }
        else
          self:raise("invalid range expression [" .. unparse_ere(a) .. "--]")
        end
      elseif self:match "%-" then
        if self:end_range() then
          local b = self:pop()
          if string.byte(a[2]) <= string.byte(b[2]) then
            return self:push { "[-", a, b }
          else
            self:raise("invalid range expression [" .. unparse_ere(a) .. "-" .. unparse_ere(b) .. "]")
          end
        else
          self:raise()
        end
      else
        return self:push(a)
      end
    end
  end

  function self:end_range()
    if self:match "%[%." then
      if self:match "(.)%.%]" then
        return self:push { "[.", self:pop() }
      elseif self:match "(..-)%.%]" then
        self:raise("collating symbol " .. self:pop() .. " is not supported in the current locale")
      else
        self:raise()
      end
    elseif self:match "([^%^%-%]])" then
      return self:push { "[char", self:pop() }
    end
  end

  return self
end

return function (text)
  return parser(text):parse()
end
