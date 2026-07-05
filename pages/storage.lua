local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")

local Storage={}

function Storage.draw(area)
 local items=Data.getTopItems(20)

 Renderer.write(area.x,area.y,"Storage Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"#",Theme.header)
 Renderer.write(area.x+5,area.y+3,"Item",Theme.header)
 Renderer.write(area.x+area.w-18,area.y+3,"Amount",Theme.header)
 Renderer.write(area.x+area.w-3,area.y+3,"T",Theme.header)

 for i=1,math.min(20,#items) do
  local item=items[i]
  local y=area.y+4+i
  local name=Utils.truncate(item.displayName or item.name,area.w-28)
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
