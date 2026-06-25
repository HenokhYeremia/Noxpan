local Hub = {}
local gui, main, titleBar = nil, nil, nil
local dragging, dragStart, framePos = false, nil, nil
local minimized, hubEnabled = false, true
local userTier, gameName = "free", "unknown"
local mods = {}
local tabs = {}
local statLabel = nil
local fishCountLabel = nil

local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            framePos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function newToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 36, 0, 22)
    btn.Position = UDim2.new(1, -42, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = frame

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -10, 0, 1)
    line.Position = UDim2.new(0, 5, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    line.BorderSizePixel = 0
    line.Parent = frame

    local state = default or false
    local function updateBtn()
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(45, 130, 45)
            btn.Text = "ON"
            btn.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Text = "OFF"
            btn.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
    updateBtn()

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateBtn()
        if callback then pcall(callback, state) end
    end)

    return btn, frame
end

local function newSlider(parent, text, min, max, default, callback, suffix)
    suffix = suffix or ""
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 130, 0, 18)
    label.Position = UDim2.new(0, 8, 0, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 50, 0, 18)
    valLabel.Position = UDim2.new(1, -58, 0, 1)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default) .. suffix
    valLabel.TextColor3 = Color3.fromRGB(255, 210, 100)
    valLabel.Font = Enum.Font.SourceSansBold
    valLabel.TextSize = 13
    valLabel.Parent = frame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -10, 0, 5)
    bg.Position = UDim2.new(0, 5, 0, 25)
    bg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    bg.BorderSizePixel = 0
    bg.ClipsDescendants = true
    bg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -10, 0, 1)
    line.Position = UDim2.new(0, 5, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    line.BorderSizePixel = 0
    line.Parent = frame

    local val = default
    local sliding = false

    local function update(inputPos)
        local absPos = bg.AbsolutePosition
        local absSize = bg.AbsoluteSize
        if absSize.X <= 0 then return end
        local rx = math.clamp(inputPos.X - absPos.X, 0, absSize.X)
        local pct = rx / absSize.X
        val = math.floor(min + pct * (max - min) + 0.5)
        val = math.clamp(val, min, max)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        valLabel.Text = tostring(val) .. suffix
        if callback then pcall(callback, val) end
    end

    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            update(input.Position)
        end
    end)
    bg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position)
        end
    end)

    return bg
end

local function newTab(parent, name)
    local margin = 5
    local tabW = 72
    local x = margin + #tabs * (tabW + 4)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, tabW, 0, 26)
    btn.Position = UDim2.new(0, x, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = parent

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -75)
    content.Position = UDim2.new(0, 5, 0, 64)
    content.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Visible = false
    content.Parent = parent

    local uilist = Instance.new("UIListLayout")
    uilist.Padding = UDim.new(0, 1)
    uilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uilist.SortOrder = Enum.SortOrder.LayoutOrder
    uilist.Parent = content
    uilist:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, uilist.AbsoluteContentSize.Y + 4)
    end)

    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1, -10, 0, 1)
    spacer.Position = UDim2.new(0, 5, 0, 62)
    spacer.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    spacer.BorderSizePixel = 0
    spacer.Parent = parent

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.content.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            t.btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 130)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        content.Visible = true
    end)

    table.insert(tabs, {btn = btn, content = content})
    if #tabs == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 130)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        content.Visible = true
    end
    return content
end

local function newLabel(parent, text, color)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 22)
    f.BackgroundColor3 = color or Color3.fromRGB(40, 80, 45)
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 5, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.SourceSansBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    return f
end

local function updateStatusBar()
    if not statLabel then return end
    local fishing = mods.fishing
    if fishing then
        local s = fishing.GetStatus()
        statLabel.Text = string.format("  [%s] Fish: %d | $%d | %s",
            string.upper(userTier), s.fish, s.earnings, s.status)
    else
        statLabel.Text = string.format("  [%s] %s | %s", string.upper(userTier), game.Players.LocalPlayer.Name, gameName)
    end
end

