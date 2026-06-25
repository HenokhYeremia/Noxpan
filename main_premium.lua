print("[Premium] Loading premium modules...")

local base = "https://raw.githubusercontent.com/HenokhYeremia/Noxpan/main/"

local modules = {
    fishing   = base .. "modules/fishing.lua",
    autoclick = base .. "modules/autoclick.lua",
    player    = base .. "modules/player.lua",
    esp       = base .. "modules/esp.lua",
    autofarm  = base .. "modules/autofarm.lua",
    antiban   = base .. "modules/antiban.lua",
    ui        = base .. "modules/ui.lua",
    hub       = base .. "modules/hub.lua",
    utils     = base .. "modules/utils.lua",
}

local loaded = {}

for name, url in pairs(modules) do
    local ok, fn = pcall(loadstring, game:HttpGet(url))
    if ok and fn then
        loaded[name] = fn()
        print("[Premium] Loaded: " .. name)
    else
        warn("[Premium] Failed to load: " .. name)
    end
end

if loaded.ui then
    loaded.ui.Alert("Noxpan Premium", "All modules loaded successfully", 4)
end

if loaded.player then
    loaded.player.Start()
    loaded.player.SetWalkSpeed(50)
    loaded.player.SetJumpPower(80)
end

if loaded.antiban then
    loaded.antiban.Start()
end

if loaded.hub then
    loaded.hub.Init("premium", loaded)
end

print("[Premium] Noxpan Premium v2.0 ready")
