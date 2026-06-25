local M = {}
local active = false
local clickThread = nil
local clickSpeed = 0.1
local totalClicks = 0

local function clickLoop()
    while active do
        pcall(function()
            mouse1click()
            totalClicks = totalClicks + 1
        end)
        task.wait(clickSpeed)
    end
end

function M.Start(speed)
    if active then return end
    speed = speed or 0.1
    clickSpeed = math.max(0.01, speed)
    active = true
    totalClicks = 0
    print("[AutoClick] Started at " .. clickSpeed .. "s interval")
    clickThread = spawn(clickLoop)
end

function M.Stop()
    active = false
    clickThread = nil
    print("[AutoClick] Stopped (clicks: " .. totalClicks .. ")")
end

function M.SetSpeed(speed)
    clickSpeed = math.max(0.01, speed or 0.1)
end

function M.GetTotalClicks()
    return totalClicks
end

function M.IsRunning()
    return active
end

return M
