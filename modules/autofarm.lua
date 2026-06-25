local AutoFarm = {}
local active = false
local settings = {
    autoSell = false,
    autoBuyBait = false,
    autoCollect = false,
    sellInterval = 60,
    collectRadius = 30,
}

local function findItems()
    local items = {}
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return items end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return items end

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.5 and v.CanCollide then
            local dist = (v.Position - hrp.Position).Magnitude
            if dist < settings.collectRadius then
                if v.Name:lower():find("fish") or v.Name:lower():find("drop") or v.Name:lower():find("item") or v.Name:lower():find("chest") then
                    table.insert(items, v)
                end
            end
        end
    end
    return items
end

local function teleportToItem(item)
    pcall(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(item.Position + Vector3.new(0, 3, 0))
        task.wait(0.2)
        fireproximityprompt and pcall(fireproximityprompt, item)
    end)
end

local function triggerSell()
    pcall(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local shop = workspace:FindFirstChild("Shop")
        if not shop then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:lower():find("shop") or v.Name:lower():find("sell")) then
                    shop = v
                    break
                end
            end
        end

        if shop then
            hrp.CFrame = CFrame.new(shop.Position + Vector3.new(0, 3, 2))
            task.wait(0.5)
            local proximityPrompt = shop:FindFirstChildWhichIsA("ProximityPrompt")
            if proximityPrompt then
                fireproximityprompt and pcall(fireproximityprompt, proximityPrompt)
            end
        end
    end)
end

local function autoSellLoop()
    while active and settings.autoSell do
        task.wait(settings.sellInterval)
        triggerSell()
        print("[AutoFarm] Auto-sell triggered")
    end
end

local function autoCollectLoop()
    while active and settings.autoCollect do
        task.wait(2)
        local items = findItems()
        for _, item in ipairs(items) do
            teleportToItem(item)
            task.wait(0.3)
        end
    end
end

function AutoFarm.Start()
    if active then return end
    active = true
    print("[AutoFarm] Started")
    spawn(autoSellLoop)
    spawn(autoCollectLoop)
end

function AutoFarm.SetAutoSell(state)
    settings.autoSell = state
    if state then
        spawn(autoSellLoop)
    end
end

function AutoFarm.SetAutoBuyBait(state)
    settings.autoBuyBait = state
end

function AutoFarm.SetAutoCollect(state)
    settings.autoCollect = state
    if state then
        spawn(autoCollectLoop)
    end
end

function AutoFarm.GetSettings()
    return settings
end

function AutoFarm.Stop()
    active = false
end

return AutoFarm
