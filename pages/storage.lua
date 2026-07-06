local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")
local Storage={}

local ITEM_LIMIT=2147480000
local FLUID_LIMIT=2147480000

local cachedItems={}
local cachedMaxedItems={}
local cachedMaxedFluids={}
local cachedStats={energy=0,itemCap=0,fluidCap=0,fluidUsed=0,cells=0,bytes=0,used=0}

local rowColors={colors.red,colors.orange,colors.yellow,colors.lime,colors.green,colors.cyan,colors.lightBlue,colors.blue,colors.purple,colors.magenta}

local function clean(v)
 v=tostring(v or "")
 v=v:gsub("%[","")
 v=v:gsub("%]","")
 return v
end

local function getItems()
 Peripherals.refresh()
 local me=Peripherals.me
 local normal={}
 local maxed={}
 if not me or type(me.getItems)~="function" then return normal,maxed end
 local ok,items=pcall(function() return me.getItems() end)
 if not ok or type(items)~="table" then return normal,maxed end

 for _,item in ipairs(items) do
  local amount=tonumber(item.amount or item.count) or 0
  local entry={name=item.name or item.id or "Unknown",displayName=clean(item.displayName or item.display_name or item.name or "Unknown"),amount=amount}
  if amount>=ITEM_LIMIT then table.insert(maxed,entry) else table.insert(normal,entry) end
 end

 table.sort(normal,function(a,b) return a.amount>b.amount end)
 table.sort(maxed,function(a,b) return a.amount>b.amount end)
 return normal,maxed
end

local function getStats()
 Peripherals.refresh()
 local me=Peripherals.me
 local s={energy=0,itemCap=0,fluidCap=0,fluidUsed=0,cells=0,bytes=0,used=0}
 local maxedFluids={}
 if not me then return s,maxedFluids end

 local ok,e=pcall(function() return me.getStoredEnergy() end) if ok then s.energy=tonumber(e) or 0 end
 local ok2,i=pcall(function() return me.getTotalItemStorage() end) if ok2 then s.itemCap=tonumber(i) or 0 end
 local ok3,f=pcall(function() return me.getTotalFluidStorage() end) if ok3 then s.fluidCap=tonumber(f) or 0 end

 local ok4,c=pcall(function() return me.getCells() end)
 if ok4 and type(c)=="table" then
  s.cells=#c
  for _,cell in ipairs(c) do
   s.bytes=s.bytes+(tonumber(cell.bytes) or 0)
   s.used=s.used+(tonumber(cell.usedBytes) or 0)
  end
 end

 local ok5,fluids=pcall(function() return me.getFluids() end)
 if ok5 and type(fluids)=="table" then
  for _,fluid in ipairs(fluids) do
   local amount=tonumber(fluid.amount or fluid.count) or 0
   local entry={name=fluid.name or fluid.id or "Unknown",displayName=clean(fluid.displayName or fluid.display_name or fluid.name or "Unknown"),amount=amount}
   if amount>=FLUID_LIMIT then table.insert(maxedFluids,entry) else s.fluidUsed=s.fluidUsed+amount end
  end
 end

 table.sort(maxedFluids,function(a,b) return a.amount>b.amount end)
 return s,maxedFluids
end

function Storage.prepare()
 cachedItems,cachedMaxedItems=getItems()
 cachedStats,cachedMaxedFluids=getStats()
end

function Storage.draw(area)
 local items=cachedItems
 local maxedItems=cachedMaxedItems
 local maxedFluids=cachedMaxedFluids
 local stats=cachedStats

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
  local color=rowColors[((i-1)%#rowColors)+1]
  Renderer.write(area.x,y,Utils.padLeft(i..".",3),color)
  Renderer.write(area.x+4,y,"|",Theme.border)
  Renderer.write(area.x+6,y,Utils.padRight(Utils.truncate(item.displayName,32),32),color)
  Renderer.write(area.x+39,y,"|",Theme.border)
  Renderer.write(area.x+42,y,Utils.padLeft(Utils.formatNumber(item.amount),12),color)
 end

 Renderer.write(rightX,area.y+3,"ME Storage Stats",Theme.header)
 Renderer.hLine(rightX,area.y+4,rightW,Theme.border)

 local cellText=Utils.formatNumber(stats.used).."/"..Utils.formatNumber(stats.bytes)
 local barW=math.max(4,rightW-18-#cellText)

 Renderer.write(rightX,area.y+6,"Cell Bytes",Theme.muted)
 Renderer.write(rightX+12,area.y+6,Utils.bar(stats.used,stats.bytes,barW),Theme.good)
 Renderer.write(rightX+13+barW,area.y+6,cellText,Theme.header)

 Renderer.write(rightX,area.y+8,"Storage Cells",Theme.muted)
 Renderer.write(rightX+16,area.y+8,tostring(stats.cells),Theme.good)

 Renderer.write(rightX,area.y+10,"Item Capacity",Theme.muted)
 Renderer.write(rightX+16,area.y+10,Utils.formatNumber(stats.itemCap),Theme.header)

 Renderer.write(rightX,area.y+12,"Fluid Capacity",Theme.muted)
 Renderer.write(rightX+16,area.y+12,Utils.formatNumber((stats.fluidUsed or 0)/1000).."/"..Utils.formatNumber((stats.fluidCap or 0)/100).." Buckets",Theme.header)

 Renderer.write(rightX,area.y+14,"Stored Energy",Theme.muted)
 Renderer.write(rightX+16,area.y+14,Utils.formatNumber(stats.energy),Theme.header)

 local y=area.y+17
 Renderer.write(rightX,y,"Integer Limit Values",Theme.warning)
 Renderer.hLine(rightX,y+1,rightW,Theme.border)

 y=y+3
 Renderer.write(rightX,y,"Items",Theme.header)
 y=y+1
 for i=1,math.min(4,#maxedItems) do
  local item=maxedItems[i]
  local color=rowColors[((i-1)%#rowColors)+1]
  Renderer.write(rightX,y,Utils.truncate(item.displayName,18),color)
  Renderer.write(rightX+20,y,Utils.formatNumber(item.amount),color)
  y=y+1
 end

 y=y+1
 Renderer.write(rightX,y,"Fluids",Theme.header)
 y=y+1
 for i=1,math.min(4,#maxedFluids) do
  local fluid=maxedFluids[i]
  local color=rowColors[((i-1)%#rowColors)+1]
  Renderer.write(rightX,y,Utils.truncate(fluid.displayName,18),color)
  Renderer.write(rightX+20,y,Utils.formatNumber(fluid.amount/1000).." Buckets",color)
  y=y+1
 end
end

return Storage
