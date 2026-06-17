local LENGTH = 10      -- 한 줄 길이. 실제 이동은 9칸
local PASSES = 5       -- 세로 줄 개수
local SHIFT = 2        -- 다음 줄로 이동할 간격
local WAIT = 300       -- 반복 대기 시간

local FUEL_NAMES = {
 ["minecraft:coal"] = true,
 ["minecraft:charcoal"] = true
}

local function isFuel(item)
 return item and FUEL_NAMES[item.name]
end

local function moveForward(n)
 for i = 1, n do
  while not turtle.forward() do
   turtle.dig()
   sleep(0.1)
  end
 end
end

local function harvestForward()
 local ok, data = turtle.inspect()
 if ok and data.name == "minecraft:sugar_cane" then
  turtle.dig()
  sleep(0.05)
 end
end

local function harvestSides()
 turtle.turnLeft()
 harvestForward()
 turtle.turnRight()

 turtle.turnRight()
 harvestForward()
 turtle.turnLeft()
end

local function refuelFromRight()
 local fuel = turtle.getFuelLevel()
 if fuel == "unlimited" or fuel > 300 then
  return
 end

 turtle.turnRight()

 for slot = 1, 16 do
  turtle.select(slot)
  local item = turtle.getItemDetail()

  if isFuel(item) then
   turtle.refuel()
  elseif not item then
   turtle.suck(16)
   local newItem = turtle.getItemDetail()
   if isFuel(newItem) then
    turtle.refuel()
   end
  end

  local now = turtle.getFuelLevel()
  if now == "unlimited" or now > 300 then
   break
  end
 end

 turtle.turnLeft()

 local now = turtle.getFuelLevel()
 if now ~= "unlimited" and now <= 50 then
  error("연료 부족")
 end
end

local function dumpToLeft()
 turtle.turnLeft()

 for slot = 1, 16 do
  turtle.select(slot)
  local item = turtle.getItemDetail()

  if item and not isFuel(item) then
   turtle.drop()
  end
 end

 turtle.turnRight()
 turtle.select(1)
end

local function patrol()
 turtle.up()

 for pass = 1, PASSES do
  for i = 1, LENGTH do
   harvestSides()

   if i < LENGTH then
    moveForward(1)
   end
  end

  if pass < PASSES then
   if pass % 2 == 1 then
    turtle.turnLeft()
    moveForward(SHIFT)
    turtle.turnLeft()
   else
    turtle.turnRight()
    moveForward(SHIFT)
    turtle.turnRight()
   end
  end
 end

 local totalShift = (PASSES - 1) * SHIFT

 if PASSES % 2 == 1 then
  turtle.turnLeft()
  turtle.turnLeft()
  moveForward(LENGTH - 1)

  turtle.turnLeft()
  moveForward(totalShift)

  turtle.turnLeft()
 else
  turtle.turnLeft()
  moveForward(totalShift)

  turtle.turnLeft()
 end

 turtle.down()
end

while true do
 refuelFromRight()
 patrol()
 dumpToLeft()
 sleep(WAIT)
end