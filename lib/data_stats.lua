local Stats={}
local function call(me,name)
 if not me or type(me[name])~="function" then return nil end
 local ok,result=pcall(function() return me[name]() end)
 if ok then return result end
 local ok2,result2=pcall(function() return me[name](me) end)
 if ok2 then return result2 end
 return nil
end
function Stats.update(me)
 local stats={}
 stats.energy=tonumber(call(me,"getStoredEnergy")) or 0
 stats.itemCapacity=tonumber(call(me,"getTotalItemStorage")) or 0
 stats.fluidCapacity=tonumber(call(me,"getTotalFluidStorage")) or 0
 stats.cellCount=0
 stats.cellBytes=0
 stats.cellUsedBytes=0
 local cells=call(me,"getCells")
 if type(cells)=="table" then
  stats.cellCount=#cells
  for _,cell in ipairs(cells) do
   if type(cell)=="table" then
    stats.cellBytes=stats.cellBytes+(tonumber(cell.bytes) or 0)
    stats.cellUsedBytes=stats.cellUsedBytes+(tonumber(cell.usedBytes) or 0)
   end
  end
 end
 return stats
end
return Stats
