local Loader={}

local cache={}

function Loader.load(path)

    if cache[path] then
        return cache[path]
    end

    local filename=path:gsub("%.","/")..".lua"

    local fn,err=loadfile(filename)

    if not fn then
        error(err)
    end

    local module=fn()

    cache[path]=module

    return module

end

return Loader
