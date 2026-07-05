local Loader=dofile("loader.lua")
local Config=Loader.load("lib.config")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")

local Dashboard={}

function Dashboard.render()
 local ok,err=Data.update()

 Renderer.begin()

 local w,h=Renderer.getSize()
 local items=Data.getTopItems(Config.topItems or 10)

 Renderer.box(1,1,w,h,Theme.border)
 Renderer.center(2,Config.title,Theme.title)
 Renderer.write(4,4,"Items found: "..tostring(Data.getItemCount()),Theme.good)
 Renderer.write(w-18,4,"Time: "..Utils.time(),Theme.header)
 Renderer.hLine(3,5,w-4,Theme.border)

 Renderer.write(4,7,"Top Stored Items",Theme.header)
 Renderer.write(4,9,"#",Theme.header)
 Renderer.write(9,9,"Item",Theme.header)
 Renderer.write(w-28,9,"Amount",Theme.header)
 Renderer.write(w-8,9,"T",Theme.header)
 Renderer.hLine(4,10,w-8,Theme.border)

 for i=1,math.min(10,#items) do
  local item=items[i]
  local y=10+i
  local name=Utils.truncate(item.displayName or item.name or "Unknown",45)
  local amount=Utils.formatNumber(item.amount or 0)
  local trend=item.trend or "="
  local trendColor=Theme.text

  if trend=="▲" then trendColor=Theme.good end
  if trend=="▼" then trendColor=Theme.bad end

  Renderer.write(4,y,Utils.padLeft(i..".",3),Theme.text)
  Renderer.write(9,y,Utils.padRight(name,45),Theme.text)
  Renderer.write(w-30,y,Utils.padLeft(amount,12),Theme.header)
  Renderer.write(w-8,y,trend,trendColor)
 end

 Renderer.hLine(3,h-2,w-4,Theme.border)

 if ok then
  Renderer.write(4,h-1,"Status: Online",Theme.good)
 else
  Renderer.write(4,h-1,"Status: "..tostring(err),Theme.bad)
 end

 Renderer.write(w-25,h-1,"Refresh: 15s",Theme.muted)

 Renderer.endFrame()
end

return Dashboard
