local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Theme=Loader.load("lib.theme")
local Config=Loader.load("lib.config")
local Renderer={}
local monitor=nil
local width=0
local height=0

local function ensure()
 Peripherals.refresh()
 monitor=Peripherals.monitor or term
 if monitor.setTextScale then monitor.setTextScale(Config.textScale or 0.5) end
 monitor.setBackgroundColor(Theme.background)
 monitor.setTextColor(Theme.text)
 width,height=monitor.getSize()
end

function Renderer.init()
 ensure()
 monitor.clear()
end

function Renderer.begin()
 ensure()
 monitor.setBackgroundColor(Theme.background)
 monitor.setTextColor(Theme.text)
 monitor.clear()
end

function Renderer.endFrame()
end

function Renderer.getSize()
 ensure()
 return width,height
end

function Renderer.write(x,y,text,fg,bg)
 ensure()
 if x<1 or y<1 or x>width or y>height then return end
 monitor.setCursorPos(x,y)
 monitor.setTextColor(fg or Theme.text)
 monitor.setBackgroundColor(bg or Theme.background)
 monitor.write(tostring(text or ""))
end

function Renderer.fill(x,y,w,h,ch,fg,bg)
 for yy=y,y+h-1 do
  Renderer.write(x,yy,string.rep(ch or " ",w),fg,bg)
 end
end

function Renderer.hLine(x,y,w,fg,bg)
 Renderer.write(x,y,string.rep("-",math.max(0,w)),fg,bg)
end

function Renderer.box(x,y,w,h,fg,bg)
 if w<2 or h<2 then return end
 Renderer.write(x,y,"+"..string.rep("-",w-2).."+",fg,bg)
 for yy=y+1,y+h-2 do
  Renderer.write(x,yy,"|",fg,bg)
  Renderer.write(x+w-1,yy,"|",fg,bg)
 end
 Renderer.write(x,y+h-1,"+"..string.rep("-",w-2).."+",fg,bg)
end

function Renderer.center(y,text,fg,bg)
 ensure()
 text=tostring(text or "")
 Renderer.write(math.floor((width-#text)/2)+1,y,text,fg,bg)
end

return Renderer
