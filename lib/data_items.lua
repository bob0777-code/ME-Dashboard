local Loader=dofile("loader.lua")
local Utils=Loader.load("lib.utils")
local Items={}
local ITEM_LIMIT=2147480000
local function clean(v) v=tostring(v or "") v=v:gsub("%[","") v=v:gsub("%]","") return v end
function Items.update(me)
 local normal={} local maxed={}
 if not me or type(me.getItems)~="function" then return normal,maxed end
 local ok,raw=pcall(function() return me.getItems() end)
 if not ok or type(raw)~="table" then return normal,maxed end
 for _,r in ipairs(raw) do
  if type(r)=="table" then
   local amount=tonumber(r.amount or r.count) or 0
   local item={name=r.name or r.id or "Unknown",displayName=clean(r.displayName or r.display_name or r.name or "Unknown"),amount=amount}
   if amount>=ITEM_LIMIT then table.insert(maxed,item) else table.insert(normal,item) end
  end
 end
 Utils.sortByAmount(normal)
 Utils.sortByAmount(maxed)
 return normal,maxed
end
return Items
