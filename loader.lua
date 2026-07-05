local Loader = {}

local cache = {}

function Loader.load(path)

    if cache[path] then
        return cache[path]
    end

    local file = fs.open(path:gsub("%.","/")..".lua","r")

    if not file then
        error("Cannot load "..path)
    end

    local source = file.readAll()

    file.close()

    local fn, err = load(source,"@"..path)

    if not fn then
        error(err)
    end

    local module = fn()

    cache[path] = module

    return module

end

return Loader
