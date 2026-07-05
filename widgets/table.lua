local Loader=dofile("loader.lua")
local Renderer=Loader.load("lib.renderer")
local Utils=Loader.load("lib.utils")
local Theme=Loader.load("lib.theme")

local Table={}

function Table.draw(x,y,width,height,items)
 items=items or {}
 if width<30 then
  Renderer.write(x,y,"Table too small",Theme.bad)
  return
 end

 local nameWidth=width-22
 local amountX=x+width-13
 local trendX=x+width-2

 Renderer.write(x,y,"#",Theme.header)
 Renderer.write(x+4,y,"Item",Theme.header)
 Renderer.write(amountX,y,"Amount",Theme.header)
 Renderer.write(trendX,y,"T",Theme.header)

 Renderer.hLine(x,y+1,width,Theme.border)

 local rows=math.min(#items,height-2)

 for i=1,rows do
  local item=items[i]
  local rowY=y+1+i
  local name=Utils.truncate(item.displayName or item.name or "Unknown",nameWidth)
  local amount=Utils.formatNumber(item.amount or 0)
  local trend=item.trend or "="
  local trendColor=Theme.text

  if trend=="▲" then trendColor=Theme.good end
  if trend=="▼" then trendColor=Theme.bad end

  Renderer.write(x,rowY,Utils.padLeft(i..".",3),Theme.text)
  Renderer.write(x+4,rowY,Utils.padRight(name,nameWidth),Theme.text)
  Renderer.write(amountX,rowY,Utils.padLeft(amount,10),Theme.header)
  Renderer.write(trendX,rowY,trend,trendColor)
 end
end

return Table
