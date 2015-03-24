local json = require "dromozoa.json"
local write_graphviz = require "dromozoa.regexp.write_graphviz"
local parse_ere = require "dromozoa.regexp.parse_ere"
local unparse_ere = require "dromozoa.regexp.unparse_ere"
local create_nfa = require "dromozoa.regexp.create_nfa"
local create_dfa = require "dromozoa.regexp.create_dfa"
local graph = require "dromozoa.graph"

local ast = parse_ere(arg[1])
-- print(json.encode(ast))
-- print(unparse_ere(ast))
local nfa = create_nfa(ast)
write_graphviz(nfa, io.open("test-nfa.dot", "w")):close()
local dfa = create_dfa(nfa)
write_graphviz(dfa, io.open("test-dfa1.dot", "w")):close()

local function reverse_dfa(dfa)
  local reverse_nfa = graph()
  local map = {}
  for u in dfa:each_vertex() do
    local v = reverse_nfa:create_vertex()
    map[u.id] = v.id
    if u.start then
      v.accept = true
    end
    if u.accept then
      v.start = true
    end
  end
  for e in dfa:each_edge() do
    local e2 = reverse_nfa:create_edge(map[e.vid], map[e.uid])
    e2.condition = e.condition
  end
  local reverse_dfa = create_dfa(reverse_nfa)
  return reverse_dfa
end

local rdfa = reverse_dfa(dfa)
write_graphviz(rdfa, io.open("test-dfa2.dot", "w")):close()
local fdfa = reverse_dfa(rdfa)
write_graphviz(fdfa, io.open("test-dfa3.dot", "w")):close()


-- local ast = ere_parser():parse(arg[1])
-- local nfa = nfa_builder():build(ast)

-- local dfa = nfa:build_powerset()
-- dfa:remove_assertion()
-- dfa:write_graphviz(io.stdout)
-- print(json.encode(nfa))
