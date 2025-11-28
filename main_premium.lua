print("PREMIUM VERSION LOADED")

local base = "https://raw.githubusercontent.com/HenokhYeremia/Noxpan/main/"

-- ambil module premium
local fishing = loadstring(game:HttpGet(base .. "modules/fishing.lua"))()
local ui      = loadstring(game:HttpGet(base .. "modules/ui.lua"))()

ui.Notify("Premium Mode Aktif")

-- contoh fitur premium
fishing.Start()
