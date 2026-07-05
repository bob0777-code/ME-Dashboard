local Loader=dofile("loader.lua")
local Config=Loader.load("lib.config")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")
local Storage=Loader.load("pages.storage")

local Dashboard={}
local currentPage="home"

local buttons={
 {name="Home",page="home",x=4},
 {name="Storage",page="storage",x=15},
 {name="Colony",page="colony",x=29},
 {name="Crafting",page="crafting",x=42},
 {name="Search",page="search",x=58},
 {name="Settings",page="settings",x=70}
}

local function drawHeader(w)
 Renderer.center(2,Config.getTitle(),Theme.title)
 Renderer.center(3,"Applied Energistics Control Center",Theme.header)
 Renderer.hLine(3,5,w-4,Theme.border)
end

local function drawNav()
 local y=7
 for _,b in ipairs(buttons) do
  local text="[ "..b.name.." ]"
  local color=currentPage==b.page and Theme.good or Theme.header
  Renderer.write(b.x,y,text,color)
 end
end

local function drawHome(area,ok,err)
 local items=Data.getTopItems(5)

 Renderer.write(area.x,area.y,"Home Dashboard",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"Unique Items",Theme.muted)
 Renderer.write(area.x+18,area.y+3,tostring(Data.getItemCount()),Theme.good)

 Renderer.write(area.x,area.y+5,"Status",Theme.muted)
 Renderer.write(area.x+18,area.y+5,ok and "Online" or "Error",ok and Theme.good or Theme.bad)

 Renderer.write(area.x,area.y+7,"Top Items",Theme.muted)

 for i=1,math.min(5,#items) do
  local item=items[i]
  Renderer.write(area.x,area.y+8+i,tostring(i)..". "..Utils.truncate(item.displayName or item.name,35),Theme.text)
  Renderer.write(area.x+45,area.y+8+i,Utils.formatNumber(item.amount),Theme.header)
 end

 Renderer.write(area.x,area.y+16,"Use monitor touch or number keys:",Theme.muted)
 Renderer.write(area.x,area.y+18,"1 Home  2 Storage  3 Colony  4 Crafting  5 Search  6 Settings",Theme.header)
end

local function drawPlaceholder(area,title)
 Renderer.write(area.x,area.y,title,Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)
 Renderer.write(area.x,area.y+3,"This page is ready to build next.",Theme.warning)
end

function Dashboard.render()
 local ok,err=Data.update()

 Renderer.begin()

 local w,h=Renderer.getSize()
 local area={x=4,y=10,w=w-8,h=h-14}

 Renderer.box(1,1,w,h,Theme.border)
 drawHeader(w)
 drawNav()
 Renderer.hLine(3,9,w-4,Theme.border)

 if currentPage=="home" then
  drawHome(area,ok,err)
 elseif currentPage=="storage" then
  Storage.draw(area)
 elseif currentPage=="colony" then
  drawPlaceholder(area,"Colony Page")
 elseif currentPage=="crafting" then
  drawPlaceholder(area,"Crafting Page")
 elseif currentPage=="search" then
  drawPlaceholder(area,"Search Page")
 elseif currentPage=="settings" then
  drawPlaceholder(area,"Settings Page")
 end

 Renderer.hLine(3,h-2,w-4,Theme.border)
 Renderer.write(4,h-1,"Current Page: "..currentPage,Theme.good)
 Renderer.write(w-25,h-1,"Refresh: "..tostring(Config.refreshRate).."s",Theme.muted)

 Renderer.endFrame()
end

function Dashboard.handleEvent(event,a,b,c)
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
