local ubench = require "dromozoa.ubench"

local b = ubench()
b:add("seq", function (ctx)
  local data = {}
  for i = 0, 1023 do
    data[i] = { 17, 23, 37, 42 }
  end
  return ctx + #data
end, 0)
b:add("map", function (ctx)
  local data = {}
  for i = 0, 1023 do
    data[i] = { a = 17, b = 23, c = 37, d = 42 }
  end
  return ctx + #data
end, 0)
b:add("sep", function (ctx)
  local a = {}
  local b = {}
  local c = {}
  local d = {}
  for i = 0, 1023 do
    a[i] = 17
    b[i] = 23
    c[i] = 37
    d[i] = 42
  end
  return ctx + #a + #b + #c + #d
end, 0)
b:add("mat4", function (ctx)
  local data = {}
  for i = 0, 1023 do
    local j = i * 4
    data[j + 1] = 17
    data[j + 2] = 23
    data[j + 3] = 37
    data[j + 4] = 42
  end
  return ctx + #data
end, 0)
b:add("mat255", function (ctx)
  local data = {}
  for i = 0, 1023 do
    local j = i * 255
    data[j + 1] = 17
    data[j + 2] = 23
    data[j + 3] = 37
    data[j + 4] = 42
  end
  return ctx + #data
end, 0)
b:add("mat256", function (ctx)
  local data = {}
  for i = 0, 1023 do
    local j = i * 256
    data[j + 1] = 17
    data[j + 2] = 23
    data[j + 3] = 37
    data[j + 4] = 42
  end
  return ctx + #data
end, 0)
b:add("mat257", function (ctx)
  local data = {}
  for i = 0, 1023 do
    local j = i * 257
    data[j + 1] = 17
    data[j + 2] = 23
    data[j + 3] = 37
    data[j + 4] = 42
  end
  return ctx + #data
end, 0)
b:add("mat2_1", function (ctx)
  local data = {}
  for i = 0, 1023 do
    data[i * 1 + 1] = 17
  end
  return ctx
end, 0)
b:add("mat2_255", function (ctx)
  local data = {}
  for i = 0, 1023 do
    data[i * 255 + 1] = 17
  end
  return ctx
end, 0)
b:add("mat2_256", function (ctx)
  local data = {}
  for i = 0, 1023 do
    data[i * 256 + 1] = 17
  end
  return ctx
end, 0)
b:add("mat2_257", function (ctx)
  local data = {}
  for i = 0, 1023 do
    data[i * 257 + 1] = 17
  end
  return ctx
end, 0)

b:run()
