print("FREE VERSION LOADED")

local base = "https://raw.githubusercontent.com/HenokhYeremia/Noxpan/main/"

local ui = loadstring(game:HttpGet(base .. "modules/ui.lua"))()
ui.Notify("Free Mode Aktif")

-- contoh fitur free:
local player = game.Players.LocalPlayer
player.Character.Humanoid.WalkSpeed = 28
