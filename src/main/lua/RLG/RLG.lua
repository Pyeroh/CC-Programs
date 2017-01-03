-- local redstone = require("redstone")
-- local colors = require("colors")
-- local bit = require("bit")

local errorLevel = 2
local availableSides = redstone.getSides()

local function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local function validateSides(tab)
  for _, side in pairs(tab) do
    if (not contains(availableSides,side)) then
      error("Side '"..side.." is not a valid side. Use redstone.getSides() to get valid sides",errorLevel)
    end
  end
end

function directAND (...)
  local input = {...}
  if #input < 2  then
    error("Not enough inputs, min 2", errorLevel)
  end
  validateSides(input)

  local andRes = true
  local i = 1
  while input[i] and andRes do
    andRes = andRes and redstone.getInput(input[i])
    i = i + 1
  end

  return andRes
end

function directOR (...)
  local input = {...}
  if #input < 1  then
    error("Not enough inputs, min 1", errorLevel)
  end
  validateSides(input)

  local orRes = false
  local i = 1
  while input[i] and not orRes do
    orRes = orRes or redstone.getInput(input[i])
    i = i + 1
  end

  return orRes
end

function directXOR (...)
  local input = {...}
  if #input ~= 2  then
    error("Only 2 inputs", errorLevel)
  end
  validateSides(input)

  local input1 = redstone.getInput(input[1])
  local input2 = redstone.getInput(input[2])

  -- XOR expression : A XOR B <=> (A OR B) AND NOT (A AND B)
  return (input1 or input2) and not (input1 and input2)
end

function directNOT (...)
  local input = {...}
  if #input ~= 1  then
    error("Only 1 input", errorLevel)
  end
  validateSides(input)

  return not redstone.getInput(input[1])
end

function directOutput (signal, ...)
  if type(signal) ~= "boolean" then
    error("Expected boolean, strings",errorLevel)
  end
  local output = {...}
  if #output < 1 then
    error("At least 1 output is needed",errorLevel)
  end
  validateSides(output)

  for _, v in pairs(output) do
  	redstone.setOutput(v, signal)
  end
end

function analogOR (...)
  local input = {...}
  if #input < 1  then
    error("Not enough inputs, min 1", errorLevel)
  end
  validateSides(input)

  local orRes = 0
  local i = 1
  while input[i] do
    orRes = math.max(orRes, redstone.getAnalogInput(input[i]))
    i = i + 1
  end

  return orRes
end

function analogAND (...)
  local input = {...}
  if #input < 2  then
    error("Not enough inputs, min 2", errorLevel)
  end
  validateSides(input)

  local andRes = 15
  local i = 1
  while input[i] do
    andRes = math.min(andRes, redstone.getAnalogInput(input[i]))
    i = i + 1
  end

  return andRes
end

function analogNOT (...)
  local input = {...}
  if #input ~= 1  then
    error("Only 1 input", errorLevel)
  end
  validateSides(input)

  return 15 - redstone.getAnalogInput(input[1])
end

function analogOutput (signalIntensity, ...)
  if type(signalIntensity) ~= "number" then
    error("Expected number, strings", errorLevel)
  end
  local output = {...}
  if #output < 1 then
    error("At least 1 output is needed", errorLevel)
  end
  validateSides(output)

  for _, v in pairs(output) do
    redstone.setAnalogOutput(v, signalIntensity)
  end
end

function bundledOR (...)
  local input = {...}
  if #input < 1 then
    error("Not enough inputs, min 1", errorLevel)
  end
  validateSides(input)

  local orRes = 0
  local i = 1
  while input[i] do
  	orRes = bit.bor(orRes, redstone.getBundledInput(input[i]))
  	i = i + 1
  end

  return orRes
end

function bundledAND (...)
  local input = {...}
  if #input < 2 then
    error("Not enough inputs, min 2", errorLevel)
  end
  validateSides(input)

  local andRes = 65535
  local i = 1
  while input[i] do
    andRes = bit.band(andRes, redstone.getBundledInput(input[i]))
    i = i + 1
  end

  return andRes
end

function bundledXOR (...)
	local input = {...}
  if #input ~= 2 then
    error("Only 2 inputs", errorLevel)
  end
  validateSides(input)

  return bit.bxor(redstone.getBundledInput(input[1]), redstone.getBundledInput(input[2]))
end

function bundledNOT (...)
  local input = {...}
  if #input ~= 1 then
    error("Only 1 input", errorLevel)
  end
  validateSides(input)

  return bit.bnot(input[1])
end

function bundledOutput (signals, ...)
  if type(signals) ~= "number" then
    error("Expected number, strings", errorLevel)
  end
  local output = {...}
  if #output < 1 then
  	error("At least 1 output is needed", errorLevel)
  end
  validateSides(output)

  for _, v in pairs(output) do
  	redstone.setBundledOutput(v, signals)
  end
end

function basicClear (...)
  local sides = {...}
  validateSides(sides)

  for _, v in pairs(sides) do
  	redstone.setOutput(v, false)
  end
end

function basicClearAll ()
  for _, v in pairs(redstone.getSides()) do
  	redstone.setOutput(v, false)
  end
end

function bundledClearSignals (signals, ...)
  if type(signals) ~= "number" then
  	error("Signals not a number", errorLevel)
  end
  local sides = {...}
  validateSides(sides)

  for _, v in pairs(sides) do
    redstone.setBundledOutput(v, colors.substract(redstone.getBundledOutput(v), signals))
  end
end

function bundledClear (...)
  local sides = {...}
  validateSides(sides)

  for _, v in pairs(sides) do
  	redstone.setBundledOutput(v, 0)
  end
end

function bundledClearAll ()
	for _, v in pairs(redstone.getSides()) do
    redstone.setBundledOutput(v, 0)
	end
end