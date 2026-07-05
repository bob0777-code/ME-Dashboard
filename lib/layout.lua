local Loader=dofile("loader.lua")
local Renderer=Loader.load("lib.renderer")

local Layout={}

function Layout.get()
 local w,h=Renderer.getSize()

 return {
  screen={x=1,y=1,w=w,h=h},

  border={x=1,y=1,w=w,h=h},

  header={x=3,y=2,w=w-4,h=4},

  content={x=4,y=7,w=w-8,h=h-12},

  footer={x=3,y=h-2,w=w-4,h=2},

  leftPanel={x=4,y=7,w=math.floor((w-10)*0.65),h=h-12},

  rightPanel={x=math.floor((w-10)*0.65)+6,y=7,w=w-math.floor((w-10)*0.65)-9,h=h-12}
 }
end

return Layout
