local Loader = dofile("loader.lua")

local Data = Loader.load("lib.data")
local Renderer = Loader.load("lib.renderer")
local Utils = Loader.load("lib.utils")
local Theme = Loader.load("lib.theme")

local TableWidget = Loader.load("widgets.table")

local Dashboard = {}

--------------------------------------------------
-- Draw header
--------------------------------------------------

local function drawHeader()

    local w, _ = Renderer.getSize()

    Renderer.write(2, 1, "Silicon Reach ME Dashboard", Theme.title)

    local time = Utils.currentTime()

    Renderer.write(w - #time - 2, 1, time, Theme.highlight)

end

--------------------------------------------------
-- Draw footer
--------------------------------------------------

local function drawFooter()

    local w, h = Renderer.getSize()

    local count = Data.getItemCount()
    local last = math.floor((os.epoch("utc") - Data.getLastUpdate()) / 1000)

    local footer = "Items: " .. count .. " | Updated: " .. last .. "s ago"

    Renderer.write(2, h, footer, Theme.text)

end

--------------------------------------------------
-- Draw main content
--------------------------------------------------

local function drawContent()

    local w, h = Renderer.getSize()

    local topItems = Data.getTopItems(10)

    TableWidget.draw(2, 3, w - 4, h - 5, topItems)

end

--------------------------------------------------
-- MAIN RENDER FUNCTION
--------------------------------------------------

function Dashboard.render()

    Data.update()

    Renderer.begin()

    drawHeader()

    drawContent()

    drawFooter()

    Renderer.endFrame()

end

return Dashboard
