-- ============================================================
-- Xaou Unlock Gong Addon
-- ไฟล์แยกสำหรับเพิ่มปุ่ม "ปลดล็อกวิชา" ในหน้า NPC Commands
-- วางที่: Scripts/Xaou_009_1/99_Xaou_UnlockGong_Addon.lua
-- ต้องใช้คู่กับ: Settings/MapStories/Xaou_UnlockGong_Bridge.xml
-- ============================================================

Xaou_UnlockGong_Addon_Loaded = true

-- กันชื่อซ้ำในหน้าเมนู
local function Xaou_UnlockGong_HasButton(list)
    if type(list) ~= "table" then return false end
    for _, v in ipairs(list) do
        local t = tostring(v.text or "")
        if string.find(t, "ปลดล็อกวิชา") ~= nil or tostring(v.page or "") == "unlockgong" then
            return true
        end
    end
    return false
end

-- เก็บฟังก์ชันเดิมไว้ แล้วครอบเพิ่มหน้าใหม่เข้าไป
local Xaou_GetNpcCommands_Old_UnlockGong = Xaou_GetNpcCommands

function Xaou_GetNpcCommands(page)
    page = tostring(page or "main")

    -- หน้าใหม่: ปลดล็อกวิชา
    if page == "unlockgong" then
        return {
            {
                text="1. 📖 ปลดล็อกวิชาสายหลักทั้งหมด",
                actions={{kind="story", story="Xaou_Unlock_AllGong"}}
            },
            {
                text="2. ⭐ สุ่มปลดล็อกวิชาระดับสวรรค์ 20 ครั้ง",
                actions={{kind="story", story="Xaou_Unlock_RandomHeavenGong20"}}
            },
            {
                text="3. 📜 เปิดเมนู XML เดิม",
                actions={{kind="story", story="ปลด1"}}
            },
            { text="0. ◀ กลับ", page="main" },
        }
    end

    local list = {}
    if type(Xaou_GetNpcCommands_Old_UnlockGong) == "function" then
        list = Xaou_GetNpcCommands_Old_UnlockGong(page) or {}
    end

    -- เพิ่มปุ่มไว้หน้า main โดยไม่แก้ไฟล์ 04 เดิม
    if page == "main" and type(list) == "table" and not Xaou_UnlockGong_HasButton(list) then
        local newList = {}
        local inserted = false

        for _, cmd in ipairs(list) do
            -- แทรกก่อน NPC สำนักอื่น ถ้าเจอ
            if not inserted and string.find(tostring(cmd.text or ""), "NPC สำนักอื่น") ~= nil then
                table.insert(newList, { text="7. 📖 ปลดล็อกวิชา", page="unlockgong" })
                inserted = true
            end
            table.insert(newList, cmd)
        end

        if not inserted then
            table.insert(newList, { text="📖 ปลดล็อกวิชา", page="unlockgong" })
        end

        return newList
    end

    return list
end

print("[Xaou] Unlock Gong Addon loaded")
