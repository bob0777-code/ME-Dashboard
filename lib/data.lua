local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local DataItems=Loader.load("lib.data_items")
local DataStats=Loader.load("lib.data_stats")

local Data={}
Data.items={}
Data.lookup={}
Data.stats={}
Data.lastUpdate=0

function Data.update()
 Peripherals.refresh()
 if not Peripherals.me then return false,"ME bridge missing" end
 if type(Peripherals.me.getItems)~="function" then return false,"ME bridge missing getItems()" end

 local ok,err=pcall(function()
  Data.items,Data.lookup=DataItems.update(Peripherals.me,Data.items)
  Data.stats=DataStats.update(Peripherals.me)
 end)

 if not ok then return false,err end
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
 text=string.lower(tostring(text or ""))
 for _,item in ipairs(Data.items) do
  local n=string.lower(item.name or "")
  local d=string.lower(item.displayName or "")
  if string.find(n,text,1,true) or string.find(d,text,1,true) then table.insert(result,item) end
 end
 return result
end

return Data
