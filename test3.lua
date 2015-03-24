local json = require "dromozoa.json"
local write_graphviz = require "dromozoa.regexp.write_graphviz"
local parse_ere = require "dromozoa.regexp.parse_ere"
local unparse_ere = require "dromozoa.regexp.unparse_ere"
local create_nfa = require "dromozoa.regexp.create_nfa"
local create_dfa = require "dromozoa.regexp.create_dfa"
local graph = require "dromozoa.graph"
local minimize_dfa = require "dromozoa.regexp.minimize_dfa"

local ast = parse_ere(arg[1])
-- print(json.encode(ast))
-- print(unparse_ere(ast))
local nfa = create_nfa(ast)
write_graphviz(nfa, io.open("test-nfa.dot", "w")):close()
local dfa = create_dfa(nfa)
write_graphviz(dfa, io.open("test-dfa1.dot", "w")):close()

local mdfa = minimize_dfa(dfa)
write_graphviz(mdfa, io.open("test-dfa2.dot", "w")):close()


-- local ast = ere_parser():parse(arg[1])
-- local nfa = nfa_builder():build(ast)

-- local dfa = nfa:build_powerset()
-- dfa:remove_assertion()
-- dfa:write_graphviz(io.stdout)
-- print(json.encode(nfa))
