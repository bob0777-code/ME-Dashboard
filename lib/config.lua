local Config={}

Config.refreshRate=15
Config.textScale=0.5
Config.topItems=10

function Config.getKingdomName()
 local label=os.getComputerLabel()
 if label and label~="" then
  return label
 end
 return "Unnamed Kingdom"
end

function Config.getTitle()
 return "Kingdom of "..Config.getKingdomName()
end

return Config
