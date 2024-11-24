-- map function likery JavaScript.
local function map(fn, ary)
  local a = {}
  for i = 1, #ary do
    table.insert(a, fn(ary[i], i))
  end
  return a
end

return {
  map = map,
}
