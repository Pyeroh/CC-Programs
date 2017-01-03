local bit = require("bit")

local colors = {
  white       = 1,
  orange      = 2,
  magenta     = 4,
  lightBlue   = 8,
  yellow      = 16,
  lime        = 32,
  pink        = 64,
  gray        = 128,
  lightGray   = 256,
  cyan        = 512,
  purple      = 1024,
  blue        = 2048,
  brown       = 4096,
  green       = 8192,
  red         = 16384,
  black       = 32768
}

local colorsTable = {}
for k, v in pairs(colors) do
	colorsTable[k] = v
end

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function copy(tab)
  local tab2 = {}
  for k, v in pairs(tab) do
  	tab2[k] = v
  end

  return tab2
end

local function decode(colorSet)
  if type(colorSet) ~= "number" then
    error("Not a number",2)
  end

  local fColorTable = {}
  local i = 1
  for k, v in spairs(colorsTable, function(t,a,b) return t[b] < t[a] end) do
    if colorSet - v >= 0 then
      fColorTable[i] = v
      i = i + 1
      colorSet = colorSet - v
    end
  end

  return fColorTable
end

function colors.combine(...)
  local combined = {}
  for i=1, select("#", ...) do
    local val, _ = select(i,...)
    if type(val) ~= "number" then
      error("Not a number",2)
    end
    local decoded = colors.decode(val)
    for k, v in pairs(decoded) do
    	combined[v] = -1
    end
  end

  local sum = 0
  for k, v in pairs(combined) do
    sum = sum + k
  end

  return sum
end

function colors.substract(initialColorSet, ...)
  if type(initialColorSet) ~= "number" then
    error("Not a number",2)
  end

  local decoded = colors.decode(initialColorSet)
  local toSubstractCombined = colors.combine(...)
  local toSubstractDecoded = colors.decode(toSubstractCombined)

  local substractedTab = copy(decoded)
  for k, v in pairs(toSubstractDecoded) do
  	for k2, v2 in pairs(substractedTab) do
  		if v2 == v then
  		  substractedTab[k2] = nil
  		end
  	end
  end

  local sum = 0
  for k, v in pairs(substractedTab) do
  	sum = sum + v
  end

  return sum
end

function colors.test(colorSet, color)
  if type(colorSet) ~= "number" or type(color) ~= "number" then
    error("Not a number",2)
  end

  return bit.bor(colorSet,color) == colorSet
end

return colors