function Hub.Init(tier, modules, game)
    userTier = tier or "free"
    mods = modules or {}
    gameName = game or "unknown"
    _G.NoxpanLoaded = modules

    print(string.format("[Hub] Loading Noxpan v3.0 | %s | %s", string.upper(userTier), gameName))

    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("NoxpanHub")
        if old then old:Destroy() end
    end)

    gui = Instance.new("ScreenGui")
    gui.Name = "NoxpanHub"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false

    main = Instance.new("Frame")
    main.Size = UDim2.new(0, 460, 0, 400)
    main.Position = UDim2.new(0.5, -230, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui
    makeDraggable(main)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
    accent.BorderSizePixel = 0
    accent.Parent = main

    titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 2)
    titleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Noxpan v3.0"
    title.TextColor3 = Color3.fromRGB(200, 200, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -56, 0, 3)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    minBtn.BorderSizePixel = 0
    minBtn.Text = "-"
    minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.TextSize = 16
    minBtn.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar

    local statColor = (userTier == "premium") and Color3.fromRGB(35, 80, 50) or Color3.fromRGB(80, 60, 30)
    statLabel = newLabel(main, "  Loading...", statColor)

    -- ===== FISHING TAB =====
    local fishTab = newTab(main, "Fishing")
    newToggle(fishTab, "Auto-Fishing", false, function(state)
        if mods.fishing then
            if state then mods.fishing.Start() else mods.fishing.Stop() end
        end
    end)
    newSlider(fishTab, "Cast Delay (s)", 1, 10, 3, function(val)
        if mods.fishing then mods.fishing.SetCastDelay(val) end
    end)
    newSlider(fishTab, "Reel Delay (s)", 0.1, 2, 0.5, function(val)
        if mods.fishing then mods.fishing.SetReelDelay(val) end
    end)
    newSlider(fishTab, "Max Wait (s)", 5, 30, 15, function(val)
        if mods.fishing then mods.fishing.SetMaxWait(val) end
    end)
    newToggle(fishTab, "Auto-Sell Fish", false, function(state)
        if mods.fishing then mods.fishing.SetAutoSell(state) end
    end)
    newToggle(fishTab, "Auto-Bait", false, function(state)
        if mods.fishing then mods.fishing.SetAutoBait(state) end
    end)

    -- ===== PLAYER TAB =====
    local playerTab = newTab(main, "Player")
    newSlider(playerTab, "WalkSpeed", 16, 250, 50, function(val)
        if mods.player then mods.player.SetWalkSpeed(val) end
    end)
    newSlider(playerTab, "Jump Power", 50, 250, 80, function(val)
        if mods.player then mods.player.SetJumpPower(val) end
    end)
    newToggle(playerTab, "Anti-Drown", false, function(state)
        if mods.player then mods.player.SetAntiDrown(state) end
    end)
    newToggle(playerTab, "NoClip", false, function(state)
        if mods.player then mods.player.SetNoClip(state) end
    end)
    newToggle(playerTab, "Infinite Jump", false, function(state)
        if mods.player then mods.player.SetInfJump(state) end
    end)
    newToggle(playerTab, "Fly (WASD)", false, function(state)
        if mods.player then mods.player.SetFly(state) end
    end)

    -- ===== ESP TAB =====
    local espTab = newTab(main, "ESP")
    newToggle(espTab, "ESP Enabled", false, function(state)
        if mods.esp then
            if state then mods.esp.Start(); mods.esp.Toggle()
            else mods.esp.Stop() end
        end
    end)
    newToggle(espTab, "Fish ESP", true, function(state)
        if mods.esp then mods.esp.SetFish(state) end
    end)
    newToggle(espTab, "Player ESP", false, function(state)
        if mods.esp then mods.esp.SetPlayers(state) end
    end)
    newToggle(espTab, "Chest / Loot", true, function(state)
        if mods.esp then mods.esp.SetChests(state) end
    end)

    -- ===== MISC TAB =====
    local miscTab = newTab(main, "Misc")
    newToggle(miscTab, "Auto-Clicker", false, function(state)
        if mods.autoclick then
            if state then mods.autoclick.Start(0.05) else mods.autoclick.Stop() end
        end
    end)
    newSlider(miscTab, "Click Speed (s)", 0.01, 1, 0.05, function(val)
        if mods.autoclick then mods.autoclick.SetSpeed(val) end
    end)
    newToggle(miscTab, "Auto-Collect Items", false, function(state)
        if mods.autofarm then mods.autofarm.SetAutoCollect(state) end
    end)

    if userTier ~= "premium" then
        newLabel(miscTab, "  Premium: auto-fishing, ESP, fly, noclip", Color3.fromRGB(80, 35, 35))
    end

    -- Status bar updater
    spawn(function()
        while gui and gui.Parent do
            task.wait(1)
            pcall(updateStatusBar)
        end
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        Hub.Stop()
    end)

    -- Minimize
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            main.Size = UDim2.new(0, 460, 0, 35)
            for _, v in ipairs(main:GetChildren()) do
                if v ~= titleBar and v ~= accent then v.Visible = false end
            end
            title.Text = "Noxpan [Minimized]"
        else
            main.Size = UDim2.new(0, 460, 0, 400)
            title.Text = "Noxpan v3.0"
            for _, v in ipairs(main:GetChildren()) do v.Visible = true end
            for _, t in ipairs(tabs) do
                if t.btn.BackgroundColor3 == Color3.fromRGB(60, 60, 130) then
                    t.content.Visible = true
                end
            end
        end
    end)

    -- Toggle with RightShift (desktop)
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            hubEnabled = not hubEnabled
            main.Visible = hubEnabled
        end
    end)

    -- Floating toggle button (mobile + desktop fallback)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 36)
    toggleBtn.Position = UDim2.new(0, 10, 0.5, -18)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "N"
    toggleBtn.TextColor3 = Color3.fromRGB(160, 160, 200)
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 18
    toggleBtn.Parent = gui
    toggleBtn.ZIndex = 10
    local uis = game:GetService("UserInputService")
    toggleBtn.Visible = uis.TouchEnabled
    if uis.TouchEnabled then makeDraggable(toggleBtn) end
    toggleBtn.MouseButton1Click:Connect(function()
        hubEnabled = not hubEnabled
        main.Visible = hubEnabled
    end)

    print("[Hub] Ready")
end

function Hub.Stop()
    for _, m in pairs(mods) do
        if m and m.Stop then pcall(m.Stop) end
    end
    pcall(function()
        local g = game:GetService("CoreGui"):FindFirstChild("NoxpanHub")
        if g then g:Destroy() end
    end)
    gui = nil
    print("[Hub] Stopped")
end

function Hub.UpdateStatus(text)
    if statLabel then
        statLabel.Text = "  " .. text
    end
end

return Hub
