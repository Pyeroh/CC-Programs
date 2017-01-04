-- local redstone = require("redstone")
-- local colors = require("colors")
-- local bit = require("bit")
-- local keys = require("keys")

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

--- @param #boolean input flag for input or output
--- @param #number num number of inputs/outputs needed
--- @param #boolean lesser flag to indicate if comparison must be made with lesser operator or different operator
local function validateInput(input, num, lesser, ...)
  local inputStr
  if input then
    inputStr = "input"
  else
    inputStr = "output"
  end
  if num > 1 then
    inputStr = inputStr.."s"
  end

  local inputs = {...}
  if lesser then
    if #inputs < num then
      error("Not enough "..inputStr..", min "..num, errorLevel)
    end
  else
    if #inputs ~= num then
      error("Only "..num.." "..inputStr, errorLevel)
    end
  end
end

function directAND (...)
  local input = {...}
  validateInput(true,2,true,...)
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
  validateInput(true,1,true,...)
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
  validateInput(true,2,false,...)
  validateSides(input)

  local input1 = redstone.getInput(input[1])
  local input2 = redstone.getInput(input[2])

  -- XOR expression : A XOR B <=> (A OR B) AND NOT (A AND B)
  return (input1 or input2) and not (input1 and input2)
end

function directNOT (...)
  local input = {...}
  validateInput(true,1,false,...)
  validateSides(input)

  return not redstone.getInput(input[1])
end

function directOutput (signal, ...)
  if type(signal) ~= "boolean" then
    error("Expected boolean, strings",errorLevel)
  end
  local output = {...}
  validateInput(false,1,true,...)
  validateSides(output)

  for _, v in pairs(output) do
    redstone.setOutput(v, signal)
  end
end

function analogOR (...)
  local input = {...}
  validateInput(true,1,true,...)
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
  validateInput(true,2,true,...)
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
  validateInput(true,1,false,...)
  validateSides(input)

  return 15 - redstone.getAnalogInput(input[1])
end

function analogOutput (signalIntensity, ...)
  if type(signalIntensity) ~= "number" then
    error("Expected number, strings", errorLevel)
  end
  local output = {...}
  validateInput(false,1,true,...)
  validateSides(output)

  for _, v in pairs(output) do
    redstone.setAnalogOutput(v, signalIntensity)
  end
end

function bundledOR (...)
  local input = {...}
  validateInput(true,1,true,...)
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
  validateInput(true,2,true,...)
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
  validateInput(true,2,false,...)
  validateSides(input)

  return bit.bxor(redstone.getBundledInput(input[1]), redstone.getBundledInput(input[2]))
end

function bundledNOT (...)
  local input = {...}
  validateInput(true,1,false,...)
  validateSides(input)

  return bit.bnot(input[1])
end

function bundledOutput (signals, ...)
  if type(signals) ~= "number" then
    error("Expected number, strings", errorLevel)
  end
  local output = {...}
  validateInput(false,1,true,...)
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

function gateLoop (loopFunction, keyToStop, ...)
  if type(loopFunction) ~= "function" then
    error("First parameter is not a function", errorLevel)
  end
  local keyName = keys.getName(keyToStop)
  if not keyName then
    error("Not a valid key", errorLevel)
  end

  local keyListener = function()
    local stop = false
    while not stop do
      os.sleep(0)
      local event, key = os.pullEvent("key_up")
      if event == "key_up" and key == keyToStop then
        stop = true
      end
    end
  end

  local loopImpl = function()
    while true do
      loopFunction()
      os.sleep(0)
    end
  end

  local breakerFunctions = {...}
  for _, v in pairs(breakerFunctions) do
  	if type(v) ~= "function" then
  	  error("One of varargs is not a function", errorLevel)
  	end
  end

  print("Waiting for user to press '"..keyName.."' to stop the gate loop")
  if #breakerFunctions > 0 then
    print("or another function to end")
  end

  parallel.waitForAny(keyListener, loopImpl, ...)
  basicClearAll()
  bundledClearAll()
end
