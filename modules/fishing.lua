local M = {}

function M.Start()
    print("[Fishing] Started")
    -- contoh: fitur sederhana
    for i = 1, 3 do
        print("Memancing...")
        task.wait(1)
    end
    print("Fishing Selesai!")
end

return M
