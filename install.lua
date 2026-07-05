local BASE="https://raw.githubusercontent.com/bob0777-code/ME-Dashboard/main/"

local folders={
    "lib",
    "pages",
    "widgets",
    "assets"
}

local files={
    "loader.lua",
    "main.lua",
    "startup.lua",
    "version.lua",

    "lib/config.lua",
    "lib/theme.lua",
    "lib/peripherals.lua",
    "lib/utils.lua",
    "lib/data.lua",
    "lib/renderer.lua",
    "lib/layout.lua",

    "pages/dashboard.lua",

    "widgets/table.lua"
}

print("===================================")
print(" ME Dashboard Installer")
print("===================================")
print("")

for _,folder in ipairs(folders) do
    if not fs.exists(folder) then
        fs.makeDir(folder)
    end
end

for _,file in ipairs(files) do

    print("Downloading "..file)

    if fs.exists(file) then
        fs.delete(file)
    end

    local response=http.get(BASE..file)

    if not response then
        error("Failed to download "..file)
    end

    local text=response.readAll()
    response.close()

    local f=fs.open(file,"w")

    if not f then
        error("Couldn't write "..file)
    end

    f.write(text)
    f.close()

end

print("")
print("===================================")
print(" Install Complete!")
print("===================================")
print("")
print("Starting dashboard...")
sleep(1)

shell.run("main")
