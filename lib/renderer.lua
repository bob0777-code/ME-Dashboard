local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Theme=Loader.load("lib.theme")
local Config=Loader.load("lib.config")

local Renderer={}
local monitor=nil
local width=0
local height=0
local buffer={}
local oldBuffer={}

local function ensureMonitor()
 if monitor then return end
 Peripherals.refresh()
 monitor=Peripherals.monitor or term
 if not monitor then error("No monitor or terminal found") end
 if monitor.setTextScale then monitor.setTextScale(Config.textScale or 0.5) end
 monitor.setBackgroundColor(Theme.background)
 monitor.setTextColor(Theme.text)
 monitor.clear()
 width,height=monitor.getSize()
end

local function same(a,b)
 if a==nil and b==nil then return true end
 if a==nil or b==nil then return false end
 return a.char==b.char and a.fg==b.fg and a.bg==b.bg
end

local function inBounds(x,y)
 return x>=1 and y>=1 and x<=width and y<=height
end

function Renderer.init()
 monitor=nil
 buffer={}
 oldBuffer={}
 ensureMonitor()
end

function Renderer.begin()
 ensureMonitor()
 local w,h=monitor.getSize()
 if w~=width or h~=height then
  width,height=w,h
  oldBuffer={}
  monitor.clear()
 end
 buffer={}
end

function Renderer.setCell(x,y,char,fg,bg)
 ensureMonitor()
 if not inBounds(x,y) then return end
 buffer[y]=buffer[y] or {}
 buffer[y][x]={char=char or " ",fg=fg or Theme.text,bg=bg or Theme.background}
end

function Renderer.write(x,y,text,fg,bg)
 text=tostring(text or "")
 for i=1,#text do
  Renderer.setCell(x+i-1,y,text:sub(i,i),fg,bg)
 end
end

function Renderer.fill(x,y,w,h,char,fg,bg)
 for yy=y,y+h-1 do
  for xx=x,x+w-1 do
   Renderer.setCell(xx,yy,char or " ",fg,bg)
  end
 end
end

function Renderer.hLine(x,y,w,fg,bg)
 Renderer.fill(x,y,w,1,"-",fg,bg)
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
 text=tostring(text or "")
 local x=math.floor((width-#text)/2)+1
 Renderer.write(x,y,text,fg,bg)
end

function Renderer.getSize()
 ensureMonitor()
 return width,height
end

function Renderer.endFrame()
 ensureMonitor()
 for y=1,height do
  for x=1,width do
   local new=buffer[y] and buffer[y][x]
   local old=oldBuffer[y] and oldBuffer[y][x]
   if not same(new,old) then
    monitor.setCursorPos(x,y)
    if new then
     monitor.setTextColor(new.fg)
     monitor.setBackgroundColor(new.bg)
     monitor.write(new.char)
    else
     monitor.setTextColor(Theme.text)
     monitor.setBackgroundColor(Theme.background)
     monitor.write(" ")
    end
    oldBuffer[y]=oldBuffer[y] or {}
    oldBuffer[y][x]=new
   end
  end
 end
end

return Renderer
