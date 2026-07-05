local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local DataItems=Loader.load("lib.data_items")
local DataFluids=Loader.load("lib.data_fluids")
local DataStats=Loader.load("lib.data_stats")
local Data={}
Data.items={}
Data.maxedItems={}
Data.fluids={}
Data.maxedFluids={}
Data.stats={}
Data.lastUpdate=0
function Data.update()
 Peripherals.refresh()
 if not Peripherals.me then return false,"ME bridge missing" end
 Data.items,Data.maxedItems=DataItems.update(Peripherals.me)
 Data.fluids,Data.maxedFluids=DataFluids.update(Peripherals.me)
 Data.stats=DataStats.update(Peripherals.me,Data.fluids)
 Data.lastUpdate=os.epoch("utc")
 return true,nil
end
function Data.getTopItems(limit) local r={} limit=limit or 10 for i=1,math.min(limit,#Data.items) do r[i]=Data.items[i] end return r end
function Data.getMaxedItems() return Data.maxedItems or {} end
function Data.getFluids() return Data.fluids or {} end
function Data.getMaxedFluids() return Data.maxedFluids or {} end
function Data.getStats() return Data.stats or {} end
function Data.getItemCount() return #Data.items end
function Data.getLastUpdate() return Data.lastUpdate end
return Data
