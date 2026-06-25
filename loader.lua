local HUB_NAME = "Noxpan"
local HUB_VERSION = "3.0"
local BASE = "https://raw.githubusercontent.com/HenokhYeremia/Noxpan/main/"
local CONFIG_URL = BASE .. "json/config.json"
local USER_DB = BASE .. "users.txt"
local GAMES = {
    [6701277882] = "fishit",
    [9691752199] = "sawahindo",
    [9721900284] = "fishzar",
    [9186719164] = "sailor",
}
local GAME_URLS = {
    fishit    = BASE .. "modules/game_fishit.lua",
    generalfishing = BASE .. "modules/game_fishing.lua",
}

local G = game:GetService("HttpService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

-- Cross-executor polyfills (Delta/Xeno/Solara/Velocity)
if not mouse1click then
    mouse1click = function()
        local ok = pcall(function()
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait()
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        if not ok then
            pcall(function()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
                game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 0))
            end)
        end
    end
end

if not fireproximityprompt then
    fireproximityprompt = function(prompt)
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end
end

local function req(url)
    local ok, res = pcall(game.HttpGet, game, url)
    if not ok then warn("[" .. HUB_NAME .. "] Network error: " .. tostring(res)) end
    return ok and res or nil
end

local function loadModule(url)
    local code = req(url)
    if not code then return nil end
    local ok, fn = pcall(loadstring, code)
    if ok and fn then
        local ok2, result = pcall(fn)
        if not ok2 then warn("[" .. HUB_NAME .. "] Runtime error") end
        return result
    else
        warn("[" .. HUB_NAME .. "] Compile failed: " .. url)
        return nil
    end
end

local function getConfig()
    local data = req(CONFIG_URL)
    if data then
        local ok, c = pcall(G.JSONDecode, G, data)
        if ok and c then return c end
    end
    return {version = "?", developer = "?"}
end

local function getUserStatus(name)
    local data = req(USER_DB)
    if not data then return "unknown" end
    for line in data:gmatch("[^\r\n]+") do
        local uname, status = line:match("([^:]+):([^:]+)")
        if uname and uname == name then return status end
    end
    return "unknown"
end

local config = getConfig()
local ok, localPlayer = pcall(function() return players.LocalPlayer end)
if not ok or not localPlayer then
    return warn("[" .. HUB_NAME .. "] Not in a Roblox game.")
end

local username = localPlayer.Name
local status = getUserStatus(username)
local gameId = game.GameId
local gameName = GAMES[gameId]

print(string.format("[%s v%s] User: %s | Status: %s | GameId: %d",
    HUB_NAME, config.version or "?", username, status, gameId))

if status == "ban" then
    return warn("[" .. HUB_NAME .. "] You are banned.")
end

if gameName and gameName ~= "" then
    print("[" .. HUB_NAME .. "] Detected: " .. gameName)
    local gameUrl = GAME_URLS[gameName]
    if gameUrl then
        local modules = {
            utils     = BASE .. "modules/utils.lua",
            ui        = BASE .. "modules/ui.lua",
            player    = BASE .. "modules/player.lua",
            settings  = BASE .. "modules/settings.lua",
        }
        if status == "premium" then
            modules.fishing   = BASE .. "modules/fishing.lua"
            modules.autoclick = BASE .. "modules/autoclick.lua"
            modules.esp       = BASE .. "modules/esp.lua"
            modules.autofarm  = BASE .. "modules/autofarm.lua"
            modules.antiban   = BASE .. "modules/antiban.lua"
        end

        local loaded = {}
        for name, url in pairs(modules) do
            local code = req(url)
            if code then
                local okFn, fn = pcall(loadstring, code)
                if okFn and fn then
                    loaded[name] = fn()
                end
            end
        end

        loaded.game = loadModule(gameUrl)

        local hubMod = req(BASE .. "modules/hub.lua")
        if hubMod then
            local okHub, hubFn = pcall(loadstring, hubMod)
            if okHub and hubFn then
                local hub = hubFn()
                hub.Init(status, loaded, gameName)
            end
        end
    end
else
    -- Generic fishing game fallback
    print("[" .. HUB_NAME .. "] Unknown game, loading generic fishing modules...")
    local loaded = {}
    local genericMods = {
        utils     = BASE .. "modules/utils.lua",
        ui        = BASE .. "modules/ui.lua",
        player    = BASE .. "modules/player.lua",
        settings  = BASE .. "modules/settings.lua",
        fishing   = BASE .. "modules/fishing.lua",
        autoclick = BASE .. "modules/autoclick.lua",
        esp       = BASE .. "modules/esp.lua",
    }
    for name, url in pairs(genericMods) do
        local code = req(url)
        if code then
            local okFn, fn = pcall(loadstring, code)
            if okFn and fn then loaded[name] = fn() end
        end
    end

    local hubMod = req(BASE .. "modules/hub.lua")
    if hubMod then
        local okHub, hubFn = pcall(loadstring, hubMod)
        if okHub and hubFn then
            local hub = hubFn()
            hub.Init(status, loaded, "generalfishing")
        end
    end
end
