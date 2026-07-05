local Peripherals = {}

Peripherals.colony = peripheral.find("colony_integrator")
Peripherals.monitor = peripheral.find("monitor")
Peripherals.me = peripheral.find("me_bridge")
Peripherals.stash = peripheral.find("minecolonies:stash")

function Peripherals.verify()

    if not Peripherals.monitor then
        error("Monitor not found")
    end

    if not Peripherals.me then
        error("ME Bridge not found")
    end

end

return Peripherals
