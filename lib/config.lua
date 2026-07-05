local Config={}

Config.refreshRate=15
Config.textScale=0.5
Config.topItems=10

function Config.getKingdomName()
 local ok,Peripherals=pcall(function()
  return dofile("loader.lua").load("lib.peripherals")
 end)

 if ok and Peripherals and Peripherals.colony then
  local methods={"getColonyName","getName"}
  for _,m in ipairs(methods) do
   if type(Peripherals.colony[m])=="function" then
    local okName,name=pcall(function()
     return Peripherals.colony[m]()
    end)
    if okName and name and name~="" then
     return tostring(name)
    end
   end
  end
 end

 local label=os.getComputerLabel()
 if label and label~="" then return label end

 return "Unnamed Kingdom"
end

function Config.getTitle()
 return Config.getKingdomName()
end

return Config
