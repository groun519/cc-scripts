local LENGTH = 11
local WIDTH = 3
local WAIT = 300

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

local function moveAndHarvest(n)
 for i = 1, n do
  harvestSides()
  moveForward(1)
 end
 harvestSides()
end

-- 왼쪽 석탄 상자에서 연료 보급
local function refuelFromLeft()
 local fuel = turtle.getFuelLevel()
 if fuel == "unlimited" or fuel > 300 then
  return
 end

 turtle.turnLeft()

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

 turtle.turnRight()

 local now = turtle.getFuelLevel()
 if now ~= "unlimited" and now <= 50 then
  error("연료 부족")
 end
end

-- 앞 사탕수수 상자에 배출
local function dumpForward()
 for slot = 1, 16 do
  turtle.select(slot)
  local item = turtle.getItemDetail()

  if item and not isFuel(item) then
   turtle.drop()
  end
 end

 turtle.select(1)
end

local function patrol()
 turtle.up()

 -- 시작 위치 기준 오른쪽으로 순회 시작
 turtle.turnRight()

 moveAndHarvest(LENGTH)
 turtle.turnRight()

 moveAndHarvest(WIDTH)
 turtle.turnRight()

 moveAndHarvest(LENGTH)
 turtle.turnRight()

 moveAndHarvest(WIDTH)

 -- 여기까지 오면 처음 위치, 처음 방향으로 복귀
 turtle.down()
end

while true do
 refuelFromLeft()
 patrol()
 dumpForward()
 sleep(WAIT)
end