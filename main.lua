local Loader=dofile("loader.lua")
local Peripherals=Loader.load("lib.peripherals")
local Renderer=Loader.load("lib.renderer")
local Config=Loader.load("lib.config")
local Dashboard=Loader.load("pages.dashboard")

Peripherals.refresh()
Peripherals.verify()
Renderer.init()

local function safeRun(fn)
    local ok,err=pcall(fn)
    if not ok then
        print("ERROR: "..tostring(err))
        Renderer.begin()
        Renderer.write(2,2,"ERROR",colors.red)
        Renderer.write(2,4,tostring(err),colors.white)
        Renderer.endFrame()
        sleep(5)
    end
end

while true do
    safeRun(function()
        Dashboard.render()
    end)
    sleep(Config.refreshRate)
end
