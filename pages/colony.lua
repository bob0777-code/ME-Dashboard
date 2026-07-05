local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")

local Colony={}

local cachedInfo={}
local cachedRequests={}

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

local function getInfo()
 Peripherals.refresh()
 local c=Peripherals.colony
 if not c then return {name="No Colony Integrator",citizens={},buildings={}} end
 return {
  name=call(c,{"getColonyName","getName"}) or "Unknown Colony",
  citizens=call(c,{"getCitizens","getcitizens"}) or {},
  buildings=call(c,{"getBuildings","getbuildings"}) or {}
 }
end

local function requestName(r)
 return r.name or r.item or r.displayName or r.desc or "Unknown Request"
end

local function requestTarget(r)
 return r.target or r.building or r.citizen or r.requester or "Unknown"
end

local function requestState(r)
 return r.state or r.status or "UNKNOWN"
end

function Colony.prepare()
 cachedInfo=getInfo()
 cachedRequests=getRequests()
end

function Colony.draw(area)
 local info=cachedInfo
 local requests=cachedRequests

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

 Renderer.write(area.x,area.y+15,"#",Theme.header)
 Renderer.write(area.x+5,area.y+15,"Item",Theme.header)
 Renderer.write(area.x+35,area.y+15,"Target",Theme.header)
 Renderer.write(area.x+58,area.y+15,"State",Theme.header)
 Renderer.hLine(area.x,area.y+16,area.w,Theme.border)

 if #requests==0 then
  Renderer.write(area.x,area.y+18,"No colony requests found.",Theme.good)
  return
 end

 local rowColors={colors.lime,colors.cyan,colors.lightBlue,colors.yellow,colors.orange,colors.magenta}

 for i=1,math.min(#requests,area.h-18) do
  local r=requests[i]
  local y=area.y+16+i
  local color=rowColors[((i-1)%#rowColors)+1]

  Renderer.write(area.x,y,Utils.padLeft(i..".",3),color)
  Renderer.write(area.x+5,y,Utils.truncate(requestName(r),28),color)
  Renderer.write(area.x+35,y,Utils.truncate(requestTarget(r),20),Theme.text)
  Renderer.write(area.x+58,y,Utils.truncate(requestState(r),16),Theme.warning)
 end
end

return Colony
