local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")
local Storage={}

local cachedItems={}
local cachedStats={energy=0,itemCap=0,fluidCap=0,cells=0,bytes=0,used=0}

local rowColors={colors.red,colors.orange,colors.yellow,colors.lime,colors.green,colors.cyan,colors.lightBlue,colors.blue,colors.purple,colors.magenta}

local function getItems()
 Peripherals.refresh()
 local me=Peripherals.me
 if not me or type(me.getItems)~="function" then return {} end
 local ok,items=pcall(function() return me.getItems() end)
 if not ok or type(items)~="table" then return {} end
 table.sort(items,function(a,b) return (tonumber(a.amount or a.count) or 0)>(tonumber(b.amount or b.count) or 0) end)
 return items
end

local function getStats()
 Peripherals.refresh()
 local me=Peripherals.me
 local s={energy=0,itemCap=0,fluidCap=0,cells=0,bytes=0,used=0}
 if not me then return s end

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

function Storage.prepare()
 cachedItems=getItems()
 cachedStats=getStats()
end

function Storage.draw(area)
 local stats=cachedStats
 local items=cachedItems
 local leftW=58
 local rightX=area.x+leftW+4
 local rightW=area.w-leftW-4
 local maxRows=math.min(#items,area.h-9)

 Renderer.write(area.x,area.y,"Storage Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"Top Stored Items",Theme.header)
 Renderer.hLine(area.x,area.y+4,leftW,Theme.border)

 Renderer.write(area.x,area.y+6,"#",Theme.header)
 Renderer.write(area.x+6,area.y+6,"Item",Theme.header)
 Renderer.write(area.x+43,area.y+6,"Amount",Theme.header)
 Renderer.hLine(area.x,area.y+7,leftW,Theme.border)

 for i=1,maxRows do
  local item=items[i]
  local y=area.y+7+i
  local name=item.displayName or item.display_name or item.name or "Unknown"
  local amount=tonumber(item.amount or item.count) or 0
  local rowColor=rowColors[((i-1)%#rowColors)+1]

  Renderer.write(area.x,y,Utils.padLeft(i..".",3),rowColor)
  Renderer.write(area.x+4,y,"|",Theme.border)
  Renderer.write(area.x+6,y,Utils.padRight(Utils.truncate(name,32),32),rowColor)
  Renderer.write(area.x+39,y,"|",Theme.border)
  Renderer.write(area.x+42,y,Utils.padLeft(Utils.formatNumber(amount),12),rowColor)
 end

 Renderer.write(rightX,area.y+3,"ME Storage Stats",Theme.header)
 Renderer.hLine(rightX,area.y+4,rightW,Theme.border)

 Renderer.write(rightX,area.y+6,"Cell Bytes",Theme.muted)
 Renderer.write(rightX+16,area.y+6,Utils.bar(stats.used,stats.bytes,20),Theme.good)
 Renderer.write(rightX+38,area.y+6,Utils.formatNumber(stats.used).."/"..Utils.formatNumber(stats.bytes),Theme.header)

 Renderer.write(rightX,area.y+8,"Storage Cells",Theme.muted)
 Renderer.write(rightX+16,area.y+8,tostring(stats.cells),Theme.good)

 Renderer.write(rightX,area.y+10,"Item Capacity",Theme.muted)
 Renderer.write(rightX+16,area.y+10,Utils.formatNumber(stats.itemCap),Theme.header)

 Renderer.write(rightX,area.y+12,"Fluid Capacity",Theme.muted)
 Renderer.write(rightX+16,area.y+12,Utils.formatNumber(stats.fluidCap),Theme.header)

 Renderer.write(rightX,area.y+14,"Stored Energy",Theme.muted)
 Renderer.write(rightX+16,area.y+14,Utils.formatNumber(stats.energy),Theme.header)
end

return Storage
