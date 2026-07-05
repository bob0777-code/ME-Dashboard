local Loader=dofile("loader.lua")
local Renderer=Loader.load("lib.renderer")
local Utils=Loader.load("lib.utils")
local Theme=Loader.load("lib.theme")
local TableWidget={}
function TableWidget.draw(x,y,width,height,items)
items=items or {}
Renderer.write(x,y,"TABLE ROWS: "..tostring(#items),Theme.warning)
for i=1,math.min(#items,10) do
local item=items[i]
local lineY=y+i
local name=Utils.truncate(item.displayName or item.name or "Unknown",40)
local amount=Utils.formatNumber(item.amount or 0)
local trend=item.trend or "="
Renderer.write(x,lineY,tostring(i)..". "..name.."  "..amount.."  "..trend,Theme.text)
end
end
return TableWidget
