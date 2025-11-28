print("FREE VERSION LOADED")

local player = game.Players.LocalPlayer
player.Character.Humanoid.WalkSpeed = 28

-- module yang boleh untuk FREE
local ui = loadstring(game:HttpGet("https://yourdomain.com/modules/ui.lua"))()
ui.Notify("Free Mode Aktif")
