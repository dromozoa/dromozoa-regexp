package = "dromozoa-regexp"
version = "1.1-1"
source = {
  url = "https://github.com/dromozoa/dromozoa-regexp/archive/v1.1.tar.gz";
  file = "dromozoa-regexp-1.1.tar.gz";
}
description = {
  summary = "Regular expressions toolkit";
  license = "GPL-3";
  homepage = "https://github.com/dromozoa/dromozoa-regexp/";
  maintainer = "Tomoyuki Fujimori <moyu@dromozoa.com>";
}
dependencies = {
  "dromozoa-commons";
  "dromozoa-graph";
  "dromozoa-tree";
}
build = {
  type = "builtin";
  modules = {
    ["dromozoa.regexp"] = "dromozoa/regexp.lua";
    ["dromozoa.regexp.bitset"] = "dromozoa/regexp/bitset.lua";
    ["dromozoa.regexp.bitset_to_node"] = "dromozoa/regexp/bitset_to_node.lua";
    ["dromozoa.regexp.branch"] = "dromozoa/regexp/branch.lua";
    ["dromozoa.regexp.buffer_writer"] = "dromozoa/regexp/buffer_writer.lua";
    ["dromozoa.regexp.character_class"] = "dromozoa/regexp/character_class.lua";
    ["dromozoa.regexp.character_range"] = "dromozoa/regexp/character_range.lua";
    ["dromozoa.regexp.compile"] = "dromozoa/regexp/compile.lua";
    ["dromozoa.regexp.concat"] = "dromozoa/regexp/concat.lua";
    ["dromozoa.regexp.decompile"] = "dromozoa/regexp/decompile.lua";
    ["dromozoa.regexp.dump"] = "dromozoa/regexp/dump.lua";
    ["dromozoa.regexp.has_assertion"] = "dromozoa/regexp/has_assertion.lua";
    ["dromozoa.regexp.indent_writer"] = "dromozoa/regexp/indent_writer.lua";
    ["dromozoa.regexp.match"] = "dromozoa/regexp/match.lua";
    ["dromozoa.regexp.matcher"] = "dromozoa/regexp/matcher.lua";
    ["dromozoa.regexp.merge"] = "dromozoa/regexp/merge.lua";
    ["dromozoa.regexp.minimize"] = "dromozoa/regexp/minimize.lua";
    ["dromozoa.regexp.node_to_bitset"] = "dromozoa/regexp/node_to_bitset.lua";
    ["dromozoa.regexp.node_to_nfa"] = "dromozoa/regexp/node_to_nfa.lua";
    ["dromozoa.regexp.parse"] = "dromozoa/regexp/parse.lua";
    ["dromozoa.regexp.powerset_construction"] = "dromozoa/regexp/powerset_construction.lua";
    ["dromozoa.regexp.product_construction"] = "dromozoa/regexp/product_construction.lua";
    ["dromozoa.regexp.remove_assertions"] = "dromozoa/regexp/remove_assertions.lua";
    ["dromozoa.regexp.scan"] = "dromozoa/regexp/scan.lua";
    ["dromozoa.regexp.scanner"] = "dromozoa/regexp/scanner.lua";
    ["dromozoa.regexp.set_token"] = "dromozoa/regexp/set_token.lua";
    ["dromozoa.regexp.template"] = "dromozoa/regexp/template.lua";
    ["dromozoa.regexp.tree_map"] = "dromozoa/regexp/tree_map.lua";
    ["dromozoa.regexp.unparse"] = "dromozoa/regexp/unparse.lua";
    ["dromozoa.regexp.write_graphviz"] = "dromozoa/regexp/write_graphviz.lua";
  };
}
