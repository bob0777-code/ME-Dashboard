local Loader=dofile("loader.lua")
local Renderer=Loader.load("lib.renderer")
local Utils=Loader.load("lib.utils")
local Theme=Loader.load("lib.theme")
local TableWidget={}

function TableWidget.draw(x,y,width,height,items)
    items=items or {}
    Renderer.write(x,y,"#  Item"..string.rep(" ",math.max(1,width-20)).."Amount  T",Theme.highlight)

    local rows=math.min(#items,height-1)

    for i=1,rows do
        local item=items[i]
        local lineY=y+i
        local name=Utils.truncate(item.displayName or item.name or "Unknown",width-18)
        local amount=Utils.formatNumber(item.amount or 0)
        local trend=item.trend or "="
        local trendColor=Theme.text

        if trend=="▲" then trendColor=Theme.good end
        if trend=="▼" then trendColor=Theme.bad end

        Renderer.write(x,lineY,Utils.padLeft(i..".",3),Theme.text)
        Renderer.write(x+4,lineY,Utils.padRight(name,width-18),Theme.text)
        Renderer.write(x+width-11,lineY,Utils.padLeft(amount,8),Theme.highlight)
        Renderer.write(x+width-2,lineY,trend,trendColor)
    end
end

return TableWidget
