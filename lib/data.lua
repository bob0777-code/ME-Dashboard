local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Utils=Loader.load("lib.utils")

local Data={}
Data.items={}
Data.previous={}
Data.lookup={}
Data.lastUpdate=0

local function safeLower(value)
 if type(value)~="string" then return "" end
 return string.lower(value)
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
 local filters={
  "pattern",
  "terminal",
  "storage_cell",
  "storage_component",
  "spatial",
  "facade",
  "cable",
  "drive",
  "p2p",
  "memory_card"
 }
 for _,filter in ipairs(filters) do
  if string.find(name,filter,1,true) then return true end
 end
 return false
end

local function addTrend(item)
 local previous=Data.previous[item.name] or item.amount
 local trend="="
 if item.amount>previous then trend="▲" end
 if item.amount<previous then trend="▼" end
 item.previous=previous
 item.trend=trend
 return item
end

function Data.update()
 Peripherals.refresh()

 if not Peripherals.me or type(Peripherals.me.getItems)~="function" then
  return false,"ME bridge missing getItems()"
 end

 Data.previous={}
 for _,item in ipairs(Data.items) do
  if item.name then Data.previous[item.name]=item.amount or 0 end
 end

 Data.items={}
 Data.lookup={}

 local ok,raw=pcall(function()
  return Peripherals.me.getItems()
 end)

 if not ok then
  return false,raw
 end

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
 Data.lastUpdate=os.epoch("utc")

 return true,nil
end

function Data.getTopItems(limit)
 local result={}
 limit=limit or 10
 for i=1,math.min(limit,#Data.items) do
  result[i]=Data.items[i]
 end
 return result
end

function Data.getItemCount()
 return #Data.items
end

function Data.getLastUpdate()
 return Data.lastUpdate
end

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
