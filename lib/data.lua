local Loader = dofile("loader.lua")

local Peripherals = Loader.load("lib.peripherals")
local Utils = Loader.load("lib.utils")

local Data = {}

Data.items = {}
Data.lookup = {}
Data.previous = {}
Data.lastUpdate = 0

--------------------------------------------------
-- Private Functions
--------------------------------------------------

local function isFiltered(item)

    local name = string.lower(item.name)

    local filters = {
        "pattern",
        "terminal",
        "storage_cell",
        "storage_component",
        "spatial",
        "facade",
        "cable",
        "drive",
        "p2p",
        "memory_card"
    }

    for _, filter in ipairs(filters) do
        if string.find(name, filter, 1, true) then
            return true
        end
    end

    return false

end

local function copyItem(item)

    local previous = Data.previous[item.name] or item.amount

    local trend = "="

    if item.amount > previous then
        trend = "▲"
    elseif item.amount < previous then
        trend = "▼"
    end

    return {

        name = item.name,

        displayName = item.displayName or item.name,

        amount = item.amount,

        previous = previous,

        trend = trend

    }

end

--------------------------------------------------
-- Public Functions
--------------------------------------------------

function Data.update()

    if not Peripherals.me then
        return false
    end

    Data.previous = {}

    for _, item in ipairs(Data.items) do

        Data.previous[item.name] = item.amount

    end

    Data.items = {}

    Data.lookup = {}

    local items = Peripherals.me.listItems()

    for _, item in ipairs(items) do

        if not isFiltered(item) then

            local newItem = copyItem(item)

            table.insert(Data.items, newItem)

            Data.lookup[newItem.name] = newItem

        end

    end

    Utils.sortByAmount(Data.items)

    Data.lastUpdate = os.epoch("utc")

    return true

end

function Data.getTopItems(limit)

    limit = limit or 10

    local results = {}

    for i = 1, math.min(limit, #Data.items) do

        results[i] = Data.items[i]

    end

    return results

end

function Data.getItem(name)

    return Data.lookup[name]

end

function Data.search(text)

    local results = {}

    text = string.lower(text)

    for _, item in ipairs(Data.items) do

        if string.find(string.lower(item.displayName), text, 1, true)

        or string.find(string.lower(item.name), text, 1, true)

        then

            table.insert(results, item)

        end

    end

    return results

end

function Data.getItemCount()

    return #Data.items

end

function Data.getLastUpdate()

    return Data.lastUpdate

end

return Data
