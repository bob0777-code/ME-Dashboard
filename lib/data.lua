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

local function safeLower(str)
    if type(str) ~= "string" then return "" end
    return string.lower(str)
end

local function isFiltered(item)
    if type(item) ~= "table" then return true end

    local name = safeLower(item.name)

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

local function normaliseItem(item)
    if type(item) ~= "table" then return nil end

    local name = item.name or item.id or "unknown"
    local amount = tonumber(item.amount or item.count) or 0

    return {
        name = name,
        displayName = item.displayName or name,
        amount = amount
    }
end

local function copyItem(item)
    local name = item.name or "unknown"
    local amount = item.amount or 0

    local previous = Data.previous[name] or amount or 0

    local trend = "="
    if amount > previous then
        trend = "▲"
    elseif amount < previous then
        trend = "▼"
    end

    return {
        name = name,
        displayName = item.displayName or name,
        amount = amount,
        previous = previous,
        trend = trend
    }
end

--------------------------------------------------
-- Public Functions
--------------------------------------------------

function Data.update()

    if not Peripherals or not Peripherals.me or type(Peripherals.me.getItems) ~= "function" then
        return false
    end

    Data.previous = {}

    for _, item in ipairs(Data.items) do
        if item and item.name then
            Data.previous[item.name] = item.amount or 0
        end
    end

    Data.items = {}
    Data.lookup = {}

    local rawItems = Peripherals.me.getItems()

    if type(rawItems) ~= "table" then
        rawItems = {}
    end

    for _, item in ipairs(rawItems) do

        local cleaned = normaliseItem(item)

        if cleaned and not isFiltered(cleaned) then

            local newItem = copyItem(cleaned)

            table.insert(Data.items, newItem)
            Data.lookup[newItem.name] = newItem

        end

    end

    if Utils and type(Utils.sortByAmount) == "function" then
        Utils.sortByAmount(Data.items)
    end

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
    if type(name) ~= "string" then return nil end
    return Data.lookup[name]
end

function Data.search(text)
    local results = {}

    if type(text) ~= "string" then return results end

    text = safeLower(text)

    for _, item in ipairs(Data.items) do
        if item then
            local dn = safeLower(item.displayName)
            local n = safeLower(item.name)

            if string.find(dn, text, 1, true)
            or string.find(n, text, 1, true) then
                table.insert(results, item)
            end
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
