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

return function ()
  local self = {}

  function self:parse(text)
    self._text = text
    self._i = 1
    self._stack = {}
    if self:extended_reg_exp() then
      local a = self:pop()
      if self._i == #text + 1 and #self._stack == 0 then
        return a
      else
        self:raise()
      end
    else
      self:raise()
    end
  end

  function self:push(v)
    local s = self._stack
    s[#s + 1] = v
    return true
  end

  function self:pop()
    local s = self._stack
    local n = #s
    local v = s[n]
    s[n] = nil
    return v
  end

  function self:match(pattern)
    local text = self._text
    local a, b, c, d = text:find("^" .. pattern, self._i)
    if a and b then
      self._i = b + 1
      if c then
        self:push(c)
        if d then
          self:push(d)
        end
      end
      return true
    else
      return false
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
      local a = { self:pop() }
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
      local a = { self:pop() }
      while self:ERE_expression() do
        a[#a + 1] = self:pop()
      end
      return self:push(a)
    end
  end

  function self:ERE_expression()
    if self:one_char_or_coll_elem_ERE_or_grouping() then
      local a = { self:pop() }
      if self:ERE_dupl_symbol() then
        a[2] = self:pop()
      end
      return self:push(a)
    elseif self:match "([%^%$])" then
      return true
    end
  end

  function self:one_char_or_coll_elem_ERE_or_grouping()
    if self:match "([^%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return true
    elseif self:match "\\([%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return true
    elseif self:match "%." then
      return self:push(-1)
    elseif self:bracket_expression() then
      return true
    elseif self:match "%(" then
      local a = self:pop()
      if self:extended_reg_exp() then
        if self:match "%)" then
          return self:push(a)
        else
          self:raise()
        end
      else
        self:raise()
      end
    end
  end

  function self:ERE_dupl_symbol()
    if self:match "([%*%+%?])" then
      return true
    elseif self:match "%{" then
      if self:match "(%d+)}" then
        local a = tonumber(self:pop(), 10)
        return self:push(a)
      elseif self:match "(%d+),}" then
        local a = tonumber(self:pop())
        return self:push { a }
      elseif self:match "(%d+),(%d+)}" then
        local b = tonumber(self:pop(), 10)
        local a = tonumber(self:pop(), 10)
        if a <= b then
          return self:push { a, b }
        else
          self:raise("invalid interval {" .. a .. "," .. b .. "}")
        end
      else
        self:raise()
      end
    end
  end

  function self:bracket_expression()
    if self:match "%[" then
      local a = { true }
      if self:match "%^" then
        a[1] = false
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
        a[#a + 1] = "-"
      end
      if self:match "%]" then
        return self:push(a)
      else
        self:raise()
      end
    end
  end

  function self:expression_term()
    if self:match "%[%=" then
      if self:match "(..-)%=%]" then
        local a = self:pop()
        self:raise("equivalence class " .. a .. " is not supported in the current locale")
      else
        self:raise()
      end
    elseif self:match "%[%:" then
      if self:match "(..-)%:%]" then
        local a = self:pop()
        local b = character_class[a]
        if b then
          return self:push { a }
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
        if string.byte(a) <= 45 then
          return self:push { a, "-" }
        else
          self:raise("invalid range [" .. a .. "--]")
        end
      elseif self:match "%-" then
        if self:end_range() then
          local b = self:pop()
          if string.byte(a) <= string.byte(b) then
            return self:push { a, b }
          else
            self:raise("invalid range [" .. a .. "-" .. b .. "]")
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
        return true
      elseif self:match "(..-)%.%]" then
        local a = self:pop()
        self:raise("collating symbol " .. a .. " is not supported in the current locale")
      else
        self:raise()
      end
    elseif self:match "([^%^%-%]])" then
      return true
    end
  end

  return self
end