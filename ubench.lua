local ubench = require "dromozoa.ubench"

local A = {}
local B = {}
for i = 1, 100 do
  A[i] = i * 2
  B[i] = i * 3
end

local function next_p1(ctx, a)
  local A = ctx[1]
  local B = ctx[2]
  local i = ctx[3]
  local j = ctx[4]
  local b

  if not i then
    i, a = next(A, i)
  end
  j, b = next(B, j)
  if not j then
    i, a = next(A, i)
    if i then
      j, b = next(B, j)
    else
      return nil
    end
  end

  ctx[3] = i
  ctx[4] = j

  return a, b
end

local function each_p1(A, B)
  return next_p1, { A, B }
end

local function next_p1(A, B)
  for i = 1, #A do
    for j = 1, #B do
      coroutine.yield(A[i], B[i])
    end
  end
end

local function each_p2(A, B)
  local coro_wrap = coroutine.wrap
  local coro_yield = coroutine.yield
  return coro_wrap(function ()
    for i = 1, #A do
      for j = 1, #B do
        coro_yield(A[i], B[i])
      end
    end
  end)
end

local b = ubench()

b:add("each_len", function (ctx)
  for i = 1, #A do
    for j = 1, #B do
      ctx = ctx + A[i] + B[i]
    end
  end
  return ctx
end, 0)

b:add("each_pairs", function (ctx)
  for i, a in pairs(A) do
    for j, b in pairs(B) do
      ctx = ctx + a + b
    end
  end
  return ctx
end, 0)

b:add("each_p1", function (ctx)
  for a, b in each_p1(A, B) do
    ctx = ctx + a + b
  end
  return ctx
end, 0)

b:add("each_p2", function (ctx)
  for a, b in each_p1(A, B) do
    ctx = ctx + a + b
  end
  return ctx
end, 0)

b:run()
