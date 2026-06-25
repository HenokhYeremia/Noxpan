local PlayerMod = {}
local boosts = {
    walkSpeed = 16,
    jumpPower = 50,
    antiDrown = false,
    noClip = false,
    infJump = false,
    fly = false,
}
local active = false
local flyBodyVelocity = nil
local jumpConn = nil

local function setWalkSpeed(speed)
    pcall(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speed
        end
    end)
end

local function setJumpPower(power)
    pcall(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = power
            char.Humanoid.UseJumpPower = true
        end
    end)
end

local function applyBoosts()
    pcall(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid.WalkSpeed = boosts.walkSpeed
        humanoid.JumpPower = boosts.jumpPower
    end)
end

local function antiDrownLoop()
    while active and boosts.antiDrown do
        task.wait(0.5)
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if hrp.Position.Y < -5 then
                hrp.Velocity = Vector3.new(0, 50, 0)
                local water = workspace:FindFirstChild("Water")
                if water and water:IsA("BasePart") then
                    hrp.Position = Vector3.new(hrp.Position.X, water.Position.Y + 5, hrp.Position.Z)
                end
            end
        end)
    end
end

local function noClipLoop()
    while active and boosts.noClip do
        task.wait(0.2)
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char then return end
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end

local function flyLoop()
    while active and boosts.fly do
        task.wait(0.1)
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not flyBodyVelocity then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                flyBodyVelocity.Parent = hrp
            end
            local moveDir = Vector3.new()
            local userInput = game:GetService("UserInputService")
            if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
            if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
            if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
            if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
            if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0, -1, 0) end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * 50
            end
            flyBodyVelocity.Velocity = moveDir
        end)
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
end

function PlayerMod.Start()
    if active then return end
    active = true
    print("[Player] Starting player module")

    local player = game.Players.LocalPlayer
    player.CharacterAdded:Connect(function()
        task.wait(1)
        applyBoosts()
    end)

    jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
        if boosts.infJump then
            pcall(function()
                local plr = game.Players.LocalPlayer
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") then
                    chr.Humanoid.Jump = true
                end
            end)
        end
    end)

    applyBoosts()
    spawn(antiDrownLoop)
    spawn(noClipLoop)
    spawn(flyLoop)
end

function PlayerMod.SetWalkSpeed(speed)
    boosts.walkSpeed = math.clamp(speed, 16, 250)
    setWalkSpeed(boosts.walkSpeed)
end

function PlayerMod.SetJumpPower(power)
    boosts.jumpPower = math.clamp(power, 50, 250)
    setJumpPower(boosts.jumpPower)
end

function PlayerMod.SetAntiDrown(state)
    boosts.antiDrown = state
end

function PlayerMod.SetNoClip(state)
    boosts.noClip = state
end

function PlayerMod.SetInfJump(state)
    boosts.infJump = state
    if state then
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Jump = true
            end
        end)
    end
end

function PlayerMod.SetFly(state)
    boosts.fly = state
    if not state and flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
end

function PlayerMod.GetSpeed()
    return boosts.walkSpeed
end

function PlayerMod.GetJump()
    return boosts.jumpPower
end

function PlayerMod.Stop()
    active = false
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
end

return PlayerMod
