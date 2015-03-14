

do
  local data = {}

  collectgarbage()
  collectgarbage()

  for i = 1, 1000000 do
    data[i] = { i; i + 1; i + 2; i + 3 }
  end

  collectgarbage()
  collectgarbage()

  print(collectgarbage("count"))
end

do
  local data = {}

  collectgarbage()
  collectgarbage()

  for i = 1, 1000000 do
    data[i] = { [0] = i; [1] = i + 1; [2] = i + 2; [3] = i + 3 }
  end

  collectgarbage()
  collectgarbage()

  print(collectgarbage("count"))
end

do
  local data = {}

  collectgarbage()
  collectgarbage()

  for i = 1, 1000000 do
    data[i] = { [1] = i; [2] = i + 1; [3] = i + 2; [4] = i + 3 }
  end

  collectgarbage()
  collectgarbage()

  print(collectgarbage("count"))
end

do
  local a = {}
  local b = {}
  local c = {}
  local d = {}

  collectgarbage()
  collectgarbage()

  for i = 1, 1000000 do
    a[i] = i
    b[i] = i + 2
    c[i] = i + 3
    d[i] = i + 4
  end

  collectgarbage()
  collectgarbage()

  print(collectgarbage("count"))
end
