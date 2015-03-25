local write_graphviz = require "dromozoa.regexp.write_graphviz"
local parse = require "dromozoa.regexp.parse"
local decode = require "dromozoa.regexp.decode"
local construct_subset = require "dromozoa.regexp.construct_subset"
local construct_product = require "dromozoa.regexp.construct_product"
local minimize = require "dromozoa.regexp.minimize"

local m1 = construct_subset(decode(parse(arg[1])))
local m2 = construct_subset(decode(parse(arg[2])))
local p = construct_product(m1, m2, "intersection")
local pm = minimize(p)
write_graphviz(m1, io.open("test-m1.dot", "w")):close()
write_graphviz(m2, io.open("test-m2.dot", "w")):close()
write_graphviz(p, io.open("test-product.dot", "w")):close()
write_graphviz(pm, io.open("test-pm.dot", "w")):close()
