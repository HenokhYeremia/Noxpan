local Settings = {}
local store = {}
local saveKey = "Noxpan_Settings"

function Settings.Init()
    pcall(function()
        local data = game:GetService("HttpService"):JSONEncode(store)
        -- Use a ModuleScript in CoreGui for persistence
        local folder = game:GetService("CoreGui"):FindFirstChild("NoxpanData")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "NoxpanData"
            folder.Parent = game:GetService("CoreGui")
        end
        local mod = folder:FindFirstChild("Settings")
        if not mod then
            mod = Instance.new("ModuleScript")
            mod.Name = "Settings"
            mod.Parent = folder
        end
        mod.Source = "return " .. data
    end)
end

function Settings.Get(key, default)
    if store[key] ~= nil then return store[key] end
    -- Try loading from saved data
    pcall(function()
        local folder = game:GetService("CoreGui"):FindFirstChild("NoxpanData")
        if folder then
            local mod = folder:FindFirstChild("Settings")
            if mod and mod:IsA("ModuleScript") then
                local ok, data = pcall(require, mod)
                if ok and type(data) == "table" then
                    store = data
                end
            end
        end
    end)
    if store[key] ~= nil then return store[key] end
    return default
end

function Settings.Set(key, value)
    store[key] = value
    Settings.Save()
end

function Settings.Save()
    pcall(function()
        local folder = game:GetService("CoreGui"):FindFirstChild("NoxpanData")
        if folder then
            local mod = folder:FindFirstChild("Settings")
            if mod and mod:IsA("ModuleScript") then
                local data = game:GetService("HttpService"):JSONEncode(store)
                mod.Source = "return " .. data
            end
        end
    end)
end

function Settings.GetAll()
    return store
end

function Settings.Reset()
    store = {}
    Settings.Save()
end

return Settings
