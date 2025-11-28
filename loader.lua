-- ============================================
-- LOADER BUATANMU SENDIRI - ORIGINAL SYSTEM
-- ============================================

-- Ganti link berikut nanti setelah upload
local userDB = "https://yourdomain.com/users.txt"
local scriptFree = "https://yourdomain.com/main_free.lua"
local scriptPremium = "https://yourdomain.com/main_premium.lua"

-- fungsi request sederhana
local function req(url)
    return game:HttpGet(url)
end

local function run(url)
    loadstring(req(url))()
end

-- fungsi baca status user
local function getStatus(name)
    local data = req(userDB)
    for line in data:gmatch("[^\r\n]+") do
        local uname, status = line:match("([^:]+):([^:]+)")
        if uname == name then
            return status
        end
    end
    return "unknown"
end

-- cek username player
local username = game.Players.LocalPlayer.Name
local status = getStatus(username)

if status == "ban" then
    return warn("[LOADER] Kamu diban dari akses script.")
elseif status == "premium" then
    print("[LOADER] Premium user terdeteksi")
    run(scriptPremium)
elseif status == "free" then
    print("[LOADER] Free user terdeteksi")
    run(scriptFree)
else
    warn("[LOADER] Username tidak terdaftar.")
end
