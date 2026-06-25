print("[Free] Loading free modules...")

local base = "https://raw.githubusercontent.com/HenokhYeremia/Noxpan/main/"

local modules = {
    player = base .. "modules/player.lua",
    ui     = base .. "modules/ui.lua",
    hub    = base .. "modules/hub.lua",
    utils  = base .. "modules/utils.lua",
}

local loaded = {}

for name, url in pairs(modules) do
    local ok, fn = pcall(loadstring, game:HttpGet(url))
    if ok and fn then
        loaded[name] = fn()
        print("[Free] Loaded: " .. name)
    end
end

if loaded.player then
    loaded.player.Start()
    loaded.player.SetWalkSpeed(28)
    loaded.player.SetJumpPower(55)
    loaded.player.SetAntiDrown(true)
end

if loaded.ui then
    loaded.ui.Notify("Noxpan Free Mode", 3)
end

if loaded.hub then
    loaded.hub.Init("free", loaded)
end

print("[Free] Noxpan Free v2.0 ready")
