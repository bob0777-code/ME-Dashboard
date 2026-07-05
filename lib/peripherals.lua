local Peripherals={}

function Peripherals.refresh()
 Peripherals.colony=peripheral.find("colony_integrator")
 Peripherals.monitor=peripheral.find("monitor")
 Peripherals.me=peripheral.find("me_bridge")
 Peripherals.stash=peripheral.find("minecolonies:stash")
end

function Peripherals.verify()
 return {
  colony=Peripherals.colony~=nil,
  monitor=Peripherals.monitor~=nil,
  me=Peripherals.me~=nil,
  stash=Peripherals.stash~=nil
 }
end

Peripherals.refresh()

return Peripherals
