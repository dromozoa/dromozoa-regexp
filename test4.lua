local json = require "dromozoa.json"
local decode_condition = require "dromozoa.regexp.decode_condition"
local encode_condition = require "dromozoa.regexp.encode_condition"
local unparse_ere = require "dromozoa.regexp.unparse_ere"

local c = decode_condition { "[^", { "[-", "a", "z" } }
print(json.encode(encode_condition(c)))
print(unparse_ere(encode_condition(c)))

