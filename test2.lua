local buffer_writer = require "dromozoa.regexp.buffer_writer"
local ere_parser = require "dromozoa.regexp.ere_parser"
local ere_unparser = require "dromozoa.regexp.ere_unparser"
local dot_writer = require "dromozoa.regexp.dot_writer"
local nfa_builder = require "dromozoa.regexp.nfa_builder"

local p = ere_parser()
local a = p:parse(arg[1])
local nfa = nfa_builder():build(a)
dot_writer(io.stdout):nfa(nfa)
