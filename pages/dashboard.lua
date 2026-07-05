local Loader=dofile("loader.lua")
local Config=Loader.load("lib.config")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Layout=Loader.load("lib.layout")

local Dashboard={}

local function drawTopItems(area,items)
 Renderer.write(area.x,area.y,"Top Stored Items",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"#",Theme.header)
 Renderer.write(area.x+5,area.y+3,"Item",Theme.header)
 Renderer.write(area.x+area.w-18,area.y+3,"Amount",Theme.header)
 Renderer.write(area.x+area.w-3,area.y+3,"T",Theme.header)

 local nameWidth=area.w-28

 for i=1,math.min(10,#items) do
  local item=items[i]
  local y=area.y+4+i
  local name=Utils.truncate(item.displayName or item.name or "Unknown",nameWidth)
  local amount=Utils.formatNumber(item.amount or 0)
  local trend=item.trend or "="
  local trendColor=Theme.text

  if trend=="▲" then trendColor=Theme.good end
  if trend=="▼" then trendColor=Theme.bad end

  Renderer.write(area.x,y,Utils.padLeft(i..".",3),Theme.text)
  Renderer.write(area.x+5,y,Utils.padRight(name,nameWidth),Theme.text)
  Renderer.write(area.x+area.w-20,y,Utils.padLeft(amount,10),Theme.header)
  Renderer.write(area.x+area.w-3,y,trend,trendColor)
 end
end

local function drawStats(area,ok,err)
 Renderer.write(area.x,area.y,"System Stats",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"ME Items",Theme.muted)
 Renderer.write(area.x+18,area.y+3,tostring(Data.getItemCount()),Theme.good)

 Renderer.write(area.x,area.y+5,"Status",Theme.muted)

 if ok then
  Renderer.write(area.x+18,area.y+5,"Online",Theme.good)
 else
  Renderer.write(area.x+18,area.y+5,"Error",Theme.bad)
  Renderer.write(area.x,area.y+7,Utils.truncate(tostring(err),area.w),Theme.bad)
 end

 Renderer.write(area.x,area.y+9,"Refresh",Theme.muted)
 Renderer.write(area.x+18,area.y+9,tostring(Config.refreshRate).."s",Theme.header)

 Renderer.write(area.x,area.y+11,"Time",Theme.muted)
 Renderer.write(area.x+18,area.y+11,Utils.time(),Theme.header)
end

function Dashboard.render()
 local ok,err=Data.update()

 Renderer.begin()

 local l=Layout.get()
 local items=Data.getTopItems(Config.topItems or 10)

 Renderer.box(l.border.x,l.border.y,l.border.w,l.border.h,Theme.border)

 Renderer.center(2,Config.title,Theme.title)
 Renderer.hLine(3,5,l.screen.w-4,Theme.border)

 drawTopItems(l.leftPanel,items)
 drawStats(l.rightPanel,ok,err)

 Renderer.hLine(3,l.screen.h-2,l.screen.w-4,Theme.border)
 Renderer.write(4,l.screen.h-1,"Dashboard running",Theme.good)
 Renderer.write(l.screen.w-25,l.screen.h-1,"Refresh: "..tostring(Config.refreshRate).."s",Theme.muted)

 Renderer.endFrame()
end

return Dashboard
