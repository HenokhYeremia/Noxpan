local ESP = {}
local active = false
local espSettings = {
    enabled = false,
    fish = true,
    players = false,
    chests = true,
    color = Color3.fromRGB(0, 255, 255),
    fishColor = Color3.fromRGB(0, 255, 100),
    chestColor = Color3.fromRGB(255, 200, 0),
    playerColor = Color3.fromRGB(255, 50, 50),
    showDistance = true,
    showName = true,
    scanRadius = 200,
}
local espObjects = {}

local function newHighlight(v, color)
    local hl = Instance.new("Highlight")
    hl.Name = "NoxpanESP"
    hl.Adornee = v
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.2
    hl.Parent = v
    return hl
end

local function newBillboard(v, text, color)
    local bg = Instance.new("BillboardGui")
    bg.Name = "NoxpanESP_Label"
    bg.Adornee = v
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = v

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 22)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = text
    nameLbl.TextColor3 = color
    nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLbl.TextStrokeTransparency = 0.3
    nameLbl.Font = Enum.Font.SourceSansBold
    nameLbl.TextSize = 13
    nameLbl.Parent = bg

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, 0, 0, 18)
    distLbl.Position = UDim2.new(0, 0, 0, 22)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = ""
    distLbl.TextColor3 = Color3.fromRGB(255, 255, 100)
    distLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    distLbl.TextStrokeTransparency = 0.3
    distLbl.Font = Enum.Font.SourceSans
    distLbl.TextSize = 11
    distLbl.Parent = bg

    return {gui = bg, nameLbl = nameLbl, distLbl = distLbl}
end

local function createESP(v, objType)
    if espObjects[v] then return end
    local color = espSettings.fishColor
    if objType == "player" then color = espSettings.playerColor
    elseif objType == "chest" then color = espSettings.chestColor end

    local hl = newHighlight(v, color)
    local bb = newBillboard(v, v.Name, color)
    espObjects[v] = {highlight = hl, billboard = bb, objType = objType}
end

local function removeESP(v)
    local data = espObjects[v]
    if data then
        pcall(function()
            data.highlight:Destroy()
            data.billboard.gui:Destroy()
        end)
        espObjects[v] = nil
    end
end

local function clearAll()
    for v, _ in pairs(espObjects) do
        pcall(function()
            v:FindFirstChild("NoxpanESP"):Destroy()
            v:FindFirstChild("NoxpanESP_Label"):Destroy()
        end)
    end
    espObjects = {}
end

local function shouldESP(v)
    if not espSettings.enabled then return false end
    if not v:IsA("Model") and not v:IsA("BasePart") then return false end
    local n = v.Name:lower()

    if espSettings.fish and (n:find("fish") or n:find("bobber") or n:find("bait") or n:find("ikan")) then
        return true, "fish"
    end
    if espSettings.players and v:IsA("Model") and v:FindFirstChild("Humanoid") then
        local plr = game.Players:GetPlayerFromCharacter(v)
        if plr and plr ~= game.Players.LocalPlayer then
            return true, "player"
        end
    end
    if espSettings.chests and (n:find("chest") or n:find("treasure") or n:find("crate") or n:find("loot") or n:find("peti") or n:find("harta")) then
        return true, "chest"
    end
    return false, nil
end

local function updateDistances()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for v, data in pairs(espObjects) do
        if v and v.Parent then
            local pos = v:IsA("BasePart") and v.Position or (v.PrimaryPart and v.PrimaryPart.Position)
            if pos then
                local dist = (pos - hrp.Position).Magnitude
                data.billboard.distLbl.Text = string.format("%.0f studs", dist)
            end
        end
    end
end

local function scanLoop()
    while active do
        task.wait(0.6)
        if not espSettings.enabled then
            if next(espObjects) then clearAll() end
            continue
        end
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local r = espSettings.scanRadius

            for _, v in ipairs(workspace:GetDescendants()) do
                if v:FindFirstChild("NoxpanESP") then continue end
                local ok, objType = shouldESP(v)
                if ok then
                    local pos = v:IsA("BasePart") and v.Position or (v.PrimaryPart and v.PrimaryPart.Position)
                    if pos and (pos - hrp.Position).Magnitude < r then
                        createESP(v, objType)
                    end
                end
            end

            for v, _ in pairs(espObjects) do
                if not v.Parent then removeESP(v)
                elseif v:IsA("BasePart") or (v.PrimaryPart) then
                    local pos = v:IsA("BasePart") and v.Position or v.PrimaryPart.Position
                    if pos and (pos - hrp.Position).Magnitude > r + 50 then
                        removeESP(v)
                    end
                end
            end

            updateDistances()
        end)
    end
end

function ESP.Start()
    if active then return end
    active = true
    spawn(scanLoop)
end

function ESP.Toggle()
    espSettings.enabled = not espSettings.enabled
    if not espSettings.enabled then clearAll() end
    return espSettings.enabled
end

function ESP.SetFish(state) espSettings.fish = state end
function ESP.SetPlayers(state) espSettings.players = state end
function ESP.SetChests(state) espSettings.chests = state end

function ESP.GetSettings()
    return espSettings
end

function ESP.Stop()
    active = false
    clearAll()
end

return ESP
