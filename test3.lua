local json = require "dromozoa.json"
local ere_parser = require "dromozoa.regexp.ere_parser"
local nfa_builder = require "dromozoa.regexp.nfa_builder"
local write_graphviz = require "dromozoa.regexp.write_graphviz"
local parse_ere = require "dromozoa.regexp.parse_ere"

print(json.encode(parse_ere(arg[1])))

-- local ast = ere_parser():parse(arg[1])
-- local nfa = nfa_builder():build(ast)
-- write_graphviz(nfa, io.stdout)

-- local dfa = nfa:build_powerset()
-- dfa:remove_assertion()
-- dfa:write_graphviz(io.stdout)
-- print(json.encode(nfa))
