local M = {}

function M.Start(speed)
    speed = speed or 0.1
    print("[AutoClick] Started at speed:", speed)

    spawn(function()
        while true do
            pcall(function()
                mouse1click()
            end)
            task.wait(speed)
        end
    end)
end

return M
