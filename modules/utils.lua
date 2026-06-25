local Utils = {}

function Utils.Request(url)
    local success, result = pcall(game.HttpGet, game, url)
    if not success then
        return nil, "HTTP request failed: " .. tostring(result)
    end
    return result, nil
end

function Utils.SafeCall(func, ...)
    local args = {...}
    return pcall(function()
        func(unpack(args))
    end)
end

function Utils.FindBobber()
    local bobber = workspace:FindFirstChild("Bobber")
    if bobber then return bobber end
    bobber = workspace:FindFirstChild("bobber")
    if bobber then return bobber end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():find("bobber") then
            return v
        end
        if v:IsA("Part") and v.Name:lower():find("hook") then
            return v
        end
    end
    return nil
end

function Utils.FindRod()
    local player = game.Players.LocalPlayer
    local rod = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
    if rod then return rod end
    rod = player.Backpack:FindFirstChildWhichIsA("Tool")
    if rod then return rod end
    for _, v in ipairs(player.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("rod") then
            return v
        end
    end
    return nil
end

function Utils.EquipRod(rod)
    local player = game.Players.LocalPlayer
    if not rod then rod = Utils.FindRod() end
    if not rod then return false end
    local char = player.Character
    if not char then return false end
    if char:FindFirstChild(rod.Name) then return true end
    local success, err = pcall(function()
        rod.Parent = char
    end)
    if not success then
        local backpackRod = player.Backpack:FindFirstChild(rod.Name)
        if backpackRod then
            pcall(function()
                backpackRod.Parent = char
            end)
        end
    end
    task.wait(0.3)
    return char:FindFirstChild(rod.Name) ~= nil
end

function Utils.FindShop()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and (v.Name:lower():find("shop") or v.Name:lower():find("seller") or v.Name:lower():find("npc")) then
            return v
        end
    end
    return nil
end

function Utils.FindWaterBody()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():find("water") then
            return v
        end
        if v:IsA("Terrain") then
            return v
        end
    end
    return workspace:FindFirstChild("Terrain") or workspace:FindFirstChild("Water")
end

function Utils.GetDistance(a, b)
    if not a or not b then return math.huge end
    local aPos = a:IsA("BasePart") and a.Position or (a.Character and a.Character.PrimaryPart and a.Character.PrimaryPart.Position)
    local bPos = b:IsA("BasePart") and b.Position or (b.Character and b.Character.PrimaryPart and b.Character.PrimaryPart.Position)
    if not aPos or not bPos then return math.huge end
    return (aPos - bPos).Magnitude
end

function Utils.CreateNotification(title, text, duration)
    duration = duration or 3
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration
        })
    end)
end

function Utils.RandomDelay(min, max)
    min = min or 0.05
    max = max or 0.15
    return min + math.random() * (max - min)
end

return Utils
