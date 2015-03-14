local json = require "dromozoa.json"
local buffer_writer = require "dromozoa.regexp.buffer_writer"
local ere_parser = require "dromozoa.regexp.ere_parser"
local ere_unparser = require "dromozoa.regexp.ere_unparser"
local dot_exporter = require "dromozoa.regexp.dot_exporter"
local nfa_builder = require "dromozoa.regexp.nfa_builder"
local dfa_builder = require "dromozoa.regexp.dfa_builder"

local p = ere_parser()
local a = p:parse(arg[1])
local nfa = nfa_builder():build(a)
-- print(json.encode(nfa))
dot_exporter(io.stdout):export(nfa)
-- local dfa = dfa_builder():build(nfa)
-- print(json.encode(dfa))
-- dot_writer(io.stdout):nfa(dfa)
