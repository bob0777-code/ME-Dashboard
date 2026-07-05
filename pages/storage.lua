local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")

local Storage={}

local function drawBar(x,y,label,used,total,width)
 used=tonumber(used) or 0
 total=tonumber(total) or 1
 local percent=0
 if total>0 then percent=math.floor((used/total)*100) end
 Renderer.write(x,y,label,Theme.muted)
 Renderer.write(x+18,y,Utils.bar(used,total,width),Theme.good)
 Renderer.write(x+18+width+2,y,tostring(percent).."%",Theme.header)
end

function Storage.draw(area)
 local items=Data.getTopItems(20)
 local stats=Data.getStats()

 Renderer.write(area.x,area.y,"Storage Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"ME Storage Stats",Theme.header)

 drawBar(area.x,area.y+5,"Cell Bytes",stats.cellUsedBytes or 0,stats.cellBytes or 1,30)

 Renderer.write(area.x,area.y+7,"Storage Cells",Theme.muted)
 Renderer.write(area.x+18,area.y+7,tostring(stats.cellCount or 0),Theme.good)

 Renderer.write(area.x,area.y+9,"Item Capacity",Theme.muted)
 Renderer.write(area.x+18,area.y+9,Utils.formatNumber(stats.itemCapacity or 0),Theme.header)

 Renderer.write(area.x,area.y+11,"Fluid Capacity",Theme.muted)
 Renderer.write(area.x+18,area.y+11,Utils.formatNumber(stats.fluidCapacity or 0),Theme.header)

 Renderer.write(area.x,area.y+13,"Stored Energy",Theme.muted)
 Renderer.write(area.x+18,area.y+13,Utils.formatNumber(stats.energy or 0),Theme.header)

 Renderer.write(area.x,area.y+16,"Top Stored Items",Theme.header)
 Renderer.hLine(area.x,area.y+17,area.w,Theme.border)

 Renderer.write(area.x,area.y+19,"#",Theme.header)
 Renderer.write(area.x+5,area.y+19,"Item",Theme.header)
 Renderer.write(area.x+area.w-18,area.y+19,"Amount",Theme.header)
 Renderer.write(area.x+area.w-3,area.y+19,"T",Theme.header)

 for i=1,math.min(20,#items) do
  local item=items[i]
  local y=area.y+19+i
  local name=Utils.truncate(item.displayName or item.name or "Unknown",area.w-28)
  local amount=Utils.formatNumber(item.amount or 0)
  local trend=item.trend or "="
  local trendColor=Theme.text
  if trend=="+" then trendColor=Theme.good end
  if trend=="-" then trendColor=Theme.bad end

  Renderer.write(area.x,y,Utils.padLeft(i..".",3),Theme.text)
  Renderer.write(area.x+5,y,Utils.padRight(name,area.w-28),Theme.text)
  Renderer.write(area.x+area.w-20,y,Utils.padLeft(amount,10),Theme.header)
  Renderer.write(area.x+area.w-3,y,trend,trendColor)
 end
end

return Storage
