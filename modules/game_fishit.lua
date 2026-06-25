local Game = {}
local gameData = {
    name = "Pemancing FishIt",
    gameId = 6701277882,
    rodNames = {"Rod", "FishingRod", "Pancingan", "Pancing"},
    bobberNames = {"Bobber", "Pelampung", "Hook", "Kail"},
    shopNames = {"Shop", "Toko", "Seller", "Penjual"},
    waterNames = {"Water", "Air", "Danau", "Laut"},
    baitNames = {"Bait", "Umpan", "Cacing", "UmpanCacing"},
}

function Game.GetName()
    return gameData.name
end

function Game.GetGameId()
    return gameData.gameId
end

function Game.GetRodNames()
    return gameData.rodNames
end

function Game.GetBobberNames()
    return gameData.bobberNames
end

function Game.FindRod()
    local player = game.Players.LocalPlayer
    local char = player.Character
    for _, name in ipairs(gameData.rodNames) do
        local rod = char and char:FindFirstChild(name)
        if rod and rod:IsA("Tool") then return rod end
        rod = player.Backpack:FindFirstChild(name)
        if rod and rod:IsA("Tool") then return rod end
    end
    for _, v in ipairs(player.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            for _, name in ipairs(gameData.rodNames) do
                if v.Name:lower():find(name:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

function Game.FindBobber()
    for _, name in ipairs(gameData.bobberNames) do
        local bobber = workspace:FindFirstChild(name)
        if bobber then return bobber end
        bobber = workspace:FindFirstChild(name:lower())
        if bobber then return bobber end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Transparency < 0.5 then
            for _, name in ipairs(gameData.bobberNames) do
                if v.Name:lower():find(name:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

function Game.FindWater()
    for _, name in ipairs(gameData.waterNames) do
        local water = workspace:FindFirstChild(name)
        if water and water:IsA("BasePart") then return water end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") then
            for _, name in ipairs(gameData.waterNames) do
                if v.Name:lower():find(name:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

function Game.FindShop()
    for _, name in ipairs(gameData.shopNames) do
        local shop = workspace:FindFirstChild(name)
        if shop then return shop end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") then
            for _, name in ipairs(gameData.shopNames) do
                if v.Name:lower():find(name:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

function Game.DetectBite(bobber)
    if not bobber then return false end
    local startY = bobber.Position.Y
    task.wait(0.2)
    local currentY = bobber.Position.Y
    if currentY < startY - 1 or currentY < -0.5 then
        return true
    end
    local vel = bobber.Velocity
    if vel and math.abs(vel.Y) > 3 then
        return true
    end
    return false
end

return Game
