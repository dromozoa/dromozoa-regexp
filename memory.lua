

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

do
  local data = {}
  local N = 2047

  collectgarbage()
  collectgarbage()

  for i = 1, 1000000 do
    j = N * i
    data[j] = i
    data[j + 1] = i + 2
    data[j + 2] = i + 3
    data[j + 3] = i + 4
  end

  collectgarbage()
  collectgarbage()

  print(collectgarbage("count"))
end

for i = 0, N - 1 do
  local j = i * M
  matrix[j + 1] = 17
  matrix[j + 2] = 23
  matrix[j + 3] = 37
  matrix[j + 4] = 42
end


