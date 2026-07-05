local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")
local Config=Loader.load("lib.config")
local Data=Loader.load("lib.data")
local Dashboard=Loader.load("pages.dashboard")

Peripherals.refresh()

local m=Peripherals.monitor or term
m.setTextScale(0.5)
m.clear()
m.setCursorPos(1,1)
m.setTextColor(colors.lime)
m.write("MAIN STARTED")

sleep(2)

Renderer.init()
Renderer.begin()
Renderer.write(1,1,"RENDERER STARTED",colors.cyan)
Renderer.endFrame()

sleep(2)

local ok,err=pcall(function()
    Data.update()
end)

m.setCursorPos(1,3)
m.setTextColor(colors.white)
m.write("Data update: "..tostring(ok))

m.setCursorPos(1,4)
m.write("Items: "..tostring(Data.getItemCount()))

if not ok then
    m.setCursorPos(1,6)
    m.setTextColor(colors.red)
    m.write(tostring(err))
    while true do sleep(10) end
end

sleep(3)

while true do
    local ok2,err2=pcall(function()
        Dashboard.render()
    end)

    if not ok2 then
        m.clear()
        m.setCursorPos(1,1)
        m.setTextColor(colors.red)
        m.write("DASHBOARD ERROR")
        m.setCursorPos(1,3)
        m.setTextColor(colors.white)
        m.write(tostring(err2))
        sleep(10)
    else
        sleep(Config.refreshRate or 15)
    end
end
