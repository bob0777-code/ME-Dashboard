local Loader=dofile("loader.lua")

local Config=Loader.load("lib.config")
local Renderer=Loader.load("lib.renderer")
local Dashboard=Loader.load("pages.dashboard")

Renderer.init()

local function showError(err)
 Renderer.begin()
 local w,h=Renderer.getSize()
 Renderer.box(1,1,w,h,colors.red)
 Renderer.write(4,3,"DASHBOARD ERROR",colors.red)
 Renderer.write(4,5,tostring(err),colors.white)
 Renderer.endFrame()
end

while true do
 local ok,err=pcall(function()
  Dashboard.render()
 end)

 if not ok then
  showError(err)
  sleep(5)
 else
  sleep(Config.refreshRate or 15)
 end
end
