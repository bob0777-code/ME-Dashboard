local Loader = dofile("loader.lua")

local Renderer = Loader.load("lib.renderer")
local Utils = Loader.load("lib.utils")
local Theme = Loader.load("lib.theme")
local Data = Loader.load("lib.data")

local TableWidget = {}

--------------------------------------------------
-- Draw Table
--------------------------------------------------

function TableWidget.draw(x, y, width, height, items)

    if not items then
        items = Data.getTopItems(height)
    end

    Renderer.clear()

    local maxNameWidth = width - 18

    for i = 1, math.min(#items, height) do

        local item = items[i]

        local name = Utils.truncate(item.displayName, maxNameWidth)
        local amount = Utils.formatNumber(item.amount)
        local trend = item.trend or "="

        local lineY = y + i - 1

        -- Rank
        Renderer.write(x, lineY, Utils.padLeft(i .. ".", 3), Theme.text)

        -- Name
        Renderer.write(x + 4, lineY, Utils.padRight(name, maxNameWidth), Theme.text)

        -- Amount
        Renderer.write(x + width - 10, lineY, Utils.padLeft(amount, 8), Theme.highlight)

        -- Trend
        local color = Theme.text

        if trend == "▲" then color = Theme.good end
        if trend == "▼" then color = Theme.bad end

        Renderer.write(x + width - 1, lineY, trend, color)

    end

end

return TableWidget
