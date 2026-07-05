local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")

local Crafting={}

local cachedTasks={}

local function call(obj,names)
 for _,name in ipairs(names) do
  if obj and type(obj[name])=="function" then
   local ok,result=pcall(function() return obj[name]() end)
   if ok then return result end
  end
 end
 return nil
end

local function getTasks()
 Peripherals.refresh()
 local me=Peripherals.me
 if not me then return {} end
 local tasks=call(me,{"getCraftingTasks","getCraftingTask"})
 if type(tasks)=="table" then return tasks end
 return {}
end

local function taskName(t)
 return t.name or t.item or t.displayName or t.display_name or t.output or "Unknown Craft"
end

local function taskAmount(t)
 return tonumber(t.amount or t.count or t.remaining or t.toCraft or 0) or 0
end

local function taskStatus(t)
 return t.status or t.state or t.craftingState or "ACTIVE"
end

function Crafting.prepare()
 cachedTasks=getTasks()
end

function Crafting.draw(area)
 local tasks=cachedTasks

 Renderer.write(area.x,area.y,"Crafting Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"Active Crafting Jobs",Theme.header)
 Renderer.write(area.x+24,area.y+3,tostring(#tasks),#tasks>0 and Theme.warning or Theme.good)

 Renderer.hLine(area.x,area.y+5,area.w,Theme.border)

 Renderer.write(area.x,area.y+7,"#",Theme.header)
 Renderer.write(area.x+5,area.y+7,"Craft",Theme.header)
 Renderer.write(area.x+45,area.y+7,"Amount",Theme.header)
 Renderer.write(area.x+60,area.y+7,"Status",Theme.header)
 Renderer.hLine(area.x,area.y+8,area.w,Theme.border)

 if #tasks==0 then
  Renderer.write(area.x,area.y+10,"No active crafting jobs.",Theme.good)
  return
 end

 local rowColors={colors.lime,colors.cyan,colors.lightBlue,colors.yellow,colors.orange,colors.magenta}

 for i=1,math.min(#tasks,area.h-10) do
  local t=tasks[i]
  local y=area.y+8+i
  local color=rowColors[((i-1)%#rowColors)+1]

  Renderer.write(area.x,y,Utils.padLeft(i..".",3),color)
  Renderer.write(area.x+5,y,Utils.truncate(taskName(t),36),color)
  Renderer.write(area.x+45,y,Utils.padLeft(Utils.formatNumber(taskAmount(t)),10),Theme.header)
  Renderer.write(area.x+60,y,Utils.truncate(taskStatus(t),18),Theme.warning)
 end
end

return Crafting
