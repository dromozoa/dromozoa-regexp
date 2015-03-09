local buffer_writer = require "dromozoa.regexp.buffer_writer"
local ere_unparser = require "dromozoa.regexp.ere_unparser"

ere_unparser(io.stdout):extended_reg_exp {
  { "^", { "a" }, { "b" }, { { false, { "a", "z" }, { "digit" } } } };
  { "^", { "c", "*" } };
}
io.write("\n")
