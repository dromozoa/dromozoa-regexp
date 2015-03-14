local ubench = require "dromozoa.ubench"

local b = ubench()
b:add("seq", function (ctx)
  local data = {}
  for i = 1, 1000 do
    data[i] = { i, i + 1, i + 2, i + 3 }
  end
  return ctx + #data
end, 0)
b:add("map", function (ctx)
  local data = {}
  for i = 1, 1000 do
    data[i] = { a = i, b = i + 1, c = i + 2, d = i + 3 }
  end
  return ctx + #data
end, 0)
b:add("sep", function (ctx)
  local a = {}
  local b = {}
  local c = {}
  local d = {}
  for i = 1, 1000 do
    a[i] = i
    b[i] = i + 1
    c[i] = i + 2
    d[i] = i + 3
  end
  return ctx + #a + #b + #c + #d
end, 0)
b:add("mat4", function (ctx)
  local data = {}
  for i = 1, 1000 do
    local j = i * 4
    data[j] = i
    data[j + 1] = i + 1
    data[j + 2] = i + 2
    data[j + 3] = i + 3
  end
  return ctx + #data
end, 0)
b:add("mat256", function (ctx)
  local data = {}
  for i = 1, 1000 do
    local j = i * 256
    data[j] = i
    data[j + 1] = i + 1
    data[j + 2] = i + 2
    data[j + 3] = i + 3
  end
  return ctx + #data
end, 0)

b:run()
