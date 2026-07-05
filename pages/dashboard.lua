local Loader=dofile("loader.lua")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Utils=Loader.load("lib.utils")
local Theme=Loader.load("lib.theme")
local TableWidget=Loader.load("widgets.table")
local Dashboard={}
local function drawHeader()
local w,h=Renderer.getSize()
Renderer.write(2,1,"Silicon Reach ME Dashboard",Theme.title)
Renderer.write(2,2,"If you can read this, renderer works",Theme.good)
end
local function drawContent()
local w,h=Renderer.getSize()
local ok=Data.update()
Renderer.write(2,4,"Data update: "..tostring(ok),ok and Theme.good or Theme.bad)
Renderer.write(2,5,"Item count: "..tostring(Data.getItemCount()),Theme.text)
local topItems=Data.getTopItems(10)
if #topItems==0 then
Renderer.write(2,7,"No items found from ME bridge",Theme.bad)
else
TableWidget.draw(2,7,w-4,math.min(10,h-8),topItems)
end
end
function Dashboard.render()
Renderer.begin()
drawHeader()
drawContent()
Renderer.endFrame()
end
return Dashboard
