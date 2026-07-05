local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Utils=Loader.load("lib.utils")

local Data={}

Data.items={}
Data.maxedItems={}
Data.fluids={}
Data.maxedFluids={}
Data.stats={energy=0,itemCap=0,fluidCap=0,fluidUsed=0,cells=0,bytes=0,used=0}
Data.lastUpdate=0

local ITEM_LIMIT=2147480000
local FLUID_LIMIT=2147480000

local function clean(v)
 v=tostring(v or "")
 v=v:gsub("%[","")
 v=v:gsub("%]","")
 return v
end

local function sortAmount(t)
 table.sort(t,function(a,b) return (a.amount or 0)>(b.amount or 0) end)
end

local function loadItems(me)
 local normal={}
 local maxed={}
 if not me or type(me.getItems)~="function" then return normal,maxed end
 local ok,raw=pcall(function() return me.getItems() end)
 if not ok or type(raw)~="table" then return normal,maxed end

 for _,r in ipairs(raw) do
  if type(r)=="table" then
   local amount=tonumber(r.amount or r.count) or 0
   local item={
    name=r.name or r.id or "Unknown",
    displayName=clean(r.displayName or r.display_name or r.name or "Unknown"),
    amount=amount
   }

   if amount>=ITEM_LIMIT then
    table.insert(maxed,item)
   else
    table.insert(normal,item)
   end
  end
 end

 sortAmount(normal)
 sortAmount(maxed)

 return normal,maxed
end

local function loadFluids(me)
 local normal={}
 local maxed={}
 if not me or type(me.getFluids)~="function" then return normal,maxed end
 local ok,raw=pcall(function() return me.getFluids() end)
 if not ok or type(raw)~="table" then return normal,maxed end

 for _,r in ipairs(raw) do
  if type(r)=="table" then
   local amount=tonumber(r.amount or r.count) or 0
   local fluid={
    name=r.name or r.id or "Unknown",
    displayName=clean(r.displayName or r.display_name or r.name or "Unknown"),
    amount=amount
   }

   if amount>=FLUID_LIMIT then
    table.insert(maxed,fluid)
   else
    table.insert(normal,fluid)
   end
  end
 end

 sortAmount(normal)
 sortAmount(maxed)

 return normal,maxed
end

local function loadStats(me,normalFluids)
 local s={energy=0,itemCap=0,fluidCap=0,fluidUsed=0,cells=0,bytes=0,used=0}

 if not me then return s end

 local ok,e=pcall(function() return me.getStoredEnergy() end)
 if ok then s.energy=tonumber(e) or 0 end

 local ok2,i=pcall(function() return me.getTotalItemStorage() end)
 if ok2 then s.itemCap=tonumber(i) or 0 end

 local ok3,f=pcall(function() return me.getTotalFluidStorage() end)
 if ok3 then s.fluidCap=tonumber(f) or 0 end

 for _,fluid in ipairs(normalFluids or {}) do
  s.fluidUsed=s.fluidUsed+(tonumber(fluid.amount) or 0)
 end

 local ok4,cells=pcall(function() return me.getCells() end)
 if ok4 and type(cells)=="table" then
  s.cells=#cells
  for _,cell in ipairs(cells) do
   if type(cell)=="table" then
    s.bytes=s.bytes+(tonumber(cell.bytes) or 0)
    s.used=s.used+(tonumber(cell.usedBytes) or 0)
   end
  end
 end

 return s
end

function Data.update()
 Peripherals.refresh()

 if not Peripherals.me then
  return false,"ME bridge missing"
 end

 Data.items,Data.maxedItems=loadItems(Peripherals.me)
 Data.fluids,Data.maxedFluids=loadFluids(Peripherals.me)
 Data.stats=loadStats(Peripherals.me,Data.fluids)
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

function Data.getMaxedItems()
 return Data.maxedItems or {}
end

function Data.getFluids()
 return Data.fluids or {}
end

function Data.getMaxedFluids()
 return Data.maxedFluids or {}
end

function Data.getStats()
 return Data.stats or {}
end

function Data.getItemCount()
 return #Data.items
end

function Data.getLastUpdate()
 return Data.lastUpdate
end

return Data
