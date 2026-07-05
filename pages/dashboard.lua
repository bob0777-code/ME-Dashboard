local Loader=dofile("loader.lua")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Utils=Loader.load("lib.utils")
local Theme=Loader.load("lib.theme")
local TableWidget=Loader.load("widgets.table")
local Dashboard={}
function Dashboard.render()
Data.update()
Renderer.begin()
local w,h=Renderer.getSize()
Renderer.write(2,1,"Silicon Reach ME Dashboard",Theme.title)
Renderer.write(2,2,"Items found: "..tostring(Data.getItemCount()),Theme.good)
Renderer.write(2,3,"Updated: "..Utils.currentTime(),Theme.highlight)
Renderer.write(2,5,"Top Stored Items",Theme.text)
TableWidget.draw(2,7,w-4,math.min(10,h-8),Data.getTopItems(10))
Renderer.endFrame()
end
return Dashboard
