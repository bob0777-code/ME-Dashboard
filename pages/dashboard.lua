local Loader=dofile("loader.lua")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Utils=Loader.load("lib.utils")
local Theme=Loader.load("lib.theme")
local Dashboard={}

function Dashboard.render()
Data.update()
Renderer.begin()

local w,h=Renderer.getSize()
local items=Data.getTopItems(10)

Renderer.write(2,1,"Silicon Reach ME Dashboard",Theme.title)
Renderer.write(2,2,"Items found: "..tostring(Data.getItemCount()),Theme.good)
Renderer.write(2,3,"Top item test: "..tostring(items[1] and items[1].displayName or "NONE"),Theme.warning)
Renderer.write(2,5,"Top Stored Items",Theme.text)

Renderer.write(2,7,"#  Item",Theme.highlight)
Renderer.write(55,7,"Amount",Theme.highlight)
Renderer.write(68,7,"T",Theme.highlight)

for i=1,math.min(10,#items) do
local item=items[i]
local y=7+i
local name=Utils.truncate(item.displayName or item.name or "Unknown",45)
local amount=Utils.formatNumber(item.amount or 0)
local trend=item.trend or "="
local trendColor=Theme.text

if trend=="▲" then trendColor=Theme.good end
if trend=="▼" then trendColor=Theme.bad end

Renderer.write(2,y,Utils.padLeft(i..".",3),Theme.text)
Renderer.write(6,y,Utils.padRight(name,45),Theme.text)
Renderer.write(55,y,Utils.padLeft(amount,10),Theme.highlight)
Renderer.write(68,y,trend,trendColor)
end

Renderer.endFrame()
end

return Dashboard
