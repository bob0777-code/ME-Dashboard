local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")
local Storage={}

local function bar(value,max,width)
 value=tonumber(value) or 0
 max=tonumber(max) or 1
 if max<=0 then max=1 end
 local filled=math.floor((value/max)*width)
 if filled<0 then filled=0 end
 if filled>width then filled=width end
 return string.rep("#",filled)..string.rep("-",width-filled)
end

local function getItems()
 Peripherals.refresh()
 if not Peripherals.me or type(Peripherals.me.getItems)~="function" then return {} end
 local ok,items=pcall(function() return Peripherals.me.getItems() end)
 if not ok or type(items)~="table" then return {} end
 table.sort(items,function(a,b) return (tonumber(a.amount or a.count) or 0)>(tonumber(b.amount or b.count) or 0) end)
 return items
end

local function getStats()
 Peripherals.refresh()
 local me=Peripherals.me
 local stats={energy=0,itemCap=0,fluidCap=0,cells=0,bytes=0,used=0}
 if not me then return stats end
 local ok,e=pcall(function() return me.getStoredEnergy() end) if ok then stats.energy=tonumber(e) or 0 end
 local ok2,i=pcall(function() return me.getTotalItemStorage() end) if ok2 then stats.itemCap=tonumber(i) or 0 end
 local ok3,f=pcall(function() return me.getTotalFluidStorage() end) if ok3 then stats.fluidCap=tonumber(f) or 0 end
 local ok4,c=pcall(function() return me.getCells() end)
 if ok4 and type(c)=="table" then
  stats.cells=#c
  for _,cell in ipairs(c) do
   if type(cell)=="table" then
    stats.bytes=stats.bytes+(tonumber(cell.bytes) or 0)
    stats.used=stats.used+(tonumber(cell.usedBytes) or 0)
   end
  end
 end
 return stats
end

function Storage.draw(area)
 local stats=getStats()
 local items=getItems()

 Renderer.write(area.x,area.y,"Storage Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"ME Storage Stats",Theme.header)
 Renderer.write(area.x,area.y+5,"Cell Bytes",Theme.muted)
 Renderer.write(area.x+18,area.y+5,bar(stats.used,stats.bytes,30),Theme.good)
 Renderer.write(area.x+50,area.y+5,Utils.formatNumber(stats.used).."/"..Utils.formatNumber(stats.bytes),Theme.header)

 Renderer.write(area.x,area.y+7,"Storage Cells",Theme.muted)
 Renderer.write(area.x+18,area.y+7,tostring(stats.cells),Theme.good)

 Renderer.write(area.x,area.y+9,"Item Capacity",Theme.muted)
 Renderer.write(area.x+18,area.y+9,Utils.formatNumber(stats.itemCap),Theme.header)

 Renderer.write(area.x,area.y+11,"Fluid Capacity",Theme.muted)
 Renderer.write(area.x+18,area.y+11,Utils.formatNumber(stats.fluidCap),Theme.header)

 Renderer.write(area.x,area.y+13,"Stored Energy",Theme.muted)
 Renderer.write(area.x+18,area.y+13,Utils.formatNumber(stats.energy),Theme.header)

 Renderer.write(area.x,area.y+16,"Top Stored Items",Theme.header)
 Renderer.hLine(area.x,area.y+17,area.w,Theme.border)

 Renderer.write(area.x,area.y+19,"#",Theme.header)
 Renderer.write(area.x+5,area.y+19,"Item",Theme.header)
 Renderer.write(area.x+area.w-18,area.y+19,"Amount",Theme.header)

 for idx=1,math.min(20,#items) do
  local item=items[idx]
  local y=area.y+19+idx
  local name=item.displayName or item.display_name or item.name or "Unknown"
  local amount=tonumber(item.amount or item.count) or 0
  Renderer.write(area.x,y,Utils.padLeft(idx..".",3),Theme.text)
  Renderer.write(area.x+5,y,Utils.padRight(Utils.truncate(name,area.w-28),area.w-28),Theme.text)
  Renderer.write(area.x+area.w-20,y,Utils.padLeft(Utils.formatNumber(amount),10),Theme.header)
 end
end

return Storage
