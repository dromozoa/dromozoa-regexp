local json = require "dromozoa.json"
local ere_parser = require "dromozoa.regexp.ere_parser"
local nfa_builder = require "dromozoa.regexp.nfa_builder"

local ast = ere_parser():parse(arg[1])
local nfa = nfa_builder():build(ast)
local dfa = nfa:build_powerset()
dfa:remove_assertion()
dfa:write_graphviz(io.stdout)
-- print(json.encode(nfa))
