local Loader=dofile("loader.lua")
local Config=Loader.load("lib.config")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Layout=Loader.load("lib.layout")

local Dashboard={}

local function drawHeader(w)
 Renderer.center(2,"Kingdom of Silicon Reach",Theme.title)
 Renderer.center(3,"Applied Energistics Control Center",Theme.header)
 Renderer.hLine(3,5,w-4,Theme.border)
end

local function drawNav(w)
 local y=7
 local buttons={"[ Home ]","[ Storage ]","[ Colony ]","[ Crafting ]","[ Search ]","[ Settings ]"}
 local x=4
 for _,b in ipairs(buttons) do
  Renderer.write(x,y,b,Theme.header)
  x=x+#b+3
 end
 Renderer.hLine(3,9,w-4,Theme.border)
end

local function drawStorageSummary(x,y,w)
 local items=Data.getTopItems(5)

 Renderer.write(x,y,"Storage Overview",Theme.header)
 Renderer.hLine(x,y+1,w,Theme.border)

 Renderer.write(x,y+3,"Unique Items",Theme.muted)
 Renderer.write(x+18,y+3,tostring(Data.getItemCount()),Theme.good)

 Renderer.write(x,y+5,"Top Items",Theme.muted)

 for i=1,math.min(5,#items) do
  local item=items[i]
  Renderer.write(x,y+6+i,tostring(i)..". "..Utils.truncate(item.displayName or item.name,28),Theme.text)
  Renderer.write(x+w-12,y+6+i,Utils.padLeft(Utils.formatNumber(item.amount),10),Theme.header)
 end
end

local function drawSystemSummary(x,y,w,ok,err)
 Renderer.write(x,y,"System Status",Theme.header)
 Renderer.hLine(x,y+1,w,Theme.border)

 Renderer.write(x,y+3,"ME Bridge",Theme.muted)
 Renderer.write(x+18,y+3,ok and "Online" or "Error",ok and Theme.good or Theme.bad)

 Renderer.write(x,y+5,"Refresh Rate",Theme.muted)
 Renderer.write(x+18,y+5,tostring(Config.refreshRate).."s",Theme.header)

 Renderer.write(x,y+7,"Current Time",Theme.muted)
 Renderer.write(x+18,y+7,Utils.time(),Theme.header)

 if not ok then
  Renderer.write(x,y+10,Utils.truncate(tostring(err),w),Theme.bad)
 end
end

local function drawFuturePanels(x,y,w)
 Renderer.write(x,y,"Coming Soon",Theme.header)
 Renderer.hLine(x,y+1,w,Theme.border)

 Renderer.write(x,y+3,"Colony Requests",Theme.muted)
 Renderer.write(x+22,y+3,"Pending",Theme.warning)

 Renderer.write(x,y+5,"Crafting Jobs",Theme.muted)
 Renderer.write(x+22,y+5,"Pending",Theme.warning)

 Renderer.write(x,y+7,"Energy Stats",Theme.muted)
 Renderer.write(x+22,y+7,"Pending",Theme.warning)

 Renderer.write(x,y+9,"Touch Navigation",Theme.muted)
 Renderer.write(x+22,y+9,"Next",Theme.good)
end

function Dashboard.render()
 local ok,err=Data.update()

 Renderer.begin()

 local w,h=Renderer.getSize()

 Renderer.box(1,1,w,h,Theme.border)
 drawHeader(w)
 drawNav(w)

 local leftW=math.floor((w-10)*0.55)
 local rightW=w-leftW-12

 drawStorageSummary(4,11,leftW)
 drawSystemSummary(leftW+8,11,rightW,ok,err)
 drawFuturePanels(leftW+8,25,rightW)

 Renderer.hLine(3,h-2,w-4,Theme.border)
 Renderer.write(4,h-1,"Home Dashboard Ready",Theme.good)
 Renderer.write(w-30,h-1,"Next: Sub Pages",Theme.muted)

 Renderer.endFrame()
end

return Dashboard
