print("PREMIUM VERSION LOADED")

local player = game.Players.LocalPlayer
player.Character.Humanoid.WalkSpeed = 100
player.Character.Humanoid.JumpPower = 150

-- MODULE PREMIUM
local fishing = loadstring(game:HttpGet("https://yourdomain.com/modules/fishing.lua"))()
local ui = loadstring(game:HttpGet("https://yourdomain.com/modules/ui.lua"))()

ui.Notify("Premium Mode Aktif")
fishing.Start()
