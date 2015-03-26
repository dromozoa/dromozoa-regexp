local write_graphviz = require "dromozoa.regexp.write_graphviz"
local parse = require "dromozoa.regexp.parse"
local decode = require "dromozoa.regexp.decode"
local construct_subset = require "dromozoa.regexp.construct_subset"
local graph = require "dromozoa.graph"
local remove_assertion = require "dromozoa.regexp.remove_assertion"
local minimize = require "dromozoa.regexp.minimize"
local compile = require "dromozoa.regexp.compile"
local execute = require "dromozoa.regexp.execute"

local json = require "dromozoa.json"

local ast = parse(arg[1])
-- print(json.encode(ast))
-- print(unparse_ere(ast))
local nfa = decode(ast)
write_graphviz(nfa, io.open("test-nfa.dot", "w")):close()
local dfa = construct_subset(nfa)
write_graphviz(dfa, io.open("test-dfa.dot", "w")):close()

local dfa1, dfa2 = remove_assertion(dfa)

write_graphviz(dfa1, io.open("test-dfa1.dot", "w")):close()
write_graphviz(dfa2, io.open("test-dfa2.dot", "w")):close()

local mdfa1 = minimize(dfa1)
write_graphviz(mdfa1, io.open("test-mdfa1.dot", "w")):close()
local mdfa2 = minimize(dfa2)
write_graphviz(mdfa2, io.open("test-mdfa2.dot", "w")):close()

local P = compile(mdfa1)
-- print(json.encode(P))

print(execute(P, arg[2], 1))
