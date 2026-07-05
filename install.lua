local files = {
    "main.lua",
    "startup.lua",
    "loader.lua",
    "version.lua",

    "lib/config.lua",
    "lib/theme.lua",
    "lib/peripherals.lua",
    "lib/utils.lua",
    "lib/data.lua",
    "lib/renderer.lua",

    "pages/dashboard.lua",

    "widgets/table.lua"
}

local base = "https://raw.githubusercontent.com/bob0777-code/ME-Dashboard/main/"

for _, file in ipairs(files) do
    print("Downloading " .. file)

    local response = http.get(base .. file)

    if response then
        local content = response.readAll()
        response.close()

        local f = fs.open(file, "w")
        f.write(content)
        f.close()
    else
        print("Failed: " .. file)
    end
end

print("Install complete. Run main.lua")
