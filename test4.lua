local fsm = require "dromozoa.regexp.fsm"

local dfa = fsm()
dfa:add_edge(1, 2, 1)
dfa:add_edge(1, 3, 2)
dfa:add_edge(3, 4, 1)
dfa:add_edge(4, 5, -1)
dfa:add_start(1)
dfa:add_accept(2)
dfa:add_accept(5)
dfa:write_graphviz(io.stdout)

for v in dfa._graph:each_u_reachable(1, function (v) return v == 1 end) do
  print(v)
end
