local Loader=dofile("loader.lua")
local Renderer=Loader.load("lib.renderer")
local Utils=Loader.load("lib.utils")
local Theme=Loader.load("lib.theme")
local Data=Loader.load("lib.data")
local TableWidget={}
function TableWidget.draw(x,y,width,height,items) items=items or Data.getTopItems(height) if width<25 then Renderer.write(x,y,"Monitor too small",Theme.bad) return end local nameWidth=width-18 if nameWidth<8 then nameWidth=8 end local maxRows=math.min(#items,height) Renderer.write(x,y,Utils.padRight("#",3),Theme.highlight) Renderer.write(x+4,y,Utils.padRight("Item",nameWidth),Theme.highlight) Renderer.write(x+width-11,y,Utils.padLeft("Amount",8),Theme.highlight) Renderer.write(x+width-2,y,"T",Theme.highlight) for i=1,maxRows-1 do local item=items[i] if item then local lineY=y+i local name=Utils.truncate(item.displayName or item.name or "Unknown",nameWidth) local amount=Utils.formatNumber(item.amount or 0) local trend=item.trend or "=" local trendColor=Theme.text if trend=="▲" then trendColor=Theme.good elseif trend=="▼" then trendColor=Theme.bad end Renderer.write(x,lineY,Utils.padLeft(i..".",3),Theme.text) Renderer.write(x+4,lineY,Utils.padRight(name,nameWidth),Theme.text) Renderer.write(x+width-11,lineY,Utils.padLeft(amount,8),Theme.highlight) Renderer.write(x+width-2,lineY,trend,trendColor) end end end
return TableWidget
