local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local DataItems=Loader.load("lib.data_items")
local DataStats=Loader.load("lib.data_stats")
local Data={}
Data.items={}
Data.lookup={}
Data.stats={}
Data.lastUpdate=0
Data.lastError=nil
function Data.update()
 Peripherals.refresh()
 if not Peripherals.me then Data.lastError="ME bridge missing" return false,Data.lastError end
 local okItems,items,lookup=pcall(function() return DataItems.update(Peripherals.me,Data.items) end)
 if okItems then Data.items=items or {} Data.lookup=lookup or {} else Data.lastError=items Data.items={} Data.lookup={} end
 local okStats,stats=pcall(function() return DataStats.update(Peripherals.me) end)
 if okStats then Data.stats=stats or {} else Data.lastError=stats Data.stats={} end
 Data.lastUpdate=os.epoch("utc")
 if not okItems then return false,Data.lastError end
 if not okStats then return false,Data.lastError end
 Data.lastError=nil
 return true,nil
end
function Data.getTopItems(limit) local r={} limit=limit or 10 for i=1,math.min(limit,#Data.items) do r[i]=Data.items[i] end return r end
function Data.getItemCount() return #Data.items end
function Data.getStats() return Data.stats or {} end
function Data.getLastUpdate() return Data.lastUpdate end
function Data.getLastError() return Data.lastError end
function Data.search(text) local r={} text=string.lower(tostring(text or "")) for _,item in ipairs(Data.items) do local n=string.lower(item.name or "") local d=string.lower(item.displayName or "") if string.find(n,text,1,true) or string.find(d,text,1,true) then table.insert(r,item) end end return r end
return Data
