local M = {}

function M.Notify(text, duration)
    duration = duration or 3
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Noxpan",
            Text = tostring(text),
            Duration = duration
        })
    end)
end

function M.Alert(title, text, duration)
    duration = duration or 5
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration
        })
    end)
end

return M
