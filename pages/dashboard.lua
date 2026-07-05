local Loader=dofile("loader.lua")
local Config=Loader.load("lib.config")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Table=Loader.load("widgets.table")

local Dashboard={}

local function drawHeader(w)
 Renderer.center(2,Config.title,Theme.title)
 Renderer.write(4,4,"Items found: "..tostring(Data.getItemCount()),Theme.good)
 Renderer.write(w-18,4,"Time: "..Utils.time(),Theme.header)
 Renderer.hLine(3,5,w-4,Theme.border)
end

local function drawFooter(w,h,ok,err)
 Renderer.hLine(3,h-2,w-4,Theme.border)
 if ok then
  Renderer.write(4,h-1,"Status: Online",Theme.good)
 else
  Renderer.write(4,h-1,"Status: "..tostring(err),Theme.bad)
 end
 Renderer.write(w-25,h-1,"Refresh: 15s",Theme.muted)
end

function Dashboard.render()
 local ok,err=Data.update()

 Renderer.begin()

 local w,h=Renderer.getSize()

 Renderer.box(1,1,w,h,Theme.border)
 drawHeader(w)

 Renderer.write(4,7,"Top Stored Items",Theme.header)
 Table.draw(4,9,w-8,math.min(14,h-12),Data.getTopItems(Config.topItems))

 drawFooter(w,h,ok,err)

 Renderer.endFrame()
end

return Dashboard
