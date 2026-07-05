local Stats={}

function Stats.update(me)
 local stats={energy=0,itemCapacity=0,fluidCapacity=0,cellCount=0,cellBytes=0,cellUsedBytes=0}

 local okEnergy,energy=pcall(function() return me.getStoredEnergy() end)
 if okEnergy then stats.energy=tonumber(energy) or 0 end

 local okItems,items=pcall(function() return me.getTotalItemStorage() end)
 if okItems then stats.itemCapacity=tonumber(items) or 0 end

 local okFluids,fluids=pcall(function() return me.getTotalFluidStorage() end)
 if okFluids then stats.fluidCapacity=tonumber(fluids) or 0 end

 local okCells,cells=pcall(function() return me.getCells() end)
 if okCells and type(cells)=="table" then
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
