local Loader = dofile("loader.lua")

local Renderer = Loader.load("lib.renderer")
local Utils = Loader.load("lib.utils")
local Theme = Loader.load("lib.theme")
local Data = Loader.load("lib.data")

local TableWidget = {}

function TableWidget.draw(x, y, width, height, items)

    if not items then
        items = Data.getTopItems(height)
    end

    local maxNameWidth = width - 18

    for i = 1, math.min(#items, height) do

        local item = items[i]

        local name = Utils.truncate(item.displayName or item.name or "Unknown", maxNameWidth)
        local amount = Utils.formatNumber(item.amount or 0)
        local trend = item.trend or "="

        local lineY = y + i - 1

        Renderer.write(x, lineY, Utils.padLeft(i .. ".", 3), Theme.text)
        Renderer.write(x + 4, lineY, Utils.padRight(name, maxNameWidth), Theme.text)
        Renderer.write(x + width - 10, lineY, Utils.padLeft(amount, 8), Theme.highlight)

        local trendColor = Theme.text

        if trend == "▲" then
            trendColor = Theme.good
        elseif trend == "▼" then
            trendColor = Theme.bad
        end

        Renderer.write(x + width - 1, lineY, trend, trendColor)

    end

end

return TableWidget
