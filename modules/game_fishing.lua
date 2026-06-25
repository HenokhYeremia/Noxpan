local Game = {}
local gameData = {
    name = "Generic Fishing Game",
    gameId = -1,
    rodNames = {"Rod", "FishingRod", "Fishing", "Pole"},
    bobberNames = {"Bobber", "Hook", "Bait"},
    waterNames = {"Water", "Lake", "Ocean", "Sea", "Pond"},
    shopNames = {"Shop", "NPC", "Seller", "Merchant"},
}

function Game.GetName() return gameData.name end
function Game.GetGameId() return gameData.gameId end

function Game.FindRod()
    local player = game.Players.LocalPlayer
    for _, name in ipairs(gameData.rodNames) do
        for _, container in ipairs({player.Character, player.Backpack}) do
            if container then
                local tool = container:FindFirstChild(name)
                if tool and tool:IsA("Tool") then return tool end
            end
        end
    end
    local bp = player.Backpack
    for _, v in ipairs(bp:GetChildren()) do
        if v:IsA("Tool") then
            for _, name in ipairs(gameData.rodNames) do
                if v.Name:lower():find(name:lower()) then return v end
            end
        end
    end
    return nil
end

function Game.FindBobber()
    for _, name in ipairs(gameData.bobberNames) do
        local b = workspace:FindFirstChild(name) or workspace:FindFirstChild(name:lower())
        if b then return b end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Transparency < 0.8 then
            for _, name in ipairs(gameData.bobberNames) do
                if v.Name:lower():find(name:lower()) then return v end
            end
        end
    end
    return nil
end

function Game.FindWater()
    for _, name in ipairs(gameData.waterNames) do
        local w = workspace:FindFirstChild(name)
        if w and w:IsA("BasePart") then return w end
        w = workspace:FindFirstChild(name:lower())
        if w and w:IsA("BasePart") then return w end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Transparency > 0.7 then
            for _, name in ipairs(gameData.waterNames) do
                if v.Name:lower():find(name:lower()) then return v end
            end
        end
    end
    return nil
end

function Game.DetectBite(bobber)
    if not bobber then return false end
    local startY = bobber.Position.Y
    task.wait(0.25)
    local curY = bobber.Position.Y
    if curY < startY - 1 or curY < -0.3 then return true end
    local vel = bobber.Velocity
    if vel and math.abs(vel.Y) > 2.5 then return true end
    return false
end

return Game
