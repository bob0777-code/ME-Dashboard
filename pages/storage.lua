local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")

local Storage={}

local function drawBar(x,y,label,value,max,width)
 Renderer.write(x,y,label,Theme.muted)
 Renderer.write(x+18,y,Utils.bar(value,max,width),Theme.good)
 Renderer.write(x+18+width+2,y,Utils.formatNumber(value).."/"..Utils.formatNumber(max),Theme.header)
end

function Storage.draw(area)
 local items=Data.getTopItems(20)
 local stats=Data.getStats()

 Renderer.write(area.x,area.y,"Storage Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"ME Storage Stats",Theme.header)

 local energy=stats.energy
 if type(energy)=="table" then
  drawBar(area.x,area.y+5,"Power",energy.stored or energy.amount or 0,energy.capacity or energy.max or 1,30)
 else
  Renderer.write(area.x,area.y+5,"Power",Theme.muted)
  Renderer.write(area.x+18,area.y+5,tostring(energy or "Unknown"),Theme.header)
 end

 local itemStorage=stats.itemStorage
 if type(itemStorage)=="table" then
  drawBar(area.x,area.y+7,"Item Storage",itemStorage.used or itemStorage.stored or 0,itemStorage.total or itemStorage.capacity or 1,30)
 else
  Renderer.write(area.x,area.y+7,"Item Storage",Theme.muted)
  Renderer.write(area.x+18,area.y+7,tostring(itemStorage or "Unknown"),Theme.header)
 end

 local fluidStorage=stats.fluidStorage
 if type(fluidStorage)=="table" then
  drawBar(area.x,area.y+9,"Fluid Storage",fluidStorage.used or fluidStorage.stored or 0,fluidStorage.total or fluidStorage.capacity or 1,30)
 else
  Renderer.write(area.x,area.y+9,"Fluid Storage",Theme.muted)
  Renderer.write(area.x+18,area.y+9,tostring(fluidStorage or "Unknown"),Theme.header)
 end

 Renderer.write(area.x,area.y+12,"Top Stored Items",Theme.header)
 Renderer.hLine(area.x,area.y+13,area.w,Theme.border)

 Renderer.write(area.x,area.y+15,"#",Theme.header)
 Renderer.write(area.x+5,area.y+15,"Item",Theme.header)
 Renderer.write(area.x+area.w-18,area.y+15,"Amount",Theme.header)
 Renderer.write(area.x+area.w-3,area.y+15,"T",Theme.header)

 for i=1,math.min(20,#items) do
  local item=items[i]
  local y=area.y+15+i
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
