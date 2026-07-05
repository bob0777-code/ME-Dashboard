local Loader = dofile("loader.lua")

local Peripherals = Loader.load("lib.peripherals")
local Theme = Loader.load("lib.theme")

local Renderer = {}

--------------------------------------------------
-- Screen state
--------------------------------------------------

local monitor = Peripherals.monitor or term

local width, height = 0, 0

local buffer = {}
local oldBuffer = {}

--------------------------------------------------
-- Init
--------------------------------------------------

function Renderer.init()

    monitor = Peripherals.monitor or term

    if monitor.setTextScale then
        monitor.setTextScale(0.5)
    end

    width, height = monitor.getSize()

    buffer = {}
    oldBuffer = {}

end

--------------------------------------------------
-- FRAME CONTROL
--------------------------------------------------

function Renderer.begin()

    buffer = {}

end

function Renderer.endFrame()

    local function setPixel(x, y, cell)

        monitor.setCursorPos(x, y)

        if cell then
            monitor.setTextColor(cell.color)
            monitor.write(cell.char)
        else
            monitor.setTextColor(Theme.background)
            monitor.write(" ")
        end

    end

    for y = 1, height do

        for x = 1, width do

            local new = buffer[y] and buffer[y][x]
            local old = oldBuffer[y] and oldBuffer[y][x]

            if new ~= old then
                setPixel(x, y, new)

                oldBuffer[y] = oldBuffer[y] or {}
                oldBuffer[y][x] = new
            end

        end

    end

end

--------------------------------------------------
-- Drawing
--------------------------------------------------

local function setCell(x, y, char, color)

    buffer[y] = buffer[y] or {}

    buffer[y][x] = {
        char = char,
        color = color or Theme.text
    }

end

function Renderer.write(x, y, text, color)

    text = tostring(text)

    for i = 1, #text do
        setCell(x + i - 1, y, text:sub(i, i), color)
    end

end

--------------------------------------------------
-- Helpers
--------------------------------------------------

function Renderer.getSize()
    return width, height
end

function Renderer.centerText(y, text, color)

    local x = math.floor((width - #text) / 2)

    Renderer.write(x, y, text, color)

end

return Renderer
