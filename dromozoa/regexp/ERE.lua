local json = require "dromozoa.json"

local upper = { { "A", "Z" } }
local lower = { { "a", "z" } }
local digit = { { "0", "9" } }
local space = { { " " }, { "\f" }, { "\n" }, { "\r" }, { "\t" }, { "\v" } }
local xdigit = { { "0", "9" }, { "A", "F" }, { "a", "f" } }

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

--[====[
/* The following tokens are for the Bracket Expression
   grammar common to both REs and EREs. */

%token    COLL_ELEM_SINGLE COLL_ELEM_MULTI META_CHAR

%token    Open_equal Equal_close Open_dot Dot_close Open_colon Colon_close
/*           '[='       '=]'        '[.'     '.]'      '[:'       ':]'  */

%token    class_name
/* class_name is a keyword to the LC_CTYPE locale category */
/* (representing a character class) in the current locale */
/* and is only recognized between [: and :] */

/* --------------------------------------------
   Bracket Expression
   -------------------------------------------
*/
bracket_expression : '[' matching_list ']'
               | '[' nonmatching_list ']'
               ;
matching_list  : bracket_list
               ;
nonmatching_list : '^' bracket_list
               ;
bracket_list   : follow_list
               | follow_list '-'
               ;
follow_list    :             expression_term
               | follow_list expression_term
               ;
expression_term : single_expression
               | range_expression
               ;
single_expression : end_range
               | character_class
               | equivalence_class
               ;
range_expression : start_range end_range
               | start_range '-'
               ;
start_range    : end_range '-'
               ;
end_range      : COLL_ELEM_SINGLE
               | collating_symbol
               ;
collating_symbol : Open_dot COLL_ELEM_SINGLE Dot_close
               | Open_dot COLL_ELEM_MULTI Dot_close
               | Open_dot META_CHAR Dot_close
               ;
equivalence_class : Open_equal COLL_ELEM_SINGLE Equal_close
               | Open_equal COLL_ELEM_MULTI Equal_close
               ;
character_class : Open_colon class_name Colon_close
               ;

%token  ORD_CHAR QUOTED_CHAR DUP_COUNT
%start  extended_reg_exp
%%

/* --------------------------------------------
   Extended Regular Expression
   --------------------------------------------
*/
extended_reg_exp   :                      ERE_branch
                   | extended_reg_exp '|' ERE_branch
                   ;
ERE_branch         :            ERE_expression
                   | ERE_branch ERE_expression
                   ;
ERE_expression     : one_char_or_coll_elem_ERE
                   | '^'
                   | '$'
                   | '(' extended_reg_exp ')'
                   | ERE_expression ERE_dupl_symbol
                   ;
one_char_or_coll_elem_ERE  : ORD_CHAR
                   | QUOTED_CHAR
                   | '.'
                   | bracket_expression
                   ;
ERE_dupl_symbol    : '*'
                   | '+'
                   | '?'
                   | '{' DUP_COUNT               '}'
                   | '{' DUP_COUNT ','           '}'
                   | '{' DUP_COUNT ',' DUP_COUNT '}'
                   ;

COLL_ELEM_SINGLE
  "[^%^%-%]]"

COLL_ELEM_MULTI

META_CHAR
  "[%^%-%]]"





extended_reg_exp {
  ERE_branch+
}

ERE_branch = {
  ERE_expression+
}

ERE_expression = {
  [1] = character (maybe nil)
  [2] = boolean (^)
  [3] = boolean ($)
  [4] = dup (maybe nil)
}

one_char_or_coll_elem_ERE {
  string or array
}

]====]

local function set_metatype(table, metattype)
  local metatable = getmetatable(table) or {}
  metatable.__dromozoa_metatype = metatype
  return setmetatable(table, metatable)
end

local function get_metatype(table)
  local metatable = getmetatable(table)
  if metatable then
    return metatable.__dromozoa_metatype
  else
    return nil
  end
end

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
      table.insert(self:top(), 1, true)
      return true
    end
  end

  function self:nonmatching_list()
    if self:match "%^" then
      if not self:bracket_list() then
        self:raise()
      end
      table.insert(self:top(), 1, false)
      return true
    end
  end

  function self:bracket_list()
    if self:follow_list() then
      local a = self:top()
      -- fixme precedence bug here
      if self:match "%-" then
        a[#a + 1] = "-"
      end
      return true
    end
  end

  function self:follow_list()
    if self:expression_term() then
      local a = { self:pop() }
      while self:expression_term() do
        a[#a + 1] = self:pop()
      end
      return self:push(a)
    end
  end

  function self:expression_term()
    if self:single_expression() then
      return true
    end
    if self:range_expression() then
      return true
    end
  end

  function self:single_expression()
    local i = self._i
    if self:end_range() then
      local a = self:pop()
      if self:match "%-" then
        self._i = i
      else
        return self:push { a }
      end
    end
    if self:character_class() then
      return self:push(set_metatype({ self:pop() }, "character_class"))
    end
    if self:equivalence_class() then
      return self:push(set_metatype({ self:pop() }, "equivalence_class"))
    end
  end

  function self:range_expression()
    if self:start_range() then
      local a = self:pop()
      if self:end_range() then
        return self:push { a, self:pop() }
      end
      if self:match "%-" then
        return self:push { a, "-" }
      end
      self:raise()
    end
  end

  function self:start_range()
    if self:end_range() then
      if not self:match "%-" then
        self:raise()
      end
      return true
    end
  end

  function self:end_range()
    local i = self._i
    if self:match "([^%^%-%]])" then
      if self:top() == "[" and self:match "[%.%=%:]" then
        self:pop()
        self._i = i
      else
        return true
      end
    end
    if self:collating_symbol() then
      return true
    end
  end

  function self:collating_symbol()
    if self:match "%[%.(.)%.%]" then
      return true
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
      if not class[self:top()] then
        self:raise "character class is not supported in the current locale"
      end
      return true
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
        a[#a + 1] = self:pop()
      end
      return self:push(a)
    end
  end

  function self:one_char_or_coll_elem_ERE()
    if self:match "([^%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return true
    end
    if self:match "\\([%^%.%[%$%(%)%|%*%+%?%{%\\])" then
      return true
    end
    if self:match "%." then
      return self:push(set_metatype({ "." }, "any"))
    end
    if self:bracket_expression() then
      return self:push { self:pop() }
    end
  end

  function self:ERE_dupl_symbol()
    if self:match "([%*%+%?])" then
      return self:push { self:pop() }
    end
    if self:match "%{(%d+),?%}" then
      return self:push { tonumber(self:pop()) }
    end
    if self:match "%{(%d+),(%d+)%}" then
      local n = tonumber(self:pop())
      local m = tonumber(self:pop())
      if n < m then
        self:raise "invalid interval expression"
      end
      return self:push { m, n }
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
