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
    if message then
      error(message .. " at position " .. self._i)
    else
      error("parse at position " .. self._i)
    end
  end

  function self:push(v)
    local s = self._stack
    s[#s + 1] = v
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

  function self:token(pattern)
    local text = self._text
    local a, b, c, d = text:find(pattern, self._i)
    if a and b then
      self._i = b + 1
      if c then
        self:push(c)
        if d then
          self:push(d)
        end
      else
        self:push(text:sub(a, b))
      end
      return true
    else
      return false
    end
  end

  function self:bracket_expression()
    if self:token "^%[" then
      self:pop()
      if self:matching_list() then
        local a = self:pop()
        if not self:token "^%]" then
          self:raise()
        end
        self:pop()
        self:push { "bracket_expression", a }
      elseif self:nonmatching_list() then
        local a = self:pop()
        if not self:token "^%]" then
          self:raise()
        end
        self:pop()
        self:push { "bracket_expression", a }
      else
        self:raise()
      end
      return true
    else
      return false
    end
  end

  function self:matching_list()
    if self:bracket_list() then
      self:push { "matching_list", self:pop() }
      return true
    else
      return false
    end
  end

  function self:nonmatching_list()
    if self:token "^%^" then
      self:pop()
      if not self:bracket_list() then
        self:raise()
      end
      self:push { "nonmatching_list", self:pop() }
      return true
    else
      return false
    end
  end

  function self:bracket_list()
    if self:follow_list() then
      self:push { "bracket_list", self:pop() }
      if self:token "^%-" then
        local b = self:pop()
        local a = self:top()
        a[#a + 1] = b
      end
      return true
    else
      return false
    end
  end

  function self:follow_list()
    if self:expression_term() then
      self:push { "follow_list", self:pop() }
      while self:expression_term() do
        local b = self:pop()
        local a = self:top()
        a[#a + 1] = b
      end
      return true
    else
      return false
    end
  end

  function self:expression_term()
    if self:single_expression() then
      self:push { "expression_term", self:pop() }
    elseif self:range_expression() then
      self:push { "expression_term", self:pop() }
    else
      return false
    end
    return true
  end

  function self:single_expression()
    local i = self._i
    if self:character_class() then
      self:push { "single_expression", self:pop() }
    elseif self:equivalence_class() then
      self:push { "single_expression", self:pop() }
    elseif self:end_range() then
      local a = self:pop()
      if self:token "^%-" then
        self:pop()
        self._i = i
        return false
      end
      self:push { "single_expression", a }
    else
      return false
    end
    return true
  end

  function self:range_expression()
    if self:start_range() then
      local a = self:pop()
      if self:end_range() then
        self:push { "range_expression", a, self:pop() }
      elseif self:token "^%-" then
        self:push { "range_expression", a, self:pop() }
      else
        self:raise()
      end
      return true
    else
      return false
    end
  end

  function self:start_range()
    if self:end_range() then
      local a = self:pop()
      if not self:token "^%-" then
        self:raise "parse error"
      end
      self:pop()
      self:push { "start_range", a }
      return true
    else
      return false
    end
  end

  function self:end_range()
    if self:collating_symbol() then
      self:push { "end_range", self:pop() }
    elseif self:token "^[^%^%-%]]" then
      self:push { "end_range", self:pop() }
    else
      return false
    end
    return true
  end

  function self:collating_symbol()
    if self:token "^%[%.(.)%.%]" then
      self:push { "collating_symbol", self:pop() }
      return true
    elseif self:token "^%[%..-%.%]" then
      self:raise "collating symbol is not supported in the current locale"
    else
      return false
    end
  end

  function self:equivalence_class()
    if self:token "^%[%=.-%=%]" then
      self:raise "equivalence class expression is not supported in the current locale"
    else
      return false
    end
  end

  function self:character_class()
    if self:token "^%[%:(.-)%:%]" then
      local a = self:pop()
      if not class[a] then
        self:raise "character class is not supported in the current locale"
      end
      self:push { "character_class", a }
      return true
    else
      return false
    end
  end

  function self:extended_reg_exp()
    if self:ERE_branch() then
      self:push { "extended_reg_exp", self:pop() }
      while self:token "^%|" do
        self:pop()
        if not self:ERE_branch() then
          self:raise "parse error"
        end
        local b = self:pop()
        local a = self:top()
        a[#a + 1] = b
      end
      return true
    else
      return false
    end
  end

  function self:ERE_branch()
    if self:ERE_expression() then
      self:push { "ERE_branch", self:pop() }
      while self:ERE_expression() do
        local b = self:pop()
        local a = self:top()
        a[#a + 1] = b
      end
      return true
    else
      return false
    end
  end

  function self:ERE_expression()
    if self:one_char_or_coll_elem_ERE() then
      self:push { "ERE_expression", self:pop() }
    elseif self:token "^[%^%$]" then
      self:push { "ERE_expression", self:pop() }
    elseif self:token "^%(" then
      self:pop()
      if not self:extended_reg_exp() then
        self:raise "parse error"
      end
      local a = self:pop()
      if not self:token "^%)" then
        self:raise "parse error"
      end
      self:pop()
      self:push { "ERE_expression", a }
    else
      return false
    end
    if self:ERE_dupl_symbol() then
      local b = self:pop()
      local a = self:pop()
      b[#b + 1] = a
      self:push(b)
    end
    return true
  end

  function self:one_char_or_coll_elem_ERE()
    if self:token "^[^%^%.%[%$%(%)%|%*%+%?%{%\\]" then
      self:push { "one_char_or_coll_elem_ERE", self:pop() }
    elseif self:token "^\\[%^%.%[%$%(%)%|%*%+%?%{%\\]" then
      self:push { "one_char_or_coll_elem_ERE", self:pop() }
    elseif self:token "^%." then
      self:push { "one_char_or_coll_elem_ERE", self:pop() }
    elseif self:bracket_expression() then
      self:push { "one_char_or_coll_elem_ERE", self:pop() }
    else
      return false
    end
    return true
  end

  function self:ERE_dupl_symbol()
    if self:token "^[%*%+%?]" then
      self:push { "ERE_dupl_symbol", self:pop() }
    elseif self:token "^%{(%d+),?%}" then
      self:push { "ERE_dupl_symbol", { m = tonumber(self:pop()) } }
    elseif self:token "^%{(%d+),(%d+)%}" then
      local n = tonumber(self:pop())
      local m = tonumber(self:pop())
      if n < m then
        self:raise "invalid interval expression"
      end
      self:push { "ERE_dupl_symbol", { m = m; n = n } }
    else
      return false
    end
    return true
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
