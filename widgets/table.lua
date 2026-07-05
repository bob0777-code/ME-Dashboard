local Loader=dofile("loader.lua")

local Renderer=Loader.load("lib.renderer")

local TableWidget={}

function TableWidget.draw(x,y,width,height,items)

    Renderer.write(x,y,"TABLE WIDGET START",colors.lime)

    Renderer.write(x,y+1,"Items: "..tostring(#items),colors.white)

    if items[1] then
        Renderer.write(x,y+2,items[1].displayName,colors.yellow)
    end

end

return TableWidget
