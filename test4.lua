local write_graphviz = require "dromozoa.regexp.write_graphviz"
local parse = require "dromozoa.regexp.parse"
local decode = require "dromozoa.regexp.decode"
local construct_subset = require "dromozoa.regexp.construct_subset"
local minimize = require "dromozoa.regexp.minimize"

local data = {}
for line in io.lines() do
  data[#data + 1] = line
end
local ere = "(" .. table.concat(data, "|") .. ")"
local nfa = decode(parse(ere))
write_graphviz(nfa, io.open("dict-nfa.dot", "w")):close()
local dfa = minimize(construct_subset(nfa))
write_graphviz(dfa, io.open("dict.dot", "w")):close()
