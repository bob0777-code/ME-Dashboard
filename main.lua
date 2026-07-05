local Loader=dofile("loader.lua")

local Version=Loader.load("version")

local Config=Loader.load("lib.config")

local Theme=Loader.load("lib.theme")

local Peripherals=Loader.load("lib.peripherals")

Peripherals.refresh()

local status=Peripherals.verify()

local monitor=Peripherals.monitor or term

monitor.setBackgroundColor(Theme.background)
monitor.setTextColor(Theme.text)

if monitor.clear then monitor.clear() end

if monitor.setTextScale then
    monitor.setTextScale(Config.textScale)
end

monitor.setCursorPos(2,2)
monitor.setTextColor(Theme.title)
monitor.write(Version.name)

monitor.setCursorPos(2,3)
monitor.setTextColor(Theme.highlight)
monitor.write("Version "..Version.version)

monitor.setCursorPos(2,5)
monitor.setTextColor(Theme.text)
monitor.write("Status")

monitor.setCursorPos(2,6)
monitor.write("---------------------")

local function drawStatus(name,value,row)

    monitor.setCursorPos(2,row)

    monitor.setTextColor(Theme.text)

    monitor.write(name)

    monitor.setCursorPos(20,row)

    if value then
        monitor.setTextColor(Theme.good)
        monitor.write("OK")
    else
        monitor.setTextColor(Theme.bad)
        monitor.write("Missing")
    end

end

drawStatus("ME Bridge",status.me,7)
drawStatus("Monitor",status.monitor,8)
drawStatus("Colony",status.colony,9)
drawStatus("Stash",status.stash,10)

monitor.setCursorPos(2,12)
monitor.setTextColor(Theme.highlight)
monitor.write("Waiting for data...")

while true do
    sleep(Config.refreshRate)
end
