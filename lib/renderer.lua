local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Theme=Loader.load("lib.theme")
local Config=Loader.load("lib.config")
local Renderer={}
local monitor=nil
local width=0
local height=0
local buffer={}
local old={}
local function ensure()
 if monitor then return end
 Peripherals.refresh()
 monitor=Peripherals.monitor or term
 if monitor.setTextScale then monitor.setTextScale(Config.textScale or 0.5) end
 monitor.setBackgroundColor(Theme.background)
 monitor.setTextColor(Theme.text)
 monitor.clear()
 width,height=monitor.getSize()
end
local function same(a,b)
 if a==nil and b==nil then return true end
 if a==nil or b==nil then return false end
 return a.t==b.t and a.f==b.f and a.b==b.b
end
function Renderer.init() monitor=nil buffer={} old={} ensure() end
function Renderer.begin()
 ensure()
 local w,h=monitor.getSize()
 if w~=width or h~=height then width,height=w,h old={} monitor.clear() end
 buffer={}
end
function Renderer.endFrame()
 ensure()
 for y=1,height do
  for x=1,width do
   local n=buffer[y] and buffer[y][x]
   local o=old[y] and old[y][x]
   if not same(n,o) then
    monitor.setCursorPos(x,y)
    if n then
     monitor.setTextColor(n.f)
     monitor.setBackgroundColor(n.b)
     monitor.write(n.t)
    else
     monitor.setTextColor(Theme.text)
     monitor.setBackgroundColor(Theme.background)
     monitor.write(" ")
    end
    old[y]=old[y] or {}
    old[y][x]=n
   end
  end
 end
end
function Renderer.getSize() ensure() return width,height end
function Renderer.cell(x,y,ch,fg,bg)
 ensure()
 if x<1 or y<1 or x>width or y>height then return end
 buffer[y]=buffer[y] or {}
 buffer[y][x]={t=ch or " ",f=fg or Theme.text,b=bg or Theme.background}
end
function Renderer.write(x,y,text,fg,bg)
 text=tostring(text or "")
 for i=1,#text do Renderer.cell(x+i-1,y,text:sub(i,i),fg,bg) end
end
function Renderer.fill(x,y,w,h,ch,fg,bg)
 for yy=y,y+h-1 do for xx=x,x+w-1 do Renderer.cell(xx,yy,ch or " ",fg,bg) end end
end
function Renderer.hLine(x,y,w,fg,bg) Renderer.write(x,y,string.rep("-",math.max(0,w)),fg,bg) end
function Renderer.box(x,y,w,h,fg,bg)
 if w<2 or h<2 then return end
 Renderer.write(x,y,"+"..string.rep("-",w-2).."+",fg,bg)
 for yy=y+1,y+h-2 do Renderer.write(x,yy,"|",fg,bg) Renderer.write(x+w-1,yy,"|",fg,bg) end
 Renderer.write(x,y+h-1,"+"..string.rep("-",w-2).."+",fg,bg)
end
function Renderer.center(y,text,fg,bg)
 ensure()
 text=tostring(text or "")
 Renderer.write(math.floor((width-#text)/2)+1,y,text,fg,bg)
end
return Renderer
