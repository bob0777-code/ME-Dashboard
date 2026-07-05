local Peripherals = dofile("loader.lua").load("lib.peripherals")
local Theme = dofile("loader.lua").load("lib.theme")

local Renderer = {}

--------------------------------------------------
-- Screen state
--------------------------------------------------

local buffer = {}
local oldBuffer = {}

local width, height = 0, 0
local monitor = Peripherals.monitor or term

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
-- Internal: set cell
--------------------------------------------------

local function setCell(x, y, char, color)

    buffer[y] = buffer[y] or {}

    buffer[y][x] = {
        char = char,
        color = color or Theme.text
    }

end

--------------------------------------------------
-- Write text
--------------------------------------------------

function Renderer.write(x, y, text, color)

    text = tostring(text)

    for i = 1, #text do
        setCell(x + i - 1, y, text:sub(i, i), color)
    end

end

--------------------------------------------------
-- Clear buffer
--------------------------------------------------

function Renderer.clear()

    buffer = {}

end

--------------------------------------------------
-- Draw full frame
--------------------------------------------------

function Renderer.render()

    local changed = false

    for y = 1, height do
        for x = 1, width do

            local new = buffer[y] and buffer[y][x]
            local old = oldBuffer[y] and oldBuffer[y][x]

            if new ~= old then

                monitor.setCursorPos(x, y)

                if new then
                    monitor.setTextColor(new.color)
                    monitor.write(new.char)
                else
                    monitor.setTextColor(Theme.background)
                    monitor.write(" ")
                end

                changed = true

                oldBuffer[y] = oldBuffer[y] or {}
                oldBuffer[y][x] = new

            end

        end
    end

    return changed

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
