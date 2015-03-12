local ere_parser = require "dromozoa.regexp.ere_parser"
local nfa_builder = require "dromozoa.regexp.nfa_builder"

local ast = ere_parser():parse(arg[1])
local nfa = nfa_builder():build(ast)
nfa:write_graphviz(io.stdout)
