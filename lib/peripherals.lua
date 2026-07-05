local Peripherals={}

Peripherals.colony=peripheral.find("colony_integrator")
Peripherals.monitor=peripheral.find("monitor")
Peripherals.me=peripheral.find("me_bridge")
Peripherals.stash=peripheral.find("minecolonies:stash")

function Peripherals.refresh()

    Peripherals.colony=peripheral.find("colony_integrator")
    Peripherals.monitor=peripheral.find("monitor")
    Peripherals.me=peripheral.find("me_bridge")
    Peripherals.stash=peripheral.find("minecolonies:stash")

end

function Peripherals.verify()

    local status={}

    status.me=Peripherals.me~=nil
    status.monitor=Peripherals.monitor~=nil
    status.colony=Peripherals.colony~=nil
    status.stash=Peripherals.stash~=nil

    return status

end

return Peripherals
