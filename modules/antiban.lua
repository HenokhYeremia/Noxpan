local AntiBan = {}
local active = false

local function randomString(len)
    len = len or 8
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for _ = 1, len do
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

function AntiBan.Start()
    if active then return end
    active = true
    print("[AntiBan] Protection active")

    spawn(function()
        while active do
            task.wait(math.random(30, 90))
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    local humanoid = char.Humanoid
                    if humanoid:FindFirstChild("Animator") then
                        local animator = humanoid.Animator
                        if animator:FindFirstChildOfClass("AnimationTrack") then
                            animator:FindFirstChildOfClass("AnimationTrack"):Stop()
                        end
                    end
                end
            end)
        end
    end)

    spawn(function()
        while active do
            task.wait(math.random(45, 120))
            pcall(function()
                for _, v in ipairs(game.CoreGui:GetDescendants()) do
                    if v:IsA("ScreenGui") and v.Name ~= "NoxpanHub" then
                        if v.Enabled and #v:GetChildren() > 0 then
                        end
                    end
                end
            end)
        end
    end)
end

function AntiBan.Stop()
    active = false
end

function AntiBan.IsActive()
    return active
end

return AntiBan
