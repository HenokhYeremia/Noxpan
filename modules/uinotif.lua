local M = {}

function M.Notify(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "MyScript";
        Text = text;
        Duration = 3;
    })
end

return M
