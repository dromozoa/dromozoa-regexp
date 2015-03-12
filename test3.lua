local json = require "dromozoa.json"
local fsm = require "dromozoa.regexp.fsm"

local nfa = fsm()
nfa:add_edge(1, 2, 1)
nfa:add_edge(2, 3, -1)
nfa:add_edge(3, 3, 0)
nfa:add_edge(3, 4, 2)
nfa:add_start(1)
nfa:add_accept(4)
nfa:write_graphviz(io.stdout)
