local json = require "dromozoa.json"

local class = {
  alnum = true;
  alpha = true;
  blank = true;
  cntrl = true;
  digit = true;
  graph = true;
  lower = true;
  print = true;
  punct = true;
  space = true;
  upper = true;
  xdigit = true;
}

local function parser()
  local self = {}

  function self:parse(text)
    self._text = text
    self._i = 1
    self._stack = {}
    if self:extended_reg_exp() and #self._stack == 1 then
      return self:pop()
    end
    print(json.encode(self._stack))
    return nil, "parse error at position " .. self._i
  end

  function self:raise(message)
    print(json.encode(self._stack))
    if message then
      error(message .. " at position " .. self._i)
    else
      error("parse at position " .. self._i)
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

  function self:top()
    local s = self._stack
    return s[#s]
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

  function self:bracket_expression()
    if self:match "%[" then
      if self:matching_list() then
        if not self:match "%]" then
          self:raise()
        end
        return self:push { "bracket_expression", self:pop() }
      end
      if self:nonmatching_list() then
        if not self:match "%]" then
          self:raise()
        end
        return self:push { "bracket_expression", self:pop() }
      end
      self:raise()
    end
  end

  function self:matching_list()
    if self:bracket_list() then
      return self:push { "matching_list", self:pop() }
    end
  end

  function self:nonmatching_list()
    if self:match "%^" then
      if not self:bracket_list() then
        self:raise()
      end
      return self:push { "nonmatching_list", self:pop() }
    end
  end

  function self:bracket_list()
    if self:follow_list() then
      local a = { "bracket_list", self:pop() }
      if self:match "%-" then
        a[#a + 1] = "-"
      end
      return self:push(a)
    end
  end

  function self:follow_list()
    if self:expression_term() then
      local a = { "follow_list", self:pop() }
      while self:expression_term() do
        a[#a + 1] = self:pop()
      end
      return self:push(a)
    end
  end

  function self:expression_term()
    if self:single_expression() then
      return self:push { "expression_term", self:pop() }
    end
    if self:range_expression() then
      return self:push { "expression_term", self:pop() }
    end
  end

  function self:single_expression()
    local i = self._i
    if self:end_range() then
      local a = self:pop()
      if self:match "%-" then
        self._i = i
      else
        return self:push { "single_expression", a }
      end
    end
    if self:character_class() then
      return self:push { "single_expression", self:pop() }
    end
    if self:equivalence_class() then
      return self:push { "single_expression", self:pop() }
    end
  end

  function self:range_expression()
    if self:start_range() then
      local a = self:pop()
      if self:end_range() then
        return self:push { "range_expression", a, self:pop() }
      end
      if self:match "%-" then
        return self:push { "range_expression", a, "-" }
      end
      self:raise()
    end
  end

  function self:start_range()
    if self:end_range() then
      if not self:match "%-" then
        self:raise()
      end
      return self:push { "start_range", self:pop() }
    end
  end

  function self:end_range()
    local i = self._i
    if self:match "([^%^%-%]])" then
      local a = self:pop()
      if a == "[" and self:match "[%.%=%:]" then
        self._i = i
      else
        return self:push { "end_range", a }
      end
    end
    if self:collating_symbol() then
      return self:push { "end_range", self:pop() }
    end
  end

  function self:collating_symbol()
    if self:match "%[%.(.)%.%]" then
      return self:push { "collating_symbol", self:pop() }
    end
    if self:match "%[%..-%.%]" then
      self:raise "collating symbol is not supported in the current locale"
    end
  end

  function self:equivalence_class()
    if self:match "%[%=.-%=%]" then
      self:raise "equivalence class expression is not supported in the current locale"
    end
  end

  function self:character_class()
    if self:match "%[%:(.-)%:%]" then
      local a = self:pop()
      if not class[a] then
        self:raise "character class is not supported in the current locale"
      end
      return self:push { "character_class", a }
    end
  end

  function self:extended_reg_exp()
    if self:ERE_branch() then
      local a = { "extended_reg_exp", self:pop() }
      while self:match "%|" do
        if not self:ERE_branch() then
          self:raise "parse error"
        end
        a[#a + 1] = self:pop()
      end
      return self:push(a)
    end
  end

  function self:ERE_branch()
    if self:ERE_expression() then
      local a = { "ERE_branch", self:pop() }
      while self:ERE_expression() do
        a[#a + 1] = self:pop()
      end
      return self:push(a)
    end
  end

  function self:ERE_expression()
    local a
    if self:one_char_or_coll_elem_ERE() then
      a = { "ERE_expression", self:pop() }
    end
    if self:match "([%^%$])" then
      a = { "ERE_expression", self:pop() }
    end
    if self:match "%(" then
      if not self:extended_reg_exp() then
        self:raise "parse error"
      end
      if not self:match "%)" then
        self:raise "parse error"
      end
      a = { "ERE_expression", self:pop() }
    end
    if a then
      if self:ERE_dupl_symbol() then
        local b = self:pop()
        b[#b + 1] = a
        return self:push(b)
      end
      return self:push(a)
    end
  end

  function self:one_char_or_coll_elem_ERE()
    if self:match "([^%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return self:push { "one_char_or_coll_elem_ERE", self:pop() }
    end
    if self:match "(\\[%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return self:push { "one_char_or_coll_elem_ERE", self:pop() }
    end
    if self:match "%." then
      return self:push { "one_char_or_coll_elem_ERE", "." }
    end
    if self:bracket_expression() then
      return self:push { "one_char_or_coll_elem_ERE", self:pop() }
    end
  end

  function self:ERE_dupl_symbol()
    if self:match "([%*%+%?])" then
      return self:push { "ERE_dupl_symbol", self:pop() }
    end
    if self:match "%{(%d+),?%}" then
      return self:push { "ERE_dupl_symbol", { m = tonumber(self:pop()) } }
    end
    if self:match "%{(%d+),(%d+)%}" then
      local n = tonumber(self:pop())
      local m = tonumber(self:pop())
      if n < m then
        self:raise "invalid interval expression"
      end
      return self:push { "ERE_dupl_symbol", { m = m; n = n } }
    end
  end

  return self
end

function parse(text)
  local p = parser()
  return p:parse(text)
end

local a, b = parse(arg[1])
if a then
  print(json.encode(a))
else
  print(b)
end
