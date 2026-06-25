local M = {}
local active = false
local fishCount = 0
local totalEarnings = 0
local statusText = "Idle"
local settings = {
    castDelay = 3,
    reelDelay = 0.5,
    autoCast = true,
    detectMode = "smart",
    maxWaitTime = 15,
    autoSell = false,
    autoBait = false,
}

local function getGameMod()
    local mod = _G.NoxpanLoaded and _G.NoxpanLoaded.game
    return mod
end

local function findBobber()
    local mod = getGameMod()
    if mod and mod.FindBobber then
        local b = mod.FindBobber()
        if b then return b end
    end
    for _, name in ipairs({"Bobber", "bobber", "Hook", "hook", "Pelampung", "pelampung"}) do
        local b = workspace:FindFirstChild(name)
        if b then return b end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Transparency < 0.8 then
            local n = v.Name:lower()
            if n:find("bobber") or n:find("hook") or n:find("float") or n:find("pelampung") or n:find("kail") then
                return v
            end
        end
    end
    return nil
end

local function findRod()
    local mod = getGameMod()
    if mod and mod.FindRod then
        local r = mod.FindRod()
        if r then return r end
    end
    local player = game.Players.LocalPlayer
    local rod = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
    if rod then return rod end
    rod = player.Backpack:FindFirstChildWhichIsA("Tool")
    if rod then return rod end
    for _, v in ipairs(player.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.Name:lower():find("rod") or v.Name:lower():find("pole") or v.Name:lower():find("pancing") or v.Name:lower():find("fishing")) then
            return v
        end
    end
    return nil
end

local function equipRod()
    local player = game.Players.LocalPlayer
    local rod = findRod()
    if not rod then return false end
    local char = player.Character
    if not char then return false end
    if char:FindFirstChild(rod.Name) then return true end
    local bpRod = player.Backpack:FindFirstChild(rod.Name)
    if bpRod then
        pcall(function() bpRod.Parent = char end)
        task.wait(0.3)
        return char:FindFirstChild(rod.Name) ~= nil
    end
    return false
end

local function castRod()
    local player = game.Players.LocalPlayer
    local rod = findRod()
    if not rod then return false end
    if not equipRod() then return false end
    task.wait(0.2)
    local tool = player.Character and player.Character:FindFirstChild(rod.Name)
    if tool and tool:IsA("Tool") then
        pcall(function() tool:Activate() end)
    end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local water = nil
        local mod = getGameMod()
        if mod and mod.FindWater then
            water = mod.FindWater()
        end
        if not water then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:lower():find("water") or v.Name:lower():find("air") or v.Name:lower():find("danau") or v.Name:lower():find("laut")) then
                    water = v
                    break
                end
            end
        end
        if water then
            local target = Vector3.new(
                water.Position.X + math.random(-15, 15),
                water.Position.Y + 2,
                water.Position.Z + math.random(-15, 15)
            )
            pcall(function()
                hrp.CFrame = CFrame.lookAt(hrp.Position, target)
            end)
        end
    end
    return true
end

local function reelIn()
    local player = game.Players.LocalPlayer
    local char = player.Character
    local rod = char and char:FindFirstChildWhichIsA("Tool")
    if rod then
        pcall(function() rod:Activate() end)
    end
    task.wait(0.1)
    pcall(function() mouse1click() end)
    task.wait(0.1)
    pcall(function() mouse1click() end)
    task.wait(0.1)
end

local function detectBite(bobber)
    if not bobber then return false end
    local mod = getGameMod()
    if mod and mod.DetectBite then
        local bitten = mod.DetectBite(bobber)
        if bitten then return true end
    end
    local startY = bobber.Position.Y
    task.wait(0.25)
    local curY = bobber.Position.Y
    if curY < startY - 1.2 or curY < -0.3 then return true end
    local vel = bobber.Velocity
    if vel and math.abs(vel.Y) > 2.5 then return true end
    if settings.detectMode == "aggressive" then
        local totalMove = math.abs(curY - startY)
        if totalMove > 0.5 then return true end
    end
    return false
end

local function findBait()
    local player = game.Players.LocalPlayer
    local char = player.Character
    local backpack = player.Backpack
    for _, name in ipairs({"Bait", "Umpan", "Cacing", "bait", "umpan"}) do
        local item = char and char:FindFirstChild(name)
        if item then return item end
        item = backpack:FindFirstChild(name)
        if item then return item end
    end
    for _, v in ipairs(backpack:GetChildren()) do
        if v:IsA("Tool") or v:IsA("HopperBin") then
            local n = v.Name:lower()
            if n:find("bait") or n:find("umpan") or n:find("cacing") or n:find("worm") then
                return v
            end
        end
    end
    return nil
end

local function sellFish()
    pcall(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local mod = getGameMod()
        local shop = mod and mod.FindShop and mod.FindShop()
        if not shop then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:lower():find("shop") or v.Name:lower():find("sell") or v.Name:lower():find("toko") or v.Name:lower():find("jual")) then
                    shop = v
                    break
                end
            end
        end
        if shop then
            hrp.CFrame = CFrame.new(shop.Position + Vector3.new(0, 3, 3))
            task.wait(0.5)
            local prompt = shop:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
    end)
end

local function autoSellCheck()
    if not settings.autoSell then return end
    if fishCount > 0 and fishCount % 5 == 0 then
        sellFish()
    end
end

local function mainLoop()
    while active do
        pcall(function()
            if not settings.autoCast then
                task.wait(1)
                return
            end

            statusText = "Casting..."
            castRod()
            statusText = "Waiting for bite..."

            local startTime = tick()
            local bitten = false

            while active and (tick() - startTime) < settings.maxWaitTime do
                local bobber = findBobber()
                if bobber and detectBite(bobber) then
                    bitten = true
                    task.wait(settings.reelDelay)
                    statusText = "Reeling..."
                    reelIn()
                    fishCount = fishCount + 1
                    totalEarnings = totalEarnings + math.random(10, 100)
                    print(string.format("[Fishing] Fish #%d caught! (+$%d)", fishCount, totalEarnings))
                    autoSellCheck()
                    statusText = "Caught! (" .. fishCount .. " fish)"
                    break
                end
                task.wait(0.15)
            end

            if not bitten then
                statusText = "No bite, re-casting..."
                reelIn()
            end

            task.wait(settings.castDelay)
        end)
        task.wait(0.3)
    end
    statusText = "Stopped"
end

function M.Start()
    if active then return end
    active = true
    fishCount = 0
    totalEarnings = 0
    print("[Fishing] Auto-fishing started")
    spawn(mainLoop)
end

function M.Stop()
    active = false
    print(string.format("[Fishing] Stopped. Fish: %d | Earned: $%d", fishCount, totalEarnings))
end

function M.GetStatus()
    return {running = active, fish = fishCount, earnings = totalEarnings, status = statusText}
end

function M.GetFishCount()
    return fishCount
end

function M.GetEarnings()
    return totalEarnings
end

function M.IsRunning()
    return active
end

function M.SetCastDelay(delay)
    settings.castDelay = math.max(1, math.min(30, delay))
end

function M.SetReelDelay(delay)
    settings.reelDelay = math.max(0.1, math.min(3, delay))
end

function M.SetMaxWait(time)
    settings.maxWaitTime = math.max(5, math.min(60, time))
end

function M.SetAutoCast(state)
    settings.autoCast = state
end

function M.SetDetectMode(mode)
    settings.detectMode = mode
end

function M.SetAutoSell(state)
    settings.autoSell = state
end

function M.SetAutoBait(state)
    settings.autoBait = state
end

function M.GetSettings()
    return settings
end

return M
