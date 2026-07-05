local Stats={}
function Stats.update(me,fluids)
 local s={energy=0,itemCap=0,fluidCap=0,fluidUsed=0,cells=0,bytes=0,used=0}
 if not me then return s end
 local ok,e=pcall(function() return me.getStoredEnergy() end) if ok then s.energy=tonumber(e) or 0 end
 local ok2,i=pcall(function() return me.getTotalItemStorage() end) if ok2 then s.itemCap=tonumber(i) or 0 end
 local ok3,f=pcall(function() return me.getTotalFluidStorage() end) if ok3 then s.fluidCap=tonumber(f) or 0 end
 for _,fluid in ipairs(fluids or {}) do s.fluidUsed=s.fluidUsed+(tonumber(fluid.amount) or 0) end
 local ok4,c=pcall(function() return me.getCells() end)
 if ok4 and type(c)=="table" then
  s.cells=#c
  for _,cell in ipairs(c) do
   if type(cell)=="table" then
    s.bytes=s.bytes+(tonumber(cell.bytes) or 0)
    s.used=s.used+(tonumber(cell.usedBytes) or 0)
   end
  end
 end
 return s
end
return Stats
