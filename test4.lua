local write_graphviz = require "dromozoa.regexp.write_graphviz"
local parse_ere = require "dromozoa.regexp.parse_ere"
local create_nfa = require "dromozoa.regexp.create_nfa"
local construct_subset = require "dromozoa.regexp.construct_subset"
local minimize_dfa = require "dromozoa.regexp.minimize_dfa"

local data = {}
for line in io.lines() do
  data[#data + 1] = line
end
local ere = "(" .. table.concat(data, "|") .. ")"
local nfa = create_nfa(parse_ere(ere))
write_graphviz(nfa, io.open("dict-nfa.dot", "w")):close()
local dfa = minimize_dfa(construct_subset(nfa))
write_graphviz(dfa, io.open("dict.dot", "w")):close()
