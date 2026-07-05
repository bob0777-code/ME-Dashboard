local Loader=dofile("loader.lua")
local Theme=Loader.load("lib.theme")
local Utils=Loader.load("lib.utils")
local Data=Loader.load("lib.data")
local Renderer=Loader.load("lib.renderer")

local Search={}
local query=""
local results={}

function Search.prepare()
 if query=="" then
  results=Data.getTopItems(30)
 else
  results=Data.search(query)
 end
end

function Search.draw(area)
 Renderer.write(area.x,area.y,"Search Page",Theme.header)
 Renderer.hLine(area.x,area.y+1,area.w,Theme.border)

 Renderer.write(area.x,area.y+3,"Search:",Theme.muted)
 Renderer.write(area.x+10,area.y+3,query=="" and "<type to search>" or query,query=="" and Theme.warning or Theme.good)

 Renderer.write(area.x,area.y+5,"Controls: type = search | backspace = delete | / = clear",Theme.muted)

 Renderer.hLine(area.x,area.y+7,area.w,Theme.border)

 Renderer.write(area.x,area.y+9,"#",Theme.header)
 Renderer.write(area.x+6,area.y+9,"Item",Theme.header)
 Renderer.write(area.x+55,area.y+9,"Amount",Theme.header)

 Renderer.hLine(area.x,area.y+10,area.w,Theme.border)

 if #results==0 then
  Renderer.write(area.x,area.y+12,"No matching items found.",Theme.bad)
  return
 end

 local rowColors={colors.red,colors.orange,colors.yellow,colors.lime,colors.green,colors.cyan,colors.lightBlue,colors.blue,colors.purple,colors.magenta}

 for i=1,math.min(#results,area.h-12) do
  local item=results[i]
  local y=area.y+10+i
  local name=item.displayName or item.display_name or item.name or item.id or "Unknown"
  local amount=tonumber(item.amount or item.count) or 0
  local color=rowColors[((i-1)%#rowColors)+1]

  Renderer.write(area.x,y,Utils.padLeft(i..".",3),color)
  Renderer.write(area.x+4,y,"|",Theme.border)
  Renderer.write(area.x+6,y,Utils.padRight(Utils.truncate(name,45),45),color)
  Renderer.write(area.x+53,y,"|",Theme.border)
  Renderer.write(area.x+56,y,Utils.padLeft(Utils.formatNumber(amount),12),color)
 end
end

function Search.handleEvent(event,a,b,c)
 if event=="char" then
  query=query..a
  return true
 end

 if event=="key" then
  if a==keys.backspace then
   query=query:sub(1,#query-1)
   return true
  end

  if a==keys.slash then
   query=""
   return true
  end
 end

 return false
end

return Search
