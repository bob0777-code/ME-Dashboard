local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")
local Colony={}

local function call(obj,names)
 for _,name in ipairs(names) do
  if obj and type(obj[name])=="function" then
   local ok,result=pcall(function() return obj[name]() end)
   if ok then return result end
  end
 end
 return nil
end

local function getRequests()
 Peripherals.refresh()
 local c=Peripherals.colony
 if not c then return {} end
 local r=call(c,{"getRequests","getrequests","getOpenRequests","getWorkOrders"})
 if type(r)=="table" then return r end
 return {}
end

local function getColonyInfo()
 Peripherals.refresh()
 local c=Peripherals.colony
 if not c then return {} end
 return {
  name=call(c,{"getColonyName","getName"}) or "Unknown Colony",
  citizens=call(c,{"getCitizens","getcitizens"}) or {},
  buildings=call(c,{"getBuildings","getbuildings"}) or {},
  visitors=call(c,{"getVisitors","getvisitors"}) or {}
 }
end

function Colony.draw(area)
 local info=getColonyInfo()
 local requests=getRequests()

 Renderer.write(area.x,area.y,"Colony Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"Colony",Theme.muted)
 Renderer.write(area.x+18,area.y+3,tostring(info.name),Theme.good)

 Renderer.write(area.x,area.y+5,"Citizens",Theme.muted)
 Renderer.write(area.x+18,area.y+5,tostring(type(info.citizens)=="table" and #info.citizens or 0),Theme.header)

 Renderer.write(area.x,area.y+7,"Buildings",Theme.muted)
 Renderer.write(area.x+18,area.y+7,tostring(type(info.buildings)=="table" and #info.buildings or 0),Theme.header)

 Renderer.write(area.x,area.y+9,"Open Requests",Theme.muted)
 Renderer.write(area.x+18,area.y+9,tostring(#requests),#requests>0 and Theme.warning or Theme.good)

 Renderer.write(area.x,area.y+12,"Recent Requests",Theme.header)
 Renderer.hLine(area.x,area.y+13,area.w,Theme.border)

 if #requests==0 then
  Renderer.write(area.x,area.y+15,"No colony requests found.",Theme.good)
  return
 end

 for i=1,math.min(#requests,area.h-16) do
  local r=requests[i]
  local y=area.y+14+i
  local text=textutils.serialize(r)
  text=text:gsub("\n"," ")
  Renderer.write(area.x,y,Utils.padLeft(i..".",3),Theme.warning)
  Renderer.write(area.x+5,y,Utils.truncate(text,area.w-6),Theme.text)
 end
end

return Colony
