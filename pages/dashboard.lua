local Loader=dofile("loader.lua")
local Config=Loader.load("lib.config")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Storage=Loader.load("pages.storage")
local Colony=Loader.load("pages.colony")
local Crafting=Loader.load("pages.crafting")
local Version=Loader.load("version")

local Dashboard={}
local currentPage="home"

local buttons={
 {name="Home",page="home",x=4},
 {name="Storage",page="storage",x=16},
 {name="Colony",page="colony",x=31},
 {name="Crafting",page="crafting",x=45},
 {name="Search",page="search",x=61},
 {name="Settings",page="settings",x=74}
}

local function drawShell(w,h)
 Renderer.box(1,1,w,h,Theme.border)
 Renderer.center(2,Config.getTitle(),Theme.title)
 Renderer.center(3,"Applied Energistics Control Center",Theme.header)
 Renderer.hLine(3,5,w-4,Theme.border)

 for _,b in ipairs(buttons) do
  local color=currentPage==b.page and Theme.good or Theme.header
  Renderer.write(b.x,7,"[ "..b.name.." ]",color)
 end

 Renderer.hLine(3,9,w-4,Theme.border)
end

local function drawHome(w,h,ok,err)
 local leftX=4
 local leftY=11
 local leftW=48
 local rightX=58
 local rightY=11
 local rightW=w-rightX-4
 local items=Data.getTopItems(5)

 Renderer.write(leftX,leftY,"Storage Overview",Theme.header)
 Renderer.hLine(leftX,leftY+1,leftW,Theme.border)

 Renderer.write(leftX,leftY+3,"Unique Items",Theme.muted)
 Renderer.write(leftX+18,leftY+3,tostring(Data.getItemCount()),Theme.good)

 Renderer.write(leftX,leftY+5,"Top Items",Theme.muted)

 for i=1,math.min(5,#items) do
  local item=items[i]
  local name=item.displayName or item.display_name or item.name or item.id or "Unknown"
  local amount=tonumber(item.amount or item.count) or 0
  Renderer.write(leftX,leftY+6+i,tostring(i)..". "..Utils.truncate(name,28),Theme.text)
  Renderer.write(leftX+34,leftY+6+i,Utils.padLeft(Utils.formatNumber(amount),10),Theme.header)
 end

 Renderer.write(rightX,rightY,"System Status",Theme.header)
 Renderer.hLine(rightX,rightY+1,rightW,Theme.border)

 Renderer.write(rightX,rightY+3,"ME Bridge",Theme.muted)
 Renderer.write(rightX+20,rightY+3,ok and "Online" or "Error",ok and Theme.good or Theme.bad)

 Renderer.write(rightX,rightY+5,"Refresh Rate",Theme.muted)
 Renderer.write(rightX+20,rightY+5,tostring(Config.refreshRate).."s",Theme.header)

 Renderer.write(rightX,rightY+7,"Current Time",Theme.muted)
 Renderer.write(rightX+20,rightY+7,Utils.time(),Theme.header)

 Renderer.write(rightX,rightY+13,"Page Progress",Theme.header)
 Renderer.hLine(rightX,rightY+14,rightW,Theme.border)

 Renderer.write(rightX,rightY+16,"Home",Theme.muted)
 Renderer.write(rightX+22,rightY+16,"Done",Theme.good)

 Renderer.write(rightX,rightY+18,"Storage",Theme.muted)
 Renderer.write(rightX+22,rightY+18,"Done",Theme.good)

 Renderer.write(rightX,rightY+20,"Colony",Theme.muted)
 Renderer.write(rightX+22,rightY+20,"Done",Theme.good)

 Renderer.write(rightX,rightY+22,"Crafting",Theme.muted)
 Renderer.write(rightX+22,rightY+22,"Done",Theme.good)

 Renderer.write(rightX,rightY+24,"Search",Theme.muted)
 Renderer.write(rightX+22,rightY+24,"Done",Theme.good)
end

local function drawPlaceholder(title)
 Renderer.write(4,11,title,Theme.header)
 Renderer.hLine(4,12,80,Theme.border)
 Renderer.write(4,14,"This page is ready to build next.",Theme.warning)
end

function Dashboard.render()
 local ok,err=Data.update()

 if currentPage=="storage" then
  Storage.prepare()
 end

 if currentPage=="colony" then
  Colony.prepare()
 end

 if currentPage=="crafting" then
  Crafting.prepare()
 end

 if currentPage=="search" then
  Search.prepare()
 end

 Renderer.begin()

 local w,h=Renderer.getSize()
 drawShell(w,h)

 if currentPage=="home" then
  drawHome(w,h,ok,err)
 elseif currentPage=="storage" then
  Storage.draw({x=4,y=11,w=w-8,h=h-15})
 elseif currentPage=="colony" then
  Colony.draw({x=4,y=11,w=w-8,h=h-15})
 elseif currentPage=="crafting" then
  Crafting.draw({x=4,y=11,w=w-8,h=h-15})
 elseif currentPage=="search" then
  Search.draw({x=4,y=11,w=w-8,h=h-15})
 elseif currentPage=="settings" then
  drawPlaceholder("Settings Page")
 end

 Renderer.hLine(3,h-2,w-4,Theme.border)
 Renderer.write(4,h-1,"Current Page: "..currentPage,Theme.good)
 Renderer.write(w-35,h-1,"v"..Version.version.." | Refresh: "..tostring(Config.refreshRate).."s",Theme.muted)

 Renderer.endFrame()
end

function Dashboard.handleEvent(event,a,b,c)
 if currentPage=="search" then
  local handled=Search.handleEvent(event,a,b,c)
  if handled then return true end
 end

 if event=="monitor_touch" then
  local x=b
  local y=c
  if y==7 then
   for _,btn in ipairs(buttons) do
    local len=#("[ "..btn.name.." ]")
    if x>=btn.x and x<=btn.x+len then
     currentPage=btn.page
     return true
    end
   end
  end
 end

 if event=="key" then
  if a==keys.one then currentPage="home" return true end
  if a==keys.two then currentPage="storage" return true end
  if a==keys.three then currentPage="colony" return true end
  if a==keys.four then currentPage="crafting" return true end
  if a==keys.five then currentPage="search" return true end
  if a==keys.six then currentPage="settings" return true end
 end

 return false
end

return Dashboard
