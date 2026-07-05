local Peripherals = require("lib.peripherals")

local Data = {}

Data.items = {}
Data.previous = {}
Data.energy = {}
Data.lastUpdate = 0

local function copyItem(item)

    return {
        name = item.name,
        displayName = item.displayName or item.name,
        amount = item.amount
    }

end

function Data.update()

    local list = Peripherals.me.listItems()

    Data.previous = {}

    for _, item in ipairs(Data.items) do
        Data.previous[item.name] = item.amount
    end

    Data.items = {}

    for _, item in ipairs(list) do
        table.insert(Data.items, copyItem(item))
    end

    table.sort(Data.items, function(a, b)
        return a.amount > b.amount
    end)

    Data.lastUpdate = os.clock()

end

function Data.getTopItems(limit)

    local results = {}

    limit = math.min(limit or 10, #Data.items)

    for i = 1, limit do
        results[i] = Data.items[i]
    end

    return results

end

function Data.getTrend(name, amount)

    local old = Data.previous[name]

    if not old then
        return "="
    end

    if amount > old then
        return "▲"
    end

    if amount < old then
        return "▼"
    end

    return "="

end

return Data
