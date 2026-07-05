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

local function render()
 local ok,err=pcall(function()
  Dashboard.render()
 end)

 if not ok then
  showError(err)
 end
end

render()

local timer=os.startTimer(Config.refreshRate or 15)

while true do
 local event,a,b,c=os.pullEvent()

 if event=="timer" and a==timer then
  render()
  timer=os.startTimer(Config.refreshRate or 15)
 else
  local ok,changed=pcall(function()
   return Dashboard.handleEvent(event,a,b,c)
  end)

  if ok and changed then
   render()
  end
 end
end
