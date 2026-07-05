local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")

local Data={}
Data.items={}
Data.maxedItems={}
Data.fluids={}
Data.maxedFluids={}
Data.lookup={}
Data.stats={energy=0,itemCap=0,fluidCap=0,fluidUsed=0,cells=0,bytes=0,used=0}
Data.lastUpdate=0

local ITEM_LIMIT=2147480000
local FLUID_LIMIT_RAW=ITEM_LIMIT*1000

local function cleanName(v)
 v=tostring(v or "")
 v=v:gsub("%[","")
 v=v:gsub("%]","")
 return v
end

local function normaliseItem(raw)
 if type(raw)~="table" then return nil end
 local name=raw.name or raw.id or "unknown"
 local display=cleanName(raw.displayName or raw.display_name or raw.label or name)
 local amount=tonumber(raw.amount or raw.count or 0) or 0
 return {name=name,displayName=display,amount=amount,count=amount,fingerprint=raw.fingerprint}
end

local function normaliseFluid(raw)
 if type(raw)~="table" then return nil end
 local name=raw.name or raw.id or "unknown"
 local display=cleanName(raw.displayName or raw.display_name or raw.label or name)
 local amount=tonumber(raw.amount or raw.count or 0) or 0
 return {name=name,displayName=display,amount=amount,count=amount,fingerprint=raw.fingerprint}
end

local function loadItems(me)
 local ok,raw=pcall(function() return me.getItems() end)
 if not ok or type(raw)~="table" then return {},{} end

 local normal={}
 local maxed={}

 for _,r in ipairs(raw) do
  local item=normaliseItem(r)
  if item then
   if item.amount>=ITEM_LIMIT then
    table.insert(maxed,item)
   else
    table.insert(normal,item)
   end
  end
 end

 table.sort(normal,function(a,b) return a.amount>b.amount end)
 table.sort(maxed,function(a,b) return a.amount>b.amount end)

 return normal,maxed
end

local function loadFluids(me)
 local ok,raw=pcall(function() return me.getFluids() end)
 if not ok or type(raw)~="table" then return {},{} end

 local normal={}
 local maxed={}

 for _,r in ipairs(raw) do
  local fluid=normaliseFluid(r)
  if fluid then
   if fluid.amount>=FLUID_LIMIT_RAW then
    table.insert(maxed,fluid)
   else
    table.insert(normal,fluid)
   end
  end
 end

 table.sort(normal,function(a,b) return a.amount>b.amount end)
 table.sort(maxed,function(a,b) return a.amount>b.amount end)

 return normal,maxed
end

local function getStats(me,fluids)
 local s={energy=0,itemCap=0,fluidCap=0,fluidUsed=0,cells=0,bytes=0,used=0}

 local ok,e=pcall(function() return me.getStoredEnergy() end)
 if ok then s.energy=tonumber(e) or 0 end

 local ok2,i=pcall(function() return me.getTotalItemStorage() end)
 if ok2 then s.itemCap=tonumber(i) or 0 end

 local ok3,f=pcall(function() return me.getTotalFluidStorage() end)
 if ok3 then s.fluidCap=tonumber(f) or 0 end

 for _,fluid in ipairs(fluids or {}) do
  s.fluidUsed=s.fluidUsed+(tonumber(fluid.amount or fluid.count) or 0)
 end

 local ok4,c=pcall(function() return me.getCells() end)
 if ok4 and type(c)=="table" then
  s.cells=#c
  for _,cell in ipairs(c) do
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
 if not Peripherals.me or type(Peripherals.me.getItems)~="function" then
  return false,"ME bridge missing"
 end

 Data.items,Data.maxedItems=loadItems(Peripherals.me)
 Data.fluids,Data.maxedFluids=loadFluids(Peripherals.me)
 Data.stats=getStats(Peripherals.me,Data.fluids)

 Data.lookup={}
 for _,item in ipairs(Data.items) do
  Data.lookup[item.name]=item
 end

 Data.lastUpdate=os.epoch("utc")
 return true,nil
end

function Data.getTopItems(limit)
 local result={}
 limit=limit or 10
 for i=1,math.min(limit,#Data.items) do result[i]=Data.items[i] end
 return result
end

function Data.getMaxedItems() return Data.maxedItems or {} end
function Data.getMaxedFluids() return Data.maxedFluids or {} end
function Data.getItemCount() return #Data.items end
function Data.getStats() return Data.stats end
function Data.getLastUpdate() return Data.lastUpdate end

function Data.search(text)
 local result={}
 text=string.lower(tostring(text or ""))
 for _,item in ipairs(Data.items) do
  local name=string.lower(tostring(item.name or ""))
  local display=string.lower(tostring(item.displayName or ""))
  if string.find(name,text,1,true) or string.find(display,text,1,true) then
   table.insert(result,item)
  end
 end
 return result
end

return Data
