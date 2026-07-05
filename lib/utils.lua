local Utils = {}

function Utils.formatNumber(n)
    if type(n) ~= "number" then
        return "0"
    end

    local abs = math.abs(n)

    if abs >= 1000000000000 then
        return string.format("%.1fT", n / 1000000000000)
    elseif abs >= 1000000000 then
        return string.format("%.1fB", n / 1000000000)
    elseif abs >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif abs >= 1000 then
        return string.format("%.1fK", n / 1000)
    end

    return tostring(math.floor(n))
end

function Utils.center(text, width)

    local padding = math.max(0, math.floor((width - #text) / 2))

    return string.rep(" ", padding) .. text

end

function Utils.padLeft(text, width)

    text = tostring(text)

    if #text >= width then
        return text
    end

    return string.rep(" ", width - #text) .. text

end

function Utils.padRight(text, width)

    text = tostring(text)

    if #text >= width then
        return text
    end

    return text .. string.rep(" ", width - #text)

end

function Utils.truncate(text, width)

    text = tostring(text)

    if #text <= width then
        return text
    end

    if width <= 3 then
        return string.sub(text,1,width)
    end

    return string.sub(text,1,width-3) .. "..."

end

function Utils.clamp(value,min,max)

    if value < min then
        return min
    end

    if value > max then
        return max
    end

    return value

end

function Utils.round(value,places)

    places = places or 0

    local mult = 10 ^ places

    return math.floor(value * mult + 0.5) / mult

end

function Utils.progressBar(current,max,width)

    if max <= 0 then
        max = 1
    end

    local percent = current / max

    percent = Utils.clamp(percent,0,1)

    local filled = math.floor(percent * width)

    return string.rep("\127",filled) .. string.rep("-",width-filled)

end

function Utils.copy(tbl)

    local result = {}

    for k,v in pairs(tbl) do
        result[k]=v
    end

    return result

end

function Utils.deepCopy(tbl)

    local result={}

    for k,v in pairs(tbl) do

        if type(v)=="table" then
            result[k]=Utils.deepCopy(v)
        else
            result[k]=v
        end

    end

    return result

end

function Utils.sortByAmount(items)

    table.sort(items,function(a,b)

        return a.amount>b.amount

    end)

end

function Utils.currentTime()

    return textutils.formatTime(os.time(),true)

end

function Utils.boolText(value)

    if value then
        return "OK"
    end

    return "Missing"

end

function Utils.boolColour(value)

    if value then
        return colors.lime
    end

    return colors.red

end

return Utils
