local Loader=dofile("loader.lua")
local Utils=Loader.load("lib.utils")
local Fluids={}
local FLUID_LIMIT=2147480000000
local function clean(v) v=tostring(v or "") v=v:gsub("%[","") v=v:gsub("%]","") return v end
function Fluids.update(me)
 local normal={} local maxed={}
 if not me or type(me.getFluids)~="function" then return normal,maxed end
 local ok,raw=pcall(function() return me.getFluids() end)
 if not ok or type(raw)~="table" then return normal,maxed end
 for _,r in ipairs(raw) do
  if type(r)=="table" then
   local amount=tonumber(r.amount or r.count) or 0
   local fluid={name=r.name or r.id or "Unknown",displayName=clean(r.displayName or r.display_name or r.name or "Unknown"),amount=amount}
   if amount>=FLUID_LIMIT then table.insert(maxed,fluid) else table.insert(normal,fluid) end
  end
 end
 Utils.sortByAmount(normal)
 Utils.sortByAmount(maxed)
 return normal,maxed
end
return Fluids
