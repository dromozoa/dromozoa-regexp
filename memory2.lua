local M = 1024

local function run(fn)
  local matrix = {}
  local result = {}

  collectgarbage()
  collectgarbage()
  collectgarbage("stop")

  local a = collectgarbage("count")
  for i = 1, M do
    local j = fn(i)
    matrix[j + 1] = math.random()
    matrix[j + 2] = math.random()
    matrix[j + 3] = math.random()
    matrix[j + 4] = math.random()
    local b = collectgarbage("count")
    result[i] = b - a
  end

  collectgarbage()
  collectgarbage()
  collectgarbage("restart")

  return result
end

local data = {
  run(function (i) return i * 4 end);
  run(function (i) return i * 1023 end);
  run(function (i) return i * 1024 end);
  run(function (i) return i * 1025 end);
}
local n = #data

for i = 1, M do
  io.write(i)
  for j = 1, n do
    io.write("\t", data[j][i])
  end
  io.write("\n")
end
