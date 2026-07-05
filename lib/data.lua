local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Utils=Loader.load("lib.utils")

local Data={}
Data.items={}
Data.lookup={}
Data.stats={energy=0,itemCap=0,fluidCap=0,cells=0,bytes=0,used=0}
Data.lastUpdate=0

local function getItems(me)
 local ok,items=pcall(function() return me.getItems() end)
 if not ok or type(items)~="table" then return {} end
 table.sort(items,function(a,b) return (tonumber(a.amount or a.count) or 0)>(tonumber(b.amount or b.count) or 0) end)
 return items
end

local function getStats(me)
 local s={energy=0,itemCap=0,fluidCap=0,cells=0,bytes=0,used=0}

 local ok,e=pcall(function() return me.getStoredEnergy() end)
 if ok then s.energy=tonumber(e) or 0 end

 local ok2,i=pcall(function() return me.getTotalItemStorage() end)
 if ok2 then s.itemCap=tonumber(i) or 0 end

 local ok3,f=pcall(function() return me.getTotalFluidStorage() end)
 if ok3 then s.fluidCap=tonumber(f) or 0 end

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

 Data.items=getItems(Peripherals.me)
 Data.stats=getStats(Peripherals.me)

 Data.lookup={}
 for _,item in ipairs(Data.items) do
  local name=item.name or item.id
  if name then Data.lookup[name]=item end
 end

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

function Data.getStats()
 return Data.stats
end

function Data.getLastUpdate()
 return Data.lastUpdate
end

function Data.search(text)
 local result={}
 text=string.lower(tostring(text or ""))
 for _,item in ipairs(Data.items) do
  local name=string.lower(tostring(item.name or item.id or ""))
  local display=string.lower(tostring(item.displayName or item.display_name or ""))
  if string.find(name,text,1,true) or string.find(display,text,1,true) then
   table.insert(result,item)
  end
 end
 return result
end

return Data
