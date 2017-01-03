local colors = require("colors")
local redstone = {}
local inputPowerBySide = {}
local outputPowerBySide = {}
local bundledInputPowerBySide = {}
local bundledOutputPowerBySide = {}

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
    if type(side) ~= "string" then
      error("Not a string",2)
    end
    if not contains(redstone.getSides(),side) then
      error("Side '"..side.." is not a valid side. Use redstone.getSides() to get valid sides",2)
    end
  end
end

local function fif(condition, if_true, if_false)
  if condition then
    return if_true
  else
    return if_false
  end
end

function redstone.getSides()
  return {"left","right","top","bottom","front","back"}
end

function redstone.getInput(side)
  validateSides({side})
  return inputPowerBySide[side] > 0
end

function redstone.setOutput(side, value)
  if type(value) ~= "boolean" then
    error("Expected string, boolean",2)
  end
  validateSides({side})
  outputPowerBySide[side] = fif(value, 15, 0)
  inputPowerBySide[side] = math.max(inputPowerBySide[side], outputPowerBySide[side])
  print("Basic redstone output has been set to "..value.." on "..side.." side")
end

function redstone.getOutput(side)
  validateSides({side})
  return outputPowerBySide[side] > 0
end

function redstone.getAnalogInput(side)
  validateSides({side})
  return inputPowerBySide[side]
end

function redstone.setAnalogOutput(side, strength)
  if type(strength) ~= "number" then
    error("Expected string, number",2)
  end
  validateSides({side})
  outputPowerBySide[side] = strength
  inputPowerBySide[side] = math.max(inputPowerBySide[side], outputPowerBySide[side])
  print("Analog redstone output has been set to "..strength.." on "..side.." side")
end

function redstone.getAnalogOutput(side)
  validateSides({side})
  return outputPowerBySide[side]
end

function redstone.getBundledInput(side)
  validateSides({side})
  return bundledInputPowerBySide[side]
end

function redstone.getBundledOutput(side)
  validateSides({side})
  return bundledOutputPowerBySide[side]
end

function redstone.setBundledOutput(side, colorsNumber)
  validateSides({side})
  if type(colorsNumber) ~= "number" then
    error("Not a number",2)
  end

  bundledOutputPowerBySide[side] = colorsNumber
  bundledInputPowerBySide[side] = colors.combine(bundledInputPowerBySide[side], bundledOutputPowerBySide[side])
  print("Bundled redstone output has been set to "..colorsNumber.." on "..side.." side")
end

function redstone.testBundledInput(side, color)
  return colors.test(redstone.getBundledInput(side), color)
end

for k, v in pairs(redstone.getSides()) do
  inputPowerBySide[k] = 0
  bundledInputPowerBySide[k] = 0
end

return redstone
