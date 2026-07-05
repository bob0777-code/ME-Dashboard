local Loader={}
local cache={}
function Loader.load(path)
 if cache[path] then return cache[path] end
 local file=path:gsub("%.","/")..".lua"
 local fn,err=loadfile(file)
 if not fn then error("Loader failed: "..tostring(err)) end
 local module=fn()
 cache[path]=module
 return module
end
function Loader.clear()
 cache={}
end
return Loader
