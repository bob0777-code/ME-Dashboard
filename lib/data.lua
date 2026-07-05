local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Utils=Loader.load("lib.utils")

local Data={}
Data.items={}
Data.previous={}
Data.lookup={}
Data.stats={}
Data.lastUpdate=0

local function safeLower(v)
 if type(v)~="string" then return "" end
 return string.lower(v)
end

local function callMe(name)
 if not Peripherals.me then return nil end
 local fn=Peripherals.me[name]
 if type(fn)~="function" then return nil end
 local ok,result=pcall(function() return fn() end)
 if ok then return result end
 return nil
end

local function normaliseItem(item)
 if type(item)~="table" then return nil end
 local name=item.name or item.id or "unknown"
 local amount=tonumber(item.amount or item.count) or 0
 local displayName=item.displayName or item.display_name or name
 return {name=name,displayName=displayName,amount=amount}
end

local function isFiltered(item)
 local name=safeLower(item.name)
 local filters={"pattern","terminal","storage_cell","storage_component","spatial","facade","cable","drive","p2p","memory_card"}
 for _,f in ipairs(filters) do
  if string.find(name,f,1,true) then return true end
 end
 return false
end

local function addTrend(item)
 local old=Data.previous[item.name] or item.amount
 item.previous=old
 item.trend="="
 if item.amount>old then item.trend="+" end
 if item.amount<old then item.trend="-" end
 return item
end

local function updateStats()
 local cells=callMe("getCells")
 Data.stats={
  energy=tonumber(callMe("getStoredEnergy")) or 0,
  itemCapacity=tonumber(callMe("getTotalItemStorage")) or 0,
  fluidCapacity=tonumber(callMe("getTotalFluidStorage")) or 0,
  cellCount=0,
  cellBytes=0,
  cellUsedBytes=0
 }

 if type(cells)=="table" then
  Data.stats.cellCount=#cells
  for _,cell in ipairs(cells) do
   if type(cell)=="table" then
    Data.stats.cellBytes=Data.stats.cellBytes+(tonumber(cell.bytes) or 0)
    Data.stats.cellUsedBytes=Data.stats.cellUsedBytes+(tonumber(cell.usedBytes) or 0)
   end
  end
 end
end

function Data.update()
 Peripherals.refresh()

 if not Peripherals.me then
  return false,"ME bridge missing"
 end

 Data.previous={}
 for _,item in ipairs(Data.items) do
  if item.name then Data.previous[item.name]=item.amount or 0 end
 end

 Data.items={}
 Data.lookup={}

 local raw=callMe("getItems")
 if type(raw)~="table" then raw={} end

 for _,rawItem in ipairs(raw) do
  local item=normaliseItem(rawItem)
  if item and not isFiltered(item) then
   item=addTrend(item)
   table.insert(Data.items,item)
   Data.lookup[item.name]=item
  end
 end

 Utils.sortByAmount(Data.items)
 updateStats()
 Data.lastUpdate=os.epoch("utc")

 return true,nil
end

function Data.getTopItems(limit)
 local result={}
 limit=limit or 10
 for i=1,math.min(limit,#Data.items) do result[i]=Data.items[i] end
 return result
end

function Data.getItemCount() return #Data.items end
function Data.getStats() return Data.stats or {} end
function Data.getLastUpdate() return Data.lastUpdate end

function Data.search(text)
 local result={}
 text=safeLower(text)
 for _,item in ipairs(Data.items) do
  if string.find(safeLower(item.name),text,1,true) or string.find(safeLower(item.displayName),text,1,true) then
   table.insert(result,item)
  end
 end
 return result
end

return Data
