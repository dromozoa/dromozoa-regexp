local function fn1(x)
  local a = x[1]
  if a < 0 then
    return a + x[2]
  end
end

local function fn1(x)
  local a, b, c = x[1], x[2], x[3]
  if a < 0 then
    return a + b
  end
end


