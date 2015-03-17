local M = 1024 * 1024

local function run()
  local matrix = {}
  local result = {}

  collectgarbage()
  collectgarbage()
  collectgarbage("stop")

  local a = collectgarbage("count")
  for i = 1, M do
    matrix[i] = 17
    result[i] = collectgarbage("count")
  end

  collectgarbage()
  collectgarbage()
  collectgarbage("restart")

  return result
end

local result = run()

for i = 1, #result - 1 do
  local d = result[i + 1] - result[i]
  if d > 0 then
    print(i, d)
  end
end
