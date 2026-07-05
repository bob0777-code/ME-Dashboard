local Loader=dofile("loader.lua")
local Utils=Loader.load("lib.utils")
local Items={}
local function lower(v) if type(v)~="string" then return "" end return string.lower(v) end
local function filtered(item) local n=lower(item.name) local filters={"pattern","terminal","storage_cell","storage_component","spatial","facade","cable","drive","p2p","memory_card"} for _,f in ipairs(filters) do if string.find(n,f,1,true) then return true end end return false end
local function call(me,name) if not me or type(me[name])~="function" then return {} end local ok,result=pcall(function() return me[name]() end) if ok then return result end return {} end
function Items.update(me,oldItems)
 local previous={}
 for _,item in ipairs(oldItems or {}) do if item.name then previous[item.name]=item.amount or 0 end end
 local list={}
 local lookup={}
 local raw=call(me,"getItems")
 if type(raw)~="table" then raw={} end
 for _,r in ipairs(raw) do
  if type(r)=="table" then
   local name=r.name or r.id or "unknown"
   local item={name=name,displayName=r.displayName or r.display_name or name,amount=tonumber(r.amount or r.count) or 0}
   if not filtered(item) then
    local old=previous[item.name] or item.amount
    item.previous=old
    item.trend="="
    if item.amount>old then item.trend="+" end
    if item.amount<old then item.trend="-" end
    table.insert(list,item)
    lookup[item.name]=item
   end
  end
 end
 Utils.sortByAmount(list)
 return list,lookup
end
return Items
