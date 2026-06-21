--------------------------------------------------
-- Xaou_009 Mod System
-- Author : xaouxaou009
-- File   : 12_Xaou_WarpSystem.lua
-- System : Warp System / Map Tools
-- Version: 2.9.0
--
-- Changelog
-- v2.9.0
-- - เปลี่ยนเป้าหมายจาก WorldMapMgr เป็น RPGMapMgr + Wnd_SelectNpc4Map ตามผลแกะ .dat
-- - เพิ่ม WorldLuaHelper Tester: UnLockPlace / CheckPlaceUnLock / UnLockWorld / GetPlaceName
-- - เพิ่ม RPGMapMgr Tester: GetWorldsInPlace / EnterRPGWorld / SwitchMap แบบจับ error
-- - เพิ่ม Wnd_SelectNpc4Map Probe เพื่อหาจุดเรียก EnterPlace/EnterWorld/ClickYes
--
-- v2.6.0
-- - เพิ่มหน้า Warp Tester แยกเป็นหน้า 3
-- - เพิ่ม TestTravelApi ทดลองเรียก Enter/Goto/Travel/Open ทีละชุด
-- - จับ error ทุกครั้ง ไม่ให้ค้างถ้าเรียกไม่ได้
--
-- v2.5.0
-- - จัดหน้า UI เป็นหน้าใช้งานจริง / Debug
-- - เพิ่ม DebugRuntimeManagerScan หา manager ที่อาจมีคำสั่งเดินทาง
-- - ไม่เรียกคำสั่งวาร์ปเสี่ยง ๆ โดยตรง
--
-- v2.4.0
-- - เพิ่มการสแกน Method/Field ของ PlacesMgr และ PlaceDef โดยไม่เรียกคำสั่งเสี่ยง
-- - เพิ่มรายงาน candidate API เช่น Enter/Visit/Goto/Open/Travel เพื่อหาคำสั่งเปลี่ยนสถานที่
--
-- v2.3.0
-- - เพิ่ม DebugPlacesMgr / DebugPlacesMgrList เพื่อทดสอบ PlacesMgr ของเกมจริงบนมือถือ
-- - อ้างอิงจากม็อด PC: PlacesMgr.Places / PlacesMgr:GetPlaceDef(localKey) / PlacesMgr:UnlockAll()
-- - ยังไม่เพิ่มคำสั่งวาร์ปข้ามสถานที่ จนกว่าจะยืนยัน API เปลี่ยนแมพจริง
--
-- v2.2.0
-- - เพิ่มเครื่องมือค้นหา Place จากช่องค้นหาในหน้า Warp
-- - เพิ่มตัวช่วยวิเคราะห์ความต่าง World X/Y กับ Grid Key
-- - เพิ่มรายงาน Place ใกล้เคียงตามฐานข้อมูล Settings เพื่อใช้แกะสูตรแปลงพิกัด
--
-- v2.1.0
-- - เพิ่ม Map Database จาก Settings/World/Places จำนวน 94 รายการ
-- - เพิ่มปุ่มรายชื่อสถานที่ / หน้าถัดไป / สถานที่สำนัก
-- - ข้อมูล X/Y เป็นพิกัดโลก ยังไม่ใช่ Grid Key สำหรับ SetPostion โดยตรง
--
-- v2.0.0
-- - เพิ่ม FocusTarget: เลื่อนกล้อง/หน้าจอไปยัง NPC ที่เลือกด้วย NpcKey
-- - เพิ่ม DebugWarpSummary: สรุป HomeKey / TargetKey / key รอบสำนักในหน้าเดียว
-- - เก็บคำสั่งที่ใช้ได้แล้ว: วาร์ป NPC กลับสำนัก / เปิดหมอก / Debug Map/NPC
-- - ไม่แตะระบบ NPC / Item / Book เดิม
--
-- v1.8.0
-- - แก้ Debug Map / NPC / AroundHome ให้เป็นแบบปลอดภัย ไม่เรียก API หนัก
-- - ลดโอกาสเกมค้างตอนกดปุ่ม Debug
-- - เก็บคำสั่งวาร์ปกลับสำนักและเปิดหมอกที่ใช้ได้ไว้เหมือนเดิม
--
-- v1.7.0
-- - เพิ่มฟังก์ชัน DebugMapInfo / DebugTargetInfo / DebugAroundHomeKeys จริง
-- - แก้ปุ่มดูข้อมูล Map / Key และ NPC / Key ให้กดติด
-- - แสดง key รอบสำนักพร้อมพิกัด x,y
--
-- v1.6.0
-- - เพิ่ม DebugMapInfo / DebugTargetInfo / DebugAroundHomeKeys
-- - ใช้ข้อมูลจริงจากมือถือช่วยหา key วาร์ป ไม่สุ่มมั่ว
-- - ไม่แตะระบบ NPC / Item / Book เดิม
--
-- v1.5.0
-- - เก็บคำสั่งที่ทดสอบแล้วว่าใช้ได้: เปิดหมอก / วาร์ป NPC กลับสำนัก
-- - ใช้ SetPostion / SetPostionOnly เป็นหลักตามที่เจอจากม็อด PC
-- - เพิ่ม DebugHomeKey สำหรับดู key จุดสำนัก/จุดกลางแผนที่
-- - ปรับ ClearDust / UnlockAllPlaces ให้ลองหลายวิธีแบบปลอดภัย
-- - ไม่แตะระบบ NPC / Item / Book เดิม
--------------------------------------------------

Xaou_WarpSystem = Xaou_WarpSystem or {}

local function XaouWarp_Msg(text, title)
    title = title or "ระบบวาร์ป"
    if Xaou_Show ~= nil then
        pcall(function() Xaou_Show(tostring(text), tostring(title)) end)
    end
    pcall(function() print("[XaouWarp] " .. tostring(text)) end)
end

local function XaouWarp_Try(label, fn)
    local ok, err = pcall(fn)
    if ok then return true, label end
    return false, tostring(err)
end

local function XaouWarp_ToNum(v)
    local n = tonumber(v)
    if n ~= nil and n > 0 then return n end
    return nil
end


-- v1.9 FIX:
-- บางฟังก์ชันด้านบน/ด้านล่างเรียก XaouWarp_GetMapSize ก่อน local function ถูกประกาศ
-- Lua จะมองเป็น global แล้วเป็น nil ได้ จึงประกาศ global สำรองไว้ตรงนี้
function XaouWarp_GetMapSize()
    local s = nil
    pcall(function() if Map ~= nil then s = XaouWarp_ToNum(Map.Size) end end)
    pcall(function() if s == nil and CS ~= nil and CS.Map ~= nil then s = XaouWarp_ToNum(CS.Map.Size) end end)
    return s or 0
end

local function XaouWarp_GetCurrentKey(target)
    local key = nil
    local obj = target or Xaou_CurrentNpcTarget or me
    pcall(function() if obj ~= nil and obj.Key ~= nil then key = XaouWarp_ToNum(obj.Key) end end)
    pcall(function() if key == nil and obj ~= nil and obj.key ~= nil then key = XaouWarp_ToNum(obj.key) end end)
    pcall(function() if key == nil and obj ~= nil and obj.Pos ~= nil then key = XaouWarp_ToNum(obj.Pos) end end)
    pcall(function() if key == nil and obj ~= nil and obj.Grid ~= nil then key = XaouWarp_ToNum(obj.Grid) end end)
    pcall(function() if key == nil and obj ~= nil and obj.Position ~= nil then key = XaouWarp_ToNum(obj.Position) end end)
    return key
end

local function XaouWarp_ReadField(obj, field)
    local value = nil
    pcall(function()
        if obj ~= nil then value = obj[field] end
    end)
    if value == nil then return nil end
    return tostring(value)
end

local function XaouWarp_GetThingKey(thing)
    local key = nil
    pcall(function() if thing ~= nil then key = XaouWarp_ToNum(thing.Key) end end)
    pcall(function() if key == nil and thing ~= nil then key = XaouWarp_ToNum(thing.key) end end)
    pcall(function() if key == nil and thing ~= nil then key = XaouWarp_ToNum(thing.Pos) end end)
    pcall(function() if key == nil and thing ~= nil then key = XaouWarp_ToNum(thing.Grid) end end)
    pcall(function() if key == nil and thing ~= nil then key = XaouWarp_ToNum(thing.Position) end end)
    return key
end

local function XaouWarp_KeyToXY(key)
    local size = XaouWarp_GetMapSize()
    key = XaouWarp_ToNum(key)
    if key == nil or size <= 0 then return nil, nil end
    local x = key % size
    local y = math.floor(key / size)
    return x, y
end

local function XaouWarp_FormatKeyLine(label, key)
    key = XaouWarp_ToNum(key)
    if key == nil then return tostring(label) .. " = nil" end
    local x, y = XaouWarp_KeyToXY(key)
    if x ~= nil then
        return tostring(label) .. " = " .. tostring(key) .. " (x=" .. tostring(x) .. ", y=" .. tostring(y) .. ")"
    end
    return tostring(label) .. " = " .. tostring(key)
end

-- v1.9: ใช้ global XaouWarp_GetMapSize ด้านบนแทน เพื่อกัน scope nil

local function XaouWarp_GetThingName(thing)
    local name = "NPC"
    pcall(function()
        name = thing.Name or thing.DisplayName or thing.defName or thing.ID or "NPC"
    end)
    return tostring(name)
end

local function XaouWarp_GetHomeKey()
    local key = nil

    pcall(function()
        if Map ~= nil and Map.BornCenter ~= nil then key = XaouWarp_ToNum(Map.BornCenter) end
    end)
    pcall(function()
        if key == nil and Map ~= nil and Map.Center ~= nil then key = XaouWarp_ToNum(Map.Center) end
    end)
    pcall(function()
        if key == nil and Map ~= nil and Map.GetRandomGrid ~= nil and me ~= nil and me.Key ~= nil then
            key = XaouWarp_ToNum(Map:GetRandomGrid(me.Key, Map.Size, 0, true))
        end
    end)
    pcall(function()
        if key == nil and me ~= nil and me.Key ~= nil then key = XaouWarp_ToNum(me.Key) end
    end)
    pcall(function()
        if key == nil then
            local s = XaouWarp_GetMapSize()
            if s > 0 then
                local x = math.floor(s / 2)
                local y = math.floor(s / 2)
                key = x + y * s
            end
        end
    end)

    return key
end

local function XaouWarp_FindEmptyKeyAround(key)
    key = XaouWarp_ToNum(key)
    if key == nil then return nil end

    local randomKey = nil
    pcall(function()
        if Map ~= nil and Map.GetRandomGrid ~= nil then
            randomKey = XaouWarp_ToNum(Map:GetRandomGrid(key, Map.Size, 0, true))
        end
    end)
    if randomKey ~= nil then return randomKey end

    local size = XaouWarp_GetMapSize()
    if size <= 0 then return key end

    local function isBlocked(k)
        local blocked = false
        pcall(function()
            if Map ~= nil and Map.Things ~= nil and Map.Things.GetThingAtGrid ~= nil and g_emThingType ~= nil then
                if Map.Things:GetThingAtGrid(k, g_emThingType.Npc) ~= nil then blocked = true end
            end
        end)
        return blocked
    end

    if not isBlocked(key) then return key end

    local baseX = key % size
    local baseY = math.floor(key / size)
    for r = 1, 16 do
        for dx = -r, r do
            for dy = -r, r do
                local x = baseX + dx
                local y = baseY + dy
                if x >= 0 and y >= 0 and x < size and y < size then
                    local k = x + y * size
                    if not isBlocked(k) then return k end
                end
            end
        end
    end

    return key
end

local function XaouWarp_LookAtKey(key)
    pcall(function()
        if CS ~= nil and CS.MapCamera ~= nil and CS.MapCamera.Instance ~= nil and CS.MapCamera.Instance.LookKey ~= nil then
            CS.MapCamera.Instance:LookKey(key)
        end
    end)
    pcall(function()
        if CameraMgr ~= nil and CameraMgr.LookAtGrid ~= nil then CameraMgr:LookAtGrid(key) end
    end)
end

local function XaouWarp_RedrawThing(thing)
    if thing == nil then return end
    pcall(function() if thing.OnClearDraw ~= nil then thing:OnClearDraw() end end)
    pcall(function() if thing.OnDraw ~= nil then thing:OnDraw(true) end end)
    pcall(function() if thing.Refresh ~= nil then thing:Refresh() end end)
    pcall(function() if thing.view ~= nil then thing.view.needUpdateMod = true end end)
end

local function XaouWarp_MoveThingToKey(thing, key)
    key = XaouWarp_ToNum(key)
    if thing == nil then return false, "ไม่มีเป้าหมาย NPC" end
    if key == nil then return false, "ไม่มีจุดวาร์ป" end

    local ok, used = false, ""

    -- สำคัญ: ม็อด PC ใช้ชื่อสะกดแบบนี้จริง ๆ: SetPostion
    if not ok and thing.SetPostion ~= nil then
        ok, used = XaouWarp_Try("SetPostion(key, true)", function() thing:SetPostion(key, true) end)
    end
    if not ok and thing.SetPostion ~= nil then
        ok, used = XaouWarp_Try("SetPostion(key, false, true, true)", function() thing:SetPostion(key, false, true, true) end)
    end
    if not ok and thing.SetPostionOnly ~= nil then
        ok, used = XaouWarp_Try("SetPostionOnly(key)", function() thing:SetPostionOnly(key) end)
    end

    -- ตัวเลือกสำรอง เผื่อบางเวอร์ชันใช้ชื่อมาตรฐาน
    if not ok and thing.MoveTo ~= nil then ok, used = XaouWarp_Try("MoveTo(key)", function() thing:MoveTo(key) end) end
    if not ok and thing.MoveToPos ~= nil then ok, used = XaouWarp_Try("MoveToPos(key)", function() thing:MoveToPos(key) end) end
    if not ok and thing.SetPos ~= nil then ok, used = XaouWarp_Try("SetPos(key)", function() thing:SetPos(key) end) end
    if not ok and thing.SetPosition ~= nil then ok, used = XaouWarp_Try("SetPosition(key)", function() thing:SetPosition(key) end) end
    if not ok and ThingMgr ~= nil and ThingMgr.MoveThing ~= nil then ok, used = XaouWarp_Try("ThingMgr:MoveThing", function() ThingMgr:MoveThing(thing, key) end) end
    if not ok and Map ~= nil and Map.Things ~= nil and Map.Things.MoveThing ~= nil then ok, used = XaouWarp_Try("Map.Things:MoveThing", function() Map.Things:MoveThing(thing, key) end) end

    -- fallback สุดท้าย ใช้เฉพาะถ้าไม่มีเมธอดข้างบนจริง ๆ
    if not ok then
        ok, used = XaouWarp_Try("thing.Key = key", function() thing.Key = key end)
    end

    if ok then
        XaouWarp_RedrawThing(thing)
        XaouWarp_LookAtKey(key)
        return true, used
    end

    return false, "ยังไม่พบคำสั่งย้ายตำแหน่งของเกมเวอร์ชันนี้"
end

function Xaou_WarpSystem.DebugHomeKey()
    local key = XaouWarp_GetHomeKey()
    local empty = XaouWarp_FindEmptyKeyAround(key)
    local size = XaouWarp_GetMapSize()
    XaouWarp_Msg("Map.Size = " .. tostring(size) .. "\nHomeKey = " .. tostring(key) .. "\nEmptyKey = " .. tostring(empty), "ระบบวาร์ป")
end

function Xaou_WarpSystem.ShowMap()
    local ok = false

    if not ok then
        ok = pcall(function()
            local map = Map.Size - 1
            for x = 0, map do
                for y = 0, map do
                    CS.MapRender.Instance.Fog:Unfog(x, y)
                end
            end
        end)
    end

    if not ok then
        ok = pcall(function()
            CS.GameMain.Instance.NoFog = true
            CS.MapRender.Instance.Fog.enabled = false
        end)
    end

    if not ok then
        ok = pcall(function() CS.MapRender.Instance.Fog.enabled = false end)
    end

    if ok then
        XaouWarp_Msg("เปิดหมอกแผนที่แล้ว", "ระบบแผนที่")
    else
        XaouWarp_Msg("เปิดหมอกแผนที่ไม่สำเร็จ", "ระบบแผนที่")
    end
end

function Xaou_WarpSystem.ClearDust()
    local count = 0
    local ok = false

    -- วิธีจากม็อด PC เดิม: ThingMgr:GetThingList(g_emThingType.CMD)
    if not ok then
        ok = pcall(function()
            local mapDust = nil
            if ThingMgr ~= nil and ThingMgr.GetThingList ~= nil and g_emThingType ~= nil then
                mapDust = ThingMgr:GetThingList(g_emThingType.CMD)
            end
            if mapDust ~= nil then
                for _, v in pairs(mapDust) do
                    pcall(function() if ThingMgr.RemoveThing ~= nil then ThingMgr:RemoveThing(v, true, true) end end)
                    pcall(function() if CS ~= nil and CS.MapRender ~= nil and CS.MapRender.Instance ~= nil and CS.MapRender.Instance.RemoveDust ~= nil then CS.MapRender.Instance:RemoveDust(v.Key) end end)
                    count = count + 1
                end
            end
        end)
    end

    -- วิธีสำรอง: เรียกเมธอดล้างฝุ่นจาก MapRender ถ้ามี
    if count <= 0 then
        pcall(function()
            local mr = CS.MapRender.Instance
            if mr.ClearDust ~= nil then mr:ClearDust(); count = count + 1; ok = true end
        end)
        pcall(function()
            local mr = CS.MapRender.Instance
            if mr.RefreshDust ~= nil then mr:RefreshDust(); ok = true end
        end)
    end

    if ok and count > 0 then
        XaouWarp_Msg("ล้างฝุ่น/สิ่งกีดขวางแล้ว จำนวนประมาณ " .. tostring(count), "ระบบแผนที่")
    elseif ok then
        XaouWarp_Msg("ลองล้างฝุ่นแล้ว แต่ไม่พบรายการฝุ่นในแมพนี้", "ระบบแผนที่")
    else
        XaouWarp_Msg("ล้างฝุ่นแผนที่ไม่สำเร็จ", "ระบบแผนที่")
    end
end

function Xaou_WarpSystem.UnlockAllPlaces()
    local ok = false
    local used = ""

    if not ok and PlacesMgr ~= nil and PlacesMgr.UnlockAll ~= nil then
        ok, used = XaouWarp_Try("PlacesMgr:UnlockAll", function() PlacesMgr:UnlockAll() end)
    end
    if not ok and PlacesMgr ~= nil and PlacesMgr.UnLockAll ~= nil then
        ok, used = XaouWarp_Try("PlacesMgr:UnLockAll", function() PlacesMgr:UnLockAll() end)
    end
    if not ok and World ~= nil and World.UnlockAllPlace ~= nil then
        ok, used = XaouWarp_Try("World:UnlockAllPlace", function() World:UnlockAllPlace() end)
    end
    if not ok and CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.PlacesMgr ~= nil and CS.XiaWorld.PlacesMgr.Instance ~= nil then
        local mgr = CS.XiaWorld.PlacesMgr.Instance
        if mgr.UnlockAll ~= nil then ok, used = XaouWarp_Try("CS.XiaWorld.PlacesMgr.Instance:UnlockAll", function() mgr:UnlockAll() end) end
        if not ok and mgr.UnLockAll ~= nil then ok, used = XaouWarp_Try("CS.XiaWorld.PlacesMgr.Instance:UnLockAll", function() mgr:UnLockAll() end) end
    end

    if ok then
        XaouWarp_Msg("ปลดล็อกสถานที่ทั้งหมดแล้ว\nใช้คำสั่ง: " .. tostring(used), "ระบบสถานที่")
    else
        XaouWarp_Msg("ปลดล็อกสถานที่ไม่สำเร็จ\nยังต้องหา API สถานที่ของมือถือเพิ่ม", "ระบบสถานที่")
    end
end

function Xaou_WarpSystem.UnlockPlace(placeKey)
    if placeKey == nil or tostring(placeKey) == "" then
        XaouWarp_Msg("ยังไม่ได้ใส่รหัสสถานที่", "ระบบสถานที่")
        return
    end

    local ok = false
    local key = tostring(placeKey)
    if not ok and PlacesMgr ~= nil and PlacesMgr.UnLockPlace ~= nil then ok = pcall(function() PlacesMgr:UnLockPlace(key) end) end
    if not ok and PlacesMgr ~= nil and PlacesMgr.UnlockPlace ~= nil then ok = pcall(function() PlacesMgr:UnlockPlace(key) end) end

    if ok then XaouWarp_Msg("ปลดล็อกสถานที่: " .. key, "ระบบสถานที่")
    else XaouWarp_Msg("ปลดล็อกสถานที่ไม่สำเร็จ: " .. key, "ระบบสถานที่") end
end



function Xaou_WarpSystem.DebugMapInfo()
    -- v1.8: ใช้ข้อมูลเบา ๆ เท่านั้น ลดโอกาสค้างบนมือถือ
    local size = XaouWarp_GetMapSize()
    local homeKey = nil
    local meKey = nil
    local centerKey = nil
    local bornKey = nil
    local mapName = "nil"

    pcall(function() if Map ~= nil then mapName = tostring(Map.Name or Map.DisplayName or Map.ID or Map.defName or "Map") end end)
    pcall(function() if Map ~= nil and Map.Center ~= nil then centerKey = XaouWarp_ToNum(Map.Center) end end)
    pcall(function() if Map ~= nil and Map.BornCenter ~= nil then bornKey = XaouWarp_ToNum(Map.BornCenter) end end)
    pcall(function() if me ~= nil then meKey = XaouWarp_GetThingKey(me) end end)

    -- ใช้ GetHomeKey ได้ แต่ครอบ pcall กันค้าง/กัน error
    pcall(function() homeKey = XaouWarp_GetHomeKey() end)

    local lines = {}
    table.insert(lines, "Debug v1.8")
    table.insert(lines, "MapName = " .. tostring(mapName))
    table.insert(lines, "Map.Size = " .. tostring(size))
    table.insert(lines, XaouWarp_FormatKeyLine("HomeKey", homeKey))
    table.insert(lines, XaouWarp_FormatKeyLine("MeKey", meKey))
    table.insert(lines, XaouWarp_FormatKeyLine("CenterKey", centerKey))
    table.insert(lines, XaouWarp_FormatKeyLine("BornKey", bornKey))

    XaouWarp_Msg(table.concat(lines, "\n"), "Debug Map / Key")
end

function Xaou_WarpSystem.DebugTargetInfo(target)
    -- v1.8: อ่านเฉพาะค่าหลัก ไม่ไล่ object ลึก ลดค้าง
    local npc = target or Xaou_CurrentNpcTarget or me
    if npc == nil then
        XaouWarp_Msg("ยังไม่มี NPC เป้าหมาย\nลองเลือก NPC ก่อน แล้วกดใหม่อีกครั้ง", "Debug NPC / Key")
        return
    end

    local name = "NPC"
    local key = nil
    local seed = nil
    local kind = nil

    pcall(function() name = XaouWarp_GetThingName(npc) end)
    pcall(function() key = XaouWarp_GetThingKey(npc) end)
    pcall(function() seed = npc.RandomSeed or npc.randomSeed or npc.Seed or npc.seed end)
    pcall(function() kind = npc.Kind or npc.kind or npc.ThingType or npc.Type end)

    local lines = {}
    table.insert(lines, "Debug v1.8")
    table.insert(lines, "Name = " .. tostring(name))
    table.insert(lines, XaouWarp_FormatKeyLine("NpcKey", key))
    table.insert(lines, "Seed = " .. tostring(seed))
    table.insert(lines, "Type = " .. tostring(kind))

    XaouWarp_Msg(table.concat(lines, "\n"), "Debug NPC / Key")
end

function Xaou_WarpSystem.DebugAroundHomeKeys()
    -- v1.8: แสดงเฉพาะ 3x3 รอบ HomeKey ไม่หา empty เพิ่ม เพื่อกันค้าง
    local homeKey = nil
    pcall(function() homeKey = XaouWarp_GetHomeKey() end)
    local size = XaouWarp_GetMapSize()
    if homeKey == nil or size <= 0 then
        XaouWarp_Msg("ยังหา HomeKey หรือ Map.Size ไม่เจอ", "Debug Key รอบสำนัก")
        return
    end

    local hx = homeKey % size
    local hy = math.floor(homeKey / size)
    local lines = {}
    table.insert(lines, "Debug v1.8")
    table.insert(lines, "HomeKey = " .. tostring(homeKey) .. " (x=" .. tostring(hx) .. ", y=" .. tostring(hy) .. ")")
    table.insert(lines, "รอบสำนัก 3x3:")

    for dy = -1, 1 do
        local row = {}
        for dx = -1, 1 do
            local x = hx + dx
            local y = hy + dy
            if x >= 0 and y >= 0 and x < size and y < size then
                local k = x + y * size
                table.insert(row, tostring(k))
            else
                table.insert(row, "nil")
            end
        end
        table.insert(lines, table.concat(row, " | "))
    end

    XaouWarp_Msg(table.concat(lines, "\n"), "Debug Key รอบสำนัก")
end


function Xaou_WarpSystem.FocusTarget(target)
    local npc = target or Xaou_CurrentNpcTarget or me
    if npc == nil then
        XaouWarp_Msg("ยังไม่มี NPC เป้าหมาย\nลองเลือก NPC ก่อน แล้วกดใหม่อีกครั้ง", "ระบบวาร์ป")
        return
    end

    local key = nil
    pcall(function() key = XaouWarp_GetThingKey(npc) end)
    if key == nil then
        XaouWarp_Msg("อ่าน Key ของ NPC ไม่ได้\nให้กด ดูข้อมูล NPC / Key เพื่อตรวจสอบก่อน", "ระบบวาร์ป")
        return
    end

    XaouWarp_LookAtKey(key)
    XaouWarp_Msg("เลื่อนไปดูตำแหน่ง NPC แล้ว\n" .. XaouWarp_GetThingName(npc) .. "\n" .. XaouWarp_FormatKeyLine("NpcKey", key), "ระบบวาร์ป")
end

function Xaou_WarpSystem.DebugWarpSummary(target)
    local npc = target or Xaou_CurrentNpcTarget or me
    local size = XaouWarp_GetMapSize()
    local homeKey = nil
    local bornKey = nil
    local targetKey = nil
    local targetName = "nil"

    pcall(function() homeKey = XaouWarp_GetHomeKey() end)
    pcall(function() if Map ~= nil and Map.BornCenter ~= nil then bornKey = XaouWarp_ToNum(Map.BornCenter) end end)
    pcall(function()
        if npc ~= nil then
            targetName = XaouWarp_GetThingName(npc)
            targetKey = XaouWarp_GetThingKey(npc)
        end
    end)

    local lines = {}
    table.insert(lines, "Xaou_009 Warp v2.0")
    table.insert(lines, "Map.Size = " .. tostring(size))
    table.insert(lines, XaouWarp_FormatKeyLine("HomeKey", homeKey))
    table.insert(lines, XaouWarp_FormatKeyLine("BornKey", bornKey))
    table.insert(lines, "Target = " .. tostring(targetName))
    table.insert(lines, XaouWarp_FormatKeyLine("TargetKey", targetKey))
    table.insert(lines, "")
    table.insert(lines, "ใช้ได้แล้ว:")
    table.insert(lines, "- เปิดหมอกแผนที่")
    table.insert(lines, "- วาร์ป NPC กลับสำนัก")
    table.insert(lines, "- ดู Map/NPC Key")
    table.insert(lines, "- โฟกัสตำแหน่ง NPC")

    XaouWarp_Msg(table.concat(lines, "\n"), "สรุประบบวาร์ป")
end

function Xaou_WarpSystem.WarpNpcHome(npc)
    if npc == nil then
        XaouWarp_Msg("กรุณากดเลือก NPC ก่อนใช้คำสั่งนี้", "ระบบวาร์ป")
        return
    end

    local homeKey = XaouWarp_GetHomeKey()
    homeKey = XaouWarp_FindEmptyKeyAround(homeKey)

    if homeKey == nil then
        XaouWarp_Msg("หาจุดเกิด/จุดกลางสำนักไม่เจอ", "ระบบวาร์ป")
        return
    end

    local ok, used = XaouWarp_MoveThingToKey(npc, homeKey)
    if ok then
        XaouWarp_Msg("วาร์ป " .. XaouWarp_GetThingName(npc) .. " กลับสำนักแล้ว\nใช้คำสั่ง: " .. tostring(used), "ระบบวาร์ป")
    else
        XaouWarp_Msg(tostring(used), "ระบบวาร์ป")
    end
end

function Xaou_WarpSystem.WarpSelectedNpcHome(target)
    Xaou_WarpSystem.WarpNpcHome(target or Xaou_CurrentNpcTarget or me)
end

-- ฟังก์ชันเรียกจาก Story XML / ระบบเก่า
function Xaou_Warp_ShowMap() Xaou_WarpSystem.ShowMap() end
function Xaou_Warp_ClearDust() Xaou_WarpSystem.ClearDust() end
function Xaou_Warp_UnlockAllPlaces() Xaou_WarpSystem.UnlockAllPlaces() end
function Xaou_Warp_SelectedNpcHome(me) Xaou_WarpSystem.WarpSelectedNpcHome(me) end
function Xaou_Warp_FocusTarget(me) Xaou_WarpSystem.FocusTarget(me) end
function Xaou_Warp_DebugSummary(me) Xaou_WarpSystem.DebugWarpSummary(me) end


-- ============================================================
-- Xaou_009 Map Database v2.1
-- ดึงข้อมูลจาก Settings/World/Places และ Schools
-- หมายเหตุ: X/Y เป็นพิกัดแผนที่โลก ไม่ใช่ Map Grid Key 128x128
-- ============================================================
Xaou_WarpSystem.PlaceData = {
    {id="Place_DanXia", name="丹霞山", x="1080", y="265", school="1", schoolName="丹霞洞天", fight="School_DanXiaDongTian", biome="", weather="", power="16"},
    {id="Place_KunLun", name="昆仑山", x="315", y="378", school="2", schoolName="昆仑宫", fight="School_KunLun", biome="TestFightMapBiomeIce", weather="LightSnow_Fov", power="16"},
    {id="Place_TianJi", name="天极峰", x="500", y="84", school="3", schoolName="极天宫", fight="School_JiTianGong", biome="", weather="", power="16"},
    {id="Place_JiuHua", name="九华山", x="1435", y="513", school="4", schoolName="紫霄宗", fight="School_ZiXiaoZong", biome="", weather="", power="16"},
    {id="Place_LongHu", name="龙虎山", x="726", y="455", school="5", schoolName="玄一道", fight="School_ZhengYiDao", biome="", weather="", power="16"},
    {id="Place_Shu", name="蜀山", x="1002", y="890", school="6", schoolName="青莲剑宗", fight="School_QingLianJianZong", biome="", weather="", power="16"},
    {id="Place_WuLian", name="五莲山", x="1002", y="640", school="7", schoolName="栖霞洞天", fight="School_QiXiaDongTian", biome="", weather="", power="16"},
    {id="Place_BaiMan", name="百蛮山", x="170", y="593", school="8", schoolName="百蛮山", fight="School_BaiManShan", biome="Biome_BaiManShan", weather="", power="16"},
    {id="Place_XianKong", name="陷空山", x="118", y="447", school="9", schoolName="七仟坞", fight="School_QiQianWu", biome="Biome_QiQianWu", weather="", power="16"},
    {id="Place_Hei", name="黑山", x="749", y="133", school="10", schoolName="七杀魔宫", fight="School_QiSha", biome="Biome_QiSha", weather="", power="16"},
    {id="Place_HeHuan", name="合欢岛", x="1708", y="411", school="11", schoolName="合欢派", fight="School_HeHuanPai", biome="", weather="", power="16"},
    {id="Place_Desert", name="大漠", x="389", y="480", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_SouthForest", name="南荒", x="100", y="1006", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_Snowfield", name="大雪原", x="859", y="37", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_FertileField", name="江岸沃野", x="1707", y="195", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_CentralPlains", name="中原", x="826", y="322", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_SouthMount", name="岭南", x="1325", y="768", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_HeYinCity", name="河阴城", x="1648", y="194", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_HuCity", name="观海城", x="1247", y="283", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_PanSheCity", name="盘蛇寨", x="208", y="901", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_ShanCity", name="丰城", x="1129", y="489", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_DaLiangCity", name="大凉城", x="583", y="400", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_DanXia1", name="上清洞", x="980", y="263", school="", schoolName="", fight="Place_DanXia1_Cave_ShangQing", biome="", weather="DimCave", power="11"},
    {id="Place_DanXia2", name="丹霞绝壁", x="1093", y="212", school="", schoolName="", fight="Place_DanXia2_Cliff_DanXia", biome="", weather="", power="10"},
    {id="Place_DanXia3", name="五龙池", x="1029", y="200", school="", schoolName="", fight="Place_DanXia3_Pond_WuLong", biome="", weather="", power="17"},
    {id="Place_KunLun1", name="登仙台", x="374", y="335", school="", schoolName="", fight="Place_KunLun1_Platform_DengXian", biome="", weather="DimCave", power="15"},
    {id="Place_KunLun2", name="龙脉洞窟", x="303", y="326", school="", schoolName="", fight="Place_KunLun2_Cave_LongMai", biome="", weather="DimCave", power="19"},
    {id="Place_KunLun2_1", name="奇特空洞", x="270", y="336", school="", schoolName="", fight="Place_KunLun2_1_Cave_Strange", biome="", weather="DimCave", power="0"},
    {id="Place_TianJi1", name="飞云涧", x="481", y="26", school="", schoolName="", fight="Place_TianJi1_Rift_FeiYun", biome="", weather="DimCave", power="20"},
    {id="Place_TianJi2", name="绝天关", x="553", y="57", school="", schoolName="", fight="Place_TianJi2_Rift_JueTian", biome="", weather="DimCave", power="12"},
    {id="Place_JiuHua1", name="九华村", x="1424", y="555", school="", schoolName="", fight="Place_JiuHua1_Villa_JiuHua", biome="", weather="", power="4"},
    {id="Place_JiuHua2", name="潜龙渊", x="1375", y="461", school="", schoolName="", fight="Place_JiuHua2_Abyss_QianLong", biome="", weather="", power="15"},
    {id="Place_JiuHua3", name="凤栖崖", x="1489", y="481", school="", schoolName="", fight="Place_JiuHua3_Cliff_FengQi", biome="Hot", weather="", power="15"},
    {id="Place_LongHu1", name="飞流瀑", x="771", y="421", school="", schoolName="", fight="Place_LongHu1_Fall_FeiLiu", biome="", weather="", power="15"},
    {id="Place_LongHu2", name="神木林", x="831", y="502", school="", schoolName="", fight="Place_LongHu2_Forest_ShenMu", biome="", weather="", power="12"},
    {id="Place_Shu1", name="凝碧崖", x="946", y="845", school="", schoolName="", fight="Place_Shu1_Cliff_NingBi", biome="", weather="DimCave", power="17"},
    {id="Place_Shu2", name="飞雷洞", x="1089", y="876", school="", schoolName="", fight="Place_Shu2_Cave_FeiLei", biome="", weather="DimCave", power="8"},
    {id="Place_Shu3", name="餐霞洞", x="1040", y="805", school="", schoolName="", fight="Place_Shu3_Cave_CanXia", biome="", weather="DimCave", power="9"},
    {id="Place_Shu4", name="玉泉洞", x="1056", y="905", school="", schoolName="", fight="Place_Shu4_Cave_YuQuan", biome="", weather="DimCave", power="16"},
    {id="Place_Shu5", name="剑冢", x="940", y="909", school="", schoolName="", fight="Place_Shu5_Cave_Cemetery", biome="", weather="DimCave", power="10"},
    {id="Place_WuLian1", name="天池", x="1011", y="692", school="", schoolName="", fight="Place_WuLian1_Pond_TianChi", biome="Cold", weather="", power="17"},
    {id="Place_WuLian2", name="木白雨林", x="948", y="558", school="", schoolName="", fight="Place_WuLian2_Forest_BaiMu", biome="", weather="ForestRain", power="12"},
    {id="Place_BaiMan1", name="千尸洞", x="118", y="588", school="", schoolName="", fight="Place_BaiMan1_Cave_QianShi", biome="", weather="DimCave", power="15"},
    {id="Place_BaiMan2", name="万蛇坑", x="206", y="615", school="", schoolName="", fight="Place_BaiMan2_Abyss_WanShe", biome="", weather="DimCave", power="16"},
    {id="Place_BaiMan3", name="百兽窟", x="166", y="552", school="", schoolName="", fight="Place_BaiMan3_Cave_Beast", biome="", weather="DimCave", power="17"},
    {id="Place_XianKong1", name="无底洞", x="69", y="430", school="", schoolName="", fight="Place_XianKong1_Cave_Endless", biome="", weather="DimCave", power="11"},
    {id="Place_Hei4", name="千棘林", x="785", y="189", school="", schoolName="", fight="Place_Hei4_Forest_QianJi", biome="", weather="", power="13"},
    {id="Place_HeHuan1", name="离恨海", x="1587", y="363", school="", schoolName="", fight="Place_HeHuan1_Island_LiHen", biome="", weather="", power="17"},
    {id="Place_HeHuan2", name="毒龙潭", x="1754", y="470", school="", schoolName="", fight="Place_HeHuan2_Pond_DuLong", biome="", weather="", power="17"},
    {id="Place_Desert1", name="万妖殿", x="480", y="577", school="12", schoolName="万妖殿", fight="School_WanYao", biome="sandFightMapBiome", weather="", power="16"},
    {id="Place_Desert2", name="幻沙原", x="485", y="481", school="", schoolName="", fight="Place_Desert2_Plain_HuanSha", biome="Hot", weather="DustPlace", power="12"},
    {id="Place_Desert3", name="火穴", x="292", y="507", school="", schoolName="", fight="Place_Desert3_Cave_Ember", biome="Hot", weather="DimCave", power="20"},
    {id="Place_Desert4", name="鸣沙村", x="528", y="432", school="", schoolName="", fight="Place_Desert4_Villa_MingSha", biome="Hot", weather="DustPlace", power="5"},
    {id="Place_SouthForest1", name="万古桃花瘴", x="67", y="1041", school="", schoolName="", fight="Place_SouthForest1_Forest_ElderPeach", biome="", weather="ForestRain", power="17"},
    {id="Place_SouthForest2", name="邪帝陵", x="262", y="1003", school="", schoolName="", fight="Place_SouthForest2_Grave_XieDi", biome="", weather="DimCave", power="12"},
    {id="Place_SouthForest3", name="虫谷", x="37", y="878", school="", schoolName="", fight="Place_SouthForest3_Valley_Pest", biome="", weather="", power="20"},
    {id="Place_Snowfield1", name="天螺峪", x="981", y="73", school="", schoolName="", fight="Place_Snowfield1_Valley_TianLuo", biome="Cold", weather="EverSnow", power="11"},
    {id="Place_Snowfield2", name="玉晶潭", x="784", y="40", school="", schoolName="", fight="Place_Snowfield2_Pond_YuJing", biome="Cold", weather="DimCave", power="21"},
    {id="Place_Snowfield3", name="雪风原", x="928", y="74", school="", schoolName="", fight="Place_Snowfield3_Plain_XueFeng", biome="Cold", weather="EverSnow", power="11"},
    {id="Place_FertileField1", name="寒山镇", x="1627", y="123", school="", schoolName="", fight="Place_FertileField1_Villa_HanShan", biome="Cold", weather="EverSnow", power="5"},
    {id="Place_FertileField2", name="落霞镇", x="1558", y="135", school="", schoolName="", fight="Place_FertileField2_Villa_LuoXia", biome="", weather="", power="4"},
    {id="Place_FertileField3", name="稻香村", x="1753", y="161", school="", schoolName="", fight="Place_FertileField3_Villa_DaoXiang", biome="", weather="", power="5"},
    {id="Place_FertileField4", name="桂山", x="1717", y="262", school="", schoolName="", fight="Place_FertileField4_Mount_Gui", biome="", weather="", power="8"},
    {id="Place_FertileField5", name="卢山", x="1826", y="203", school="", schoolName="", fight="Place_FertileField5_Mount_Lu", biome="", weather="", power="17"},
    {id="Place_CentralPlains1", name="云台山", x="702", y="256", school="", schoolName="", fight="Place_CentralPlains1_Mount_Yun", biome="", weather="", power="8"},
    {id="Place_CentralPlains2", name="炼丹峰", x="923", y="396", school="", schoolName="", fight="Place_CentralPlains2_Peak_LianDan", biome="", weather="", power="17"},
    {id="Place_CentralPlains3", name="平顶山", x="624", y="301", school="", schoolName="", fight="Place_CentralPlains3_Mount_PingDing", biome="", weather="", power="10"},
    {id="Place_CentralPlains4", name="五华村", x="922", y="332", school="", schoolName="", fight="Place_CentralPlains4_Villa_WuHua", biome="", weather="", power="4"},
    {id="Place_CentralPlains5", name="芦墟村", x="752", y="334", school="", schoolName="", fight="Place_CentralPlains5_Villa_LuXu", biome="", weather="", power="4"},
    {id="Place_BirthPlace11", name="南屏村", x="1218", y="661", school="", schoolName="", fight="Place_BirthPlace11_Villa_NanPing", biome="", weather="", power="3"},
    {id="Place_BirthPlace12", name="月轮山", x="1404", y="768", school="", schoolName="", fight="Place_BirthPlace12_Mount_YueLun", biome="", weather="", power="3"},
    {id="Place_BirthPlace13", name="小凉山", x="1325", y="673", school="", schoolName="", fight="Place_BirthPlace13_Mount_Liang", biome="", weather="", power="3"},
    {id="Place_BirthPlace14", name="铜陵山", x="1314", y="865", school="", schoolName="", fight="Place_BirthPlace14_Mount_TongLing", biome="", weather="", power="3"},
    {id="Place_BirthPlace15", name="太一遗迹", x="1405", y="798", school="", schoolName="", fight="Place_BirthPlace15_Remains_TaiYi", biome="", weather="", power="0"},
    {id="Place_BirthPlace16", name="黑沙滩", x="1560", y="745", school="", schoolName="", fight="", biome="", weather="", power="0"},
    {id="Place_QingLianShan", name="青莲山", x="883", y="981", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_ChiLianYuan", name="琼楼", x="527", y="744", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_LongTai", name="龙台", x="84", y="93", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_XuanKongDong", name="玄空洞", x="1643", y="1001", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_GuZhanChang", name="仙魔战场", x="302", y="752", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_YiJieLieFeng", name="异界裂缝", x="1314", y="159", school="", schoolName="", fight="", biome="", weather="", power=""},
    {id="_OnTheWay", name="路上", x="", y="", school="-1", schoolName="", fight="", biome="", weather="", power=""},
    {id="_GodOnTheWay", name="神在路上", x="", y="", school="-1", schoolName="", fight="", biome="", weather="", power=""},
    {id="_InMap", name="场景", x="", y="", school="-1", schoolName="", fight="", biome="", weather="", power=""},
    {id="_StayFree", name="四处历练，行踪不定", x="", y="", school="-1", schoolName="", fight="", biome="", weather="", power=""},
    {id="_InNpcStory", name="NpcStory", x="", y="", school="-1", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_OldSchool", name="老门派", x="1175", y="721", school="1000000", schoolName="", fight="", biome="", weather="", power=""},
    {id="_TestMap", name="路上", x="", y="", school="12", schoolName="万妖殿", fight="TestMap", biome="TestFightMapBiome", weather="MouldRains", power="16"},
    {id="_LOSTPALCE", name="失落之地(模组丢失)", x="", y="", school="-1", schoolName="", fight="", biome="", weather="", power=""},
    {id="Place_BigBamboo", name="大竹林", x="1197", y="531", school="", schoolName="", fight="Place_BigBamboo", biome="", weather="", power="0"},
    {id="Place_WuDang_Taizipo", name="复真观", x="1693", y="680", school="", schoolName="", fight="Place_WuDang_Taizipo", biome="WudangMapBiome", weather="", power="11"},
    {id="Place_WuDang_ZiXiaoGong", name="紫霄宫", x="1784", y="718", school="", schoolName="", fight="Place_WuDang_ZiXiaoGong", biome="WudangMapBiome", weather="", power="11"},
    {id="Place_WuDang_NanYanGong", name="南岩宫", x="1780", y="665", school="", schoolName="", fight="Place_WuDang_NanYanGong", biome="WudangMapBiome_Cold", weather="LightSnow_Fov", power="11"},
    {id="Place_WuDang_JinDing", name="金顶", x="1736", y="694", school="13", schoolName="武当派", fight="School_WuDang", biome="WudangMapBiome_Cold", weather="LightSnow_Fov", power="16"},
}

local function XaouWarp_PlaceLine(i, p)
    local s = tostring(i) .. ". " .. tostring(p.name or p.id)
    if p.schoolName ~= nil and tostring(p.schoolName) ~= "" then
        s = s .. " [" .. tostring(p.schoolName) .. "]"
    end
    s = s .. "\nID: " .. tostring(p.id)
    if p.x ~= nil and tostring(p.x) ~= "" then
        s = s .. "  X=" .. tostring(p.x) .. " Y=" .. tostring(p.y)
    end
    if p.fight ~= nil and tostring(p.fight) ~= "" then
        s = s .. "\nMap: " .. tostring(p.fight)
    end
    return s
end


local function XaouWarp_Lower(v)
    return string.lower(tostring(v or ""))
end

local function XaouWarp_PlaceMatch(p, kw)
    kw = XaouWarp_Lower(kw)
    if kw == "" then return true end
    local fields = {p.id, p.name, p.schoolName, p.fight, p.biome, p.weather, p.school}
    for _, v in ipairs(fields) do
        if string.find(XaouWarp_Lower(v), kw, 1, true) ~= nil then return true end
    end
    return false
end

function Xaou_WarpSystem.SearchPlaces(keyword)
    keyword = tostring(keyword or "")
    local list = Xaou_WarpSystem.PlaceData or {}
    local out = {"ค้นสถานที่จาก Settings", "คำค้น: " .. (keyword ~= "" and keyword or "(ว่าง = แสดงตัวอย่าง)")}
    local count = 0
    for i, p in ipairs(list) do
        if XaouWarp_PlaceMatch(p, keyword) then
            count = count + 1
            if count <= 8 then
                table.insert(out, XaouWarp_PlaceLine(i, p))
            end
        end
    end
    table.insert(out, 2, "พบทั้งหมด: " .. tostring(count))
    if count == 0 then
        table.insert(out, "ลองพิมพ์ชื่อจีน / Place_ / School_ / KunLun / WuDang ในช่องค้นหา")
    elseif count > 8 then
        table.insert(out, "\nแสดง 8 รายการแรกเท่านั้น ถ้าจะดูต่อให้ค้นคำให้แคบลง")
    end
    XaouWarp_Msg(table.concat(out, "\n\n"), "ค้น Place")
end

local function XaouWarp_Distance2(ax, ay, bx, by)
    ax, ay, bx, by = tonumber(ax), tonumber(ay), tonumber(bx), tonumber(by)
    if ax == nil or ay == nil or bx == nil or by == nil then return nil end
    local dx, dy = ax - bx, ay - by
    return dx * dx + dy * dy
end

function Xaou_WarpSystem.DebugNearestPlacesByWorldXY(x, y)
    x = tonumber(x); y = tonumber(y)
    if x == nil or y == nil then
        XaouWarp_Msg("ยังไม่มี X/Y สำหรับค้นสถานที่ใกล้เคียง", "Map Database")
        return
    end
    local tmp = {}
    for i, p in ipairs(Xaou_WarpSystem.PlaceData or {}) do
        local d = XaouWarp_Distance2(x, y, p.x, p.y)
        if d ~= nil then table.insert(tmp, {idx=i, p=p, d=d}) end
    end
    table.sort(tmp, function(a,b) return a.d < b.d end)
    local out = {"สถานที่ใกล้ X/Y", "X=" .. tostring(x) .. " Y=" .. tostring(y), "หมายเหตุ: เป็นพิกัดโลก ไม่ใช่ GridKey"}
    for n = 1, math.min(8, #tmp) do
        local item = tmp[n]
        table.insert(out, XaouWarp_PlaceLine(item.idx, item.p) .. "\nDistance2=" .. tostring(math.floor(item.d)))
    end
    XaouWarp_Msg(table.concat(out, "\n\n"), "ใกล้สถานที่")
end

function Xaou_WarpSystem.DebugCoordinateBridge(target)
    target = target or Xaou_CurrentNpcTarget or me
    local mapSize = XaouWarp_GetMapSize()
    local homeKey = XaouWarp_GetHomeKey()
    local hx, hy = XaouWarp_KeyToXY(homeKey)
    local tkey = XaouWarp_GetThingKey(target)
    local tx, ty = XaouWarp_KeyToXY(tkey)
    local out = {"วิเคราะห์พิกัด World X/Y ↔ GridKey", "Map.Size=" .. tostring(mapSize)}
    table.insert(out, XaouWarp_FormatKeyLine("HomeKey", homeKey))
    table.insert(out, XaouWarp_FormatKeyLine("TargetKey", tkey))
    table.insert(out, "")
    table.insert(out, "สถานะตอนนี้:")
    table.insert(out, "- PlaceData มี X/Y แบบพิกัดโลก")
    table.insert(out, "- SetPostion ใช้ GridKey เช่น HomeKey/NpcKey")
    table.insert(out, "- ยังไม่พบสูตรแปลง X/Y -> GridKey โดยตรง")
    table.insert(out, "")
    table.insert(out, "ตัวอย่างที่รู้จริง:")
    if hx ~= nil then table.insert(out, "Home Grid = x" .. tostring(hx) .. ", y" .. tostring(hy)) end
    if tx ~= nil then table.insert(out, "Target Grid = x" .. tostring(tx) .. ", y" .. tostring(ty)) end
    table.insert(out, "")
    table.insert(out, "ขั้นต่อไป: ต้องหา Object/Region ที่มีทั้ง PlaceID และ GridKey ในเกม")
    XaouWarp_Msg(table.concat(out, "\n"), "พิกัดวาร์ป")
end

function Xaou_WarpSystem.DebugPlaceList(page)
    page = tonumber(page or Xaou_WarpSystem.PlacePage or 1) or 1
    if page < 1 then page = 1 end
    local list = Xaou_WarpSystem.PlaceData or {}
    local per = 8
    local maxPage = math.max(1, math.ceil(#list / per))
    if page > maxPage then page = 1 end
    Xaou_WarpSystem.PlacePage = page
    local startIndex = (page - 1) * per + 1
    local out = {"รายชื่อสถานที่จาก Settings", "หน้า " .. tostring(page) .. "/" .. tostring(maxPage) .. " | จำนวน " .. tostring(#list)}
    for i = startIndex, math.min(#list, startIndex + per - 1) do
        table.insert(out, XaouWarp_PlaceLine(i, list[i]))
    end
    XaouWarp_Msg(table.concat(out, "\n\n"), "Map Database")
end

function Xaou_WarpSystem.DebugNextPlacePage()
    local p = tonumber(Xaou_WarpSystem.PlacePage or 1) or 1
    Xaou_WarpSystem.DebugPlaceList(p + 1)
end

function Xaou_WarpSystem.DebugSchoolPlaces()
    local list = Xaou_WarpSystem.PlaceData or {}
    local out = {"สถานที่สำนัก / School Places"}
    local count = 0
    for i, p in ipairs(list) do
        if p.school ~= nil and tostring(p.school) ~= "" and tostring(p.school) ~= "-1" then
            count = count + 1
            table.insert(out, XaouWarp_PlaceLine(i, p))
            if count >= 10 then break end
        end
    end
    table.insert(out, "\nหมายเหตุ: X/Y เป็นพิกัดโลก ยังไม่ใช่ Grid Key สำหรับ SetPostion")
    XaouWarp_Msg(table.concat(out, "\n\n"), "สำนัก / Places")
end

function Xaou_WarpSystem.DebugPlaceSummary()
    local list = Xaou_WarpSystem.PlaceData or {}
    local schools = 0
    local fight = 0
    for _, p in ipairs(list) do
        if p.school ~= nil and tostring(p.school) ~= "" and tostring(p.school) ~= "-1" then schools = schools + 1 end
        if p.fight ~= nil and tostring(p.fight) ~= "" then fight = fight + 1 end
    end
    XaouWarp_Msg("Map Database v2.1\nPlaces = " .. tostring(#list) .. "\nSchool Places = " .. tostring(schools) .. "\nFightMap entries = " .. tostring(fight) .. "\n\nข้อมูลนี้ใช้เป็นรายชื่อสถานที่/ID ก่อน ยังไม่ใช่ Grid Key วาร์ปโดยตรง", "Map Database")
end


-- ============================================================
-- v2.3 Runtime PlacesMgr Debug
-- ทดสอบ Manager ของเกมจริงที่เจอจากม็อด PC:
-- PlacesMgr.Places / PlacesMgr:GetPlaceDef(localKey) / PlacesMgr:UnLockPlace / PlacesMgr:UnlockAll
-- ============================================================
local function XaouWarp_GetPlacesMgr()
    local mgr = nil
    pcall(function() if PlacesMgr ~= nil then mgr = PlacesMgr end end)
    pcall(function()
        if mgr == nil and CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.PlacesMgr ~= nil then
            mgr = CS.XiaWorld.PlacesMgr
        end
    end)
    pcall(function()
        if mgr == nil and CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.PlacesMgr ~= nil and CS.XiaWorld.PlacesMgr.Instance ~= nil then
            mgr = CS.XiaWorld.PlacesMgr.Instance
        end
    end)
    return mgr
end

local function XaouWarp_GetPlaceDefSafe(mgr, key)
    local def = nil
    pcall(function()
        if mgr ~= nil and mgr.GetPlaceDef ~= nil then
            def = mgr:GetPlaceDef(key)
        end
    end)
    return def
end

local function XaouWarp_GetDisplayNameSafe(obj)
    local v = nil
    pcall(function() if obj ~= nil and obj.DisplayName ~= nil then v = obj.DisplayName end end)
    pcall(function() if v == nil and obj ~= nil and obj.Name ~= nil then v = obj.Name end end)
    pcall(function() if v == nil and obj ~= nil and obj.name ~= nil then v = obj.name end end)
    pcall(function() if v == nil and obj ~= nil and obj.def ~= nil and obj.def.DisplayName ~= nil then v = obj.def.DisplayName end end)
    if v == nil then return nil end
    return tostring(v)
end

local function XaouWarp_ReadAnyField(obj, names)
    if obj == nil then return nil end
    for _, field in ipairs(names or {}) do
        local v = nil
        pcall(function() v = obj[field] end)
        if v ~= nil then return v, field end
    end
    return nil, nil
end

local function XaouWarp_HasMethod(obj, name)
    local ok = false
    pcall(function() ok = (obj ~= nil and obj[name] ~= nil) end)
    return ok
end

local function XaouWarp_AddMethodLine(lines, obj, name)
    table.insert(lines, tostring(name) .. " = " .. tostring(XaouWarp_HasMethod(obj, name)))
end

local function XaouWarp_ScanMethods(obj, names)
    local found = {}
    for _, name in ipairs(names or {}) do
        if XaouWarp_HasMethod(obj, name) then table.insert(found, name) end
    end
    if #found == 0 then return "ไม่พบ candidate method" end
    return table.concat(found, ", ")
end

local function XaouWarp_CountPairs(t, maxCount)
    local n = 0
    if t == nil then return 0 end
    maxCount = maxCount or 9999
    pcall(function()
        for _, _ in pairs(t) do
            n = n + 1
            if n >= maxCount then break end
        end
    end)
    return n
end

function Xaou_WarpSystem.DebugPlacesMgr()
    local mgr = XaouWarp_GetPlacesMgr()
    local lines = {}
    table.insert(lines, "PlacesMgr Runtime v2.4")
    table.insert(lines, "PlacesMgr = " .. tostring(mgr ~= nil))

    if mgr ~= nil then
        local hasPlaces = false
        local count = 0
        pcall(function()
            hasPlaces = (mgr.Places ~= nil)
            count = XaouWarp_CountPairs(mgr.Places, 9999)
        end)
        table.insert(lines, "Places = " .. tostring(hasPlaces))
        table.insert(lines, "Places Count = " .. tostring(count))
        table.insert(lines, "GetPlaceDef = " .. tostring(mgr.GetPlaceDef ~= nil))
        table.insert(lines, "UnLockPlace = " .. tostring(mgr.UnLockPlace ~= nil))
        table.insert(lines, "UnLockAll = " .. tostring(mgr.UnLockAll ~= nil))

        table.insert(lines, "")
        table.insert(lines, "Candidate API ที่เจอบน PlacesMgr:")
        local candidates = {
            "EnterPlace", "Enter", "VisitPlace", "Visit", "GoToPlace", "GotoPlace", "Goto",
            "Travel", "StartTravel", "OpenPlace", "Open", "ShowPlace", "Show",
            "SelectPlace", "SetPlace", "SetCurPlace", "GetPlace", "GetPlaceData",
            "GetRegion", "GetPlaceRegion", "GetMap", "GetMapName",
            "AddPlace", "RemovePlace", "SetPlaceState", "SetPlaceOpen",
            "UnLockPlace", "UnLockAll", "GetPlaceDef"
        }
        table.insert(lines, XaouWarp_ScanMethods(mgr, candidates))

        local sampleKey = nil
        pcall(function()
            if mgr.Places ~= nil then
                for k, _ in pairs(mgr.Places) do sampleKey = k; break end
            end
        end)
        table.insert(lines, "")
        table.insert(lines, "SampleKey = " .. tostring(sampleKey))
        if sampleKey ~= nil then
            local def = XaouWarp_GetPlaceDefSafe(mgr, sampleKey)
            local runtimePlace = nil
            pcall(function() runtimePlace = mgr.Places[sampleKey] end)
            table.insert(lines, "SampleDef = " .. tostring(def ~= nil))
            table.insert(lines, "SampleName = " .. tostring(XaouWarp_GetDisplayNameSafe(def) or XaouWarp_GetDisplayNameSafe(runtimePlace)))

            local checkFields = {"Name", "DisplayName", "Desc", "Map", "MapName", "Region", "RegionName", "Place", "PlaceID", "Key", "GridKey", "X", "Y", "Pos", "Position", "BornKey", "Icon"}
            local printed = 0
            for _, field in ipairs(checkFields) do
                local v = nil
                pcall(function() if def ~= nil then v = def[field] end end)
                if v == nil then pcall(function() if runtimePlace ~= nil then v = runtimePlace[field] end end) end
                if v ~= nil and printed < 8 then
                    table.insert(lines, tostring(field) .. " = " .. tostring(v))
                    printed = printed + 1
                end
            end
        end

        table.insert(lines, "")
        table.insert(lines, "หมายเหตุ: หน้านี้ยังไม่เรียก Enter/Travel จริง เพื่อกันเกมเด้ง")
    end

    XaouWarp_Msg(table.concat(lines, "\n"), "PlacesMgr")
end


function Xaou_WarpSystem.DebugPlacesMgrApiScan()
    local mgr = XaouWarp_GetPlacesMgr()
    if mgr == nil then
        XaouWarp_Msg("ไม่พบ PlacesMgr", "PlacesMgr API")
        return
    end

    local groups = {
        {"เดินทาง/เข้า Place", {"EnterPlace", "Enter", "VisitPlace", "Visit", "GoToPlace", "GotoPlace", "Goto", "Travel", "StartTravel", "Go", "MoveToPlace"}},
        {"เปิด UI/เลือก Place", {"OpenPlace", "Open", "ShowPlace", "Show", "SelectPlace", "Select", "ClickPlace", "FocusPlace"}},
        {"อ่านข้อมูล", {"GetPlaceDef", "GetPlace", "GetPlaceData", "GetRegion", "GetPlaceRegion", "GetMap", "GetMapName", "GetAllPlaces"}},
        {"ปลดล็อก/สถานะ", {"UnLockPlace", "UnLockAll", "UnlockPlace", "UnlockAll", "SetPlaceOpen", "SetPlaceState", "IsPlaceOpen", "IsUnlocked"}},
    }

    local lines = {"PlacesMgr API Scan v2.4"}
    for _, g in ipairs(groups) do
        table.insert(lines, "")
        table.insert(lines, g[1] .. ":")
        local found = XaouWarp_ScanMethods(mgr, g[2])
        table.insert(lines, found)
    end

    table.insert(lines, "")
    table.insert(lines, "ถ้าเจอ Enter/Visit/Goto/Travel ค่อยทำปุ่มทดสอบแยก")
    XaouWarp_Msg(table.concat(lines, "\n"), "PlacesMgr API")
end

function Xaou_WarpSystem.DebugRuntimePlaceDetail(key)
    local mgr = XaouWarp_GetPlacesMgr()
    if mgr == nil or mgr.Places == nil then
        XaouWarp_Msg("ไม่พบ PlacesMgr.Places", "Place Detail")
        return
    end

    if key == nil or tostring(key) == "" then
        pcall(function()
            for k, _ in pairs(mgr.Places) do key = k; break end
        end)
    end

    if key == nil then
        XaouWarp_Msg("ยังหา key ตัวอย่างไม่ได้", "Place Detail")
        return
    end

    local def = XaouWarp_GetPlaceDefSafe(mgr, key)
    local place = nil
    pcall(function() place = mgr.Places[key] end)

    local fields = {"Name", "DisplayName", "Desc", "Map", "MapName", "Region", "RegionName", "Place", "PlaceID", "Key", "GridKey", "X", "Y", "Pos", "Position", "BornKey", "Icon", "School", "SchoolID", "WorldX", "WorldY"}
    local lines = {"Runtime Place Detail v2.4", "Key = " .. tostring(key), "Def = " .. tostring(def ~= nil), "PlaceObj = " .. tostring(place ~= nil)}
    table.insert(lines, "Name = " .. tostring(XaouWarp_GetDisplayNameSafe(def) or XaouWarp_GetDisplayNameSafe(place)))

    local printed = 0
    for _, field in ipairs(fields) do
        local v = nil
        pcall(function() if def ~= nil then v = def[field] end end)
        if v == nil then pcall(function() if place ~= nil then v = place[field] end end) end
        if v ~= nil then
            table.insert(lines, tostring(field) .. " = " .. tostring(v))
            printed = printed + 1
            if printed >= 14 then break end
        end
    end

    if printed == 0 then table.insert(lines, "ยังอ่าน field เพิ่มไม่ได้") end
    XaouWarp_Msg(table.concat(lines, "\n"), "Place Detail")
end

function Xaou_WarpSystem.DebugPlacesMgrList(page)
    page = tonumber(page or 1) or 1
    if page < 1 then page = 1 end

    local mgr = XaouWarp_GetPlacesMgr()
    if mgr == nil or mgr.Places == nil then
        XaouWarp_Msg("ไม่พบ PlacesMgr.Places บนมือถือ\nจะใช้ฐานข้อมูล Settings ที่ฝังไว้แทนก่อน", "PlacesMgr")
        return
    end

    local list = {}
    pcall(function()
        for k, v in pairs(mgr.Places) do
            local def = XaouWarp_GetPlaceDefSafe(mgr, k)
            local name = XaouWarp_GetDisplayNameSafe(def) or XaouWarp_GetDisplayNameSafe(v) or tostring(k)
            table.insert(list, { key = tostring(k), name = tostring(name) })
        end
    end)

    table.sort(list, function(a, b) return tostring(a.key) < tostring(b.key) end)

    local per = 8
    local total = #list
    local maxPage = math.max(1, math.ceil(total / per))
    if page > maxPage then page = maxPage end
    Xaou_WarpSystem._runtimePlacePage = page

    local lines = {}
    table.insert(lines, "PlacesMgr.Places = " .. tostring(total) .. " รายการ")
    table.insert(lines, "หน้า " .. tostring(page) .. "/" .. tostring(maxPage))

    local startIndex = (page - 1) * per + 1
    for i = startIndex, math.min(total, startIndex + per - 1) do
        local item = list[i]
        table.insert(lines, tostring(i) .. ". " .. tostring(item.name) .. " | " .. tostring(item.key))
    end

    if total == 0 then
        table.insert(lines, "ไม่พบรายการใน PlacesMgr.Places")
    end

    XaouWarp_Msg(table.concat(lines, "\n"), "PlacesMgr List")
end

function Xaou_WarpSystem.DebugPlacesMgrNextPage()
    local p = tonumber(Xaou_WarpSystem._runtimePlacePage or 1) or 1
    Xaou_WarpSystem.DebugPlacesMgrList(p + 1)
end

--------------------------------------------------
-- v2.5 Runtime Manager Scan
-- เป้าหมาย: หา manager ที่อาจมีคำสั่ง Enter/Visit/Goto/Travel
--------------------------------------------------

local function XaouWarp_GetGlobalSafe(name)
    local v = nil
    pcall(function()
        if _G ~= nil then v = _G[name] end
    end)
    return v
end

local function XaouWarp_GetCSPathSafe(path)
    local cur = CS
    if cur == nil then return nil end
    for part in string.gmatch(tostring(path or ""), "[^%.]+") do
        local nextObj = nil
        pcall(function() nextObj = cur[part] end)
        if nextObj == nil then return nil end
        cur = nextObj
    end
    return cur
end

local function XaouWarp_TryInstance(obj)
    local inst = nil
    pcall(function() if obj ~= nil then inst = obj.Instance end end)
    return inst or obj
end

local function XaouWarp_ScanOneRuntimeManager(label, obj, lines, candidates)
    table.insert(lines, "")
    table.insert(lines, tostring(label) .. " = " .. tostring(obj ~= nil))
    if obj == nil then return end
    local target = XaouWarp_TryInstance(obj)
    if target ~= obj then
        table.insert(lines, "  Instance = true")
    end
    local found = XaouWarp_ScanMethods(target, candidates)
    table.insert(lines, "  method = " .. tostring(found))
end

function Xaou_WarpSystem.DebugRuntimeManagerScan()
    local candidates = {
        "EnterPlace", "Enter", "VisitPlace", "Visit", "GoToPlace", "GotoPlace", "Goto", "GoTo",
        "Travel", "StartTravel", "MoveToPlace", "OpenPlace", "Open", "ShowPlace", "SelectPlace",
        "EnterRegion", "GotoRegion", "TravelToRegion", "StartOutspread", "OpenOutspread",
        "EnterMap", "LoadMap", "ChangeMap", "SwitchMap", "GotoMap", "FocusPlace", "LookAtPlace"
    }

    local lines = {
        "Runtime Manager Scan v2.5",
        "หา API เดินทาง/เข้า Place แบบไม่เรียกจริง"
    }

    local globals = {
        "World", "world", "WorldLua", "Map", "MapMgr", "WorldMgr", "RegionMgr", "PlacesMgr",
        "OutMgr", "OutspreadMgr", "SchoolMgr", "JianghuMgr", "GameMain", "ThingMgr", "CameraMgr"
    }
    for _, name in ipairs(globals) do
        XaouWarp_ScanOneRuntimeManager(name, XaouWarp_GetGlobalSafe(name), lines, candidates)
    end

    local csPaths = {
        "XiaWorld.OutspreadMgr",
        "XiaWorld.OutspreadMgr.Instance",
        "XiaWorld.World",
        "XiaWorld.World.Instance",
        "XiaWorld.WorldLua",
        "XiaWorld.WorldLua.Instance",
        "XiaWorld.PlacesMgr",
        "XiaWorld.PlacesMgr.Instance",
        "XiaWorld.MapMgr",
        "XiaWorld.MapMgr.Instance",
        "XiaWorld.WorldMapMgr",
        "XiaWorld.WorldMapMgr.Instance",
        "XiaWorld.SchoolMgr",
        "XiaWorld.SchoolMgr.Instance",
        "XiaWorld.GameMain",
        "GameMain",
        "GameMain.Instance"
    }
    for _, path in ipairs(csPaths) do
        XaouWarp_ScanOneRuntimeManager("CS." .. path, XaouWarp_GetCSPathSafe(path), lines, candidates)
    end

    table.insert(lines, "")
    table.insert(lines, "ถ้าเจอ method กลุ่ม Enter/Visit/Goto/Travel ให้ทำปุ่มทดสอบแยกในรอบถัดไป")
    XaouWarp_Msg(table.concat(lines, "\n"), "Runtime API")
end

--------------------------------------------------
-- v2.6 Warp Tester
-- เป้าหมาย: ทดลองเรียก API เดินทางทีละชุด พร้อมจับ error
--------------------------------------------------

local function XaouWarp_ResolveTestPlaceKey(keyword)
    keyword = tostring(keyword or "")
    local mgr = XaouWarp_GetPlacesMgr()

    -- ถ้ามี keyword ให้หาใน Runtime PlacesMgr ก่อน
    if keyword ~= "" and mgr ~= nil and mgr.Places ~= nil then
        local low = string.lower(keyword)
        local foundKey = nil
        pcall(function()
            for k, v in pairs(mgr.Places) do
                local def = XaouWarp_GetPlaceDefSafe(mgr, k)
                local name = XaouWarp_GetDisplayNameSafe(def) or XaouWarp_GetDisplayNameSafe(v) or tostring(k)
                local text = string.lower(tostring(k) .. " " .. tostring(name))
                if string.find(text, low, 1, true) ~= nil then
                    foundKey = tostring(k)
                    break
                end
            end
        end)
        if foundKey ~= nil then return foundKey end
    end

    -- หาในฐาน Settings ที่ฝังไว้
    if keyword ~= "" then
        for _, p in ipairs(Xaou_WarpSystem.PlaceData or {}) do
            if XaouWarp_PlaceMatch ~= nil and XaouWarp_PlaceMatch(p, keyword) then
                return tostring(p.id or p.key or p.name)
            end
        end
    end

    -- ค่า default ที่ Runtime เคยพบแล้ว
    if mgr ~= nil and mgr.Places ~= nil then
        local fallback = nil
        pcall(function()
            if mgr.Places["Place_BigBamboo"] ~= nil then fallback = "Place_BigBamboo" end
        end)
        if fallback ~= nil then return fallback end
        pcall(function()
            for k, _ in pairs(mgr.Places) do fallback = tostring(k); break end
        end)
        if fallback ~= nil then return fallback end
    end

    return "Place_BigBamboo"
end

local function XaouWarp_GetRuntimeTargets()
    local targets = {}
    local function add(label, obj)
        if obj == nil then return end
        local t = XaouWarp_TryInstance(obj)
        targets[label] = t or obj
    end

    add("GameMain", XaouWarp_GetGlobalSafe("GameMain"))
    add("CS.XiaWorld.GameMain", XaouWarp_GetCSPathSafe("XiaWorld.GameMain"))
    add("CS.XiaWorld.GameMain.Instance", XaouWarp_GetCSPathSafe("XiaWorld.GameMain.Instance"))
    add("MapMgr", XaouWarp_GetGlobalSafe("MapMgr"))
    add("CS.XiaWorld.MapMgr", XaouWarp_GetCSPathSafe("XiaWorld.MapMgr"))
    add("CS.XiaWorld.MapMgr.Instance", XaouWarp_GetCSPathSafe("XiaWorld.MapMgr.Instance"))
    add("WorldMapMgr", XaouWarp_GetGlobalSafe("WorldMapMgr"))
    add("CS.XiaWorld.WorldMapMgr", XaouWarp_GetCSPathSafe("XiaWorld.WorldMapMgr"))
    add("CS.XiaWorld.WorldMapMgr.Instance", XaouWarp_GetCSPathSafe("XiaWorld.WorldMapMgr.Instance"))
    add("WorldLua", XaouWarp_GetGlobalSafe("WorldLua"))
    add("CS.XiaWorld.WorldLua", XaouWarp_GetCSPathSafe("XiaWorld.WorldLua"))
    add("CS.XiaWorld.WorldLua.Instance", XaouWarp_GetCSPathSafe("XiaWorld.WorldLua.Instance"))
    add("World", XaouWarp_GetGlobalSafe("World"))
    add("world", XaouWarp_GetGlobalSafe("world"))
    return targets
end

local function XaouWarp_GetPlaceDefForKey(key)
    local mgr = XaouWarp_GetPlacesMgr()
    if mgr == nil or key == nil then return nil end
    return XaouWarp_GetPlaceDefSafe(mgr, key)
end

local function XaouWarp_TryCallMethod(target, method, key, def)
    if target == nil or method == nil then return false, "target/method nil" end
    local fn = nil
    pcall(function() fn = target[method] end)
    if fn == nil then return false, "method nil" end

    local variants = {
        {"colon(key)", function() return fn(target, key) end},
        {"dot(key)", function() return fn(key) end},
        {"colon(key,true)", function() return fn(target, key, true) end},
        {"colon(key,false)", function() return fn(target, key, false) end},
    }
    if def ~= nil then
        table.insert(variants, {"colon(def)", function() return fn(target, def) end})
        table.insert(variants, {"dot(def)", function() return fn(def) end})
        table.insert(variants, {"colon(def,true)", function() return fn(target, def, true) end})
    end

    local lastErr = ""
    for _, v in ipairs(variants) do
        local ok, ret = pcall(v[2])
        if ok then
            return true, tostring(method) .. " " .. tostring(v[1]) .. " OK ret=" .. tostring(ret)
        else
            lastErr = tostring(v[1]) .. " => " .. tostring(ret)
        end
    end
    return false, lastErr
end

local function XaouWarp_TestOnTargets(targetLabels, methods, placeKey)
    local targets = XaouWarp_GetRuntimeTargets()
    local def = XaouWarp_GetPlaceDefForKey(placeKey)
    local lines = {
        "Warp Tester v2.6",
        "PlaceKey = " .. tostring(placeKey),
        "Def = " .. tostring(def ~= nil),
        "หมายเหตุ: OK หมายถึงเรียกเมธอดไม่ error แต่อาจยังไม่เปลี่ยนแมพเสมอไป",
        ""
    }

    local anyOk = false
    local tried = 0
    for _, label in ipairs(targetLabels or {}) do
        local target = targets[label]
        table.insert(lines, tostring(label) .. " = " .. tostring(target ~= nil))
        if target ~= nil then
            for _, method in ipairs(methods or {}) do
                if XaouWarp_HasMethod(target, method) then
                    tried = tried + 1
                    local ok, msg = XaouWarp_TryCallMethod(target, method, placeKey, def)
                    table.insert(lines, "  " .. tostring(method) .. " -> " .. (ok and "OK" or "ERR"))
                    table.insert(lines, "    " .. tostring(msg))
                    if ok then
                        anyOk = true
                        -- หยุดทันทีเพื่อไม่เรียกหลายคำสั่งซ้อนกัน
                        XaouWarp_Msg(table.concat(lines, "\n"), "Warp Tester")
                        return true
                    end
                    if tried >= 10 then break end
                end
            end
        end
        if tried >= 10 then break end
    end

    if tried == 0 then table.insert(lines, "ไม่พบ method ที่ตรงกับชุดนี้") end
    if not anyOk then table.insert(lines, "ยังไม่มีคำสั่งที่เรียกสำเร็จในชุดนี้") end
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp Tester")
    return anyOk
end

function Xaou_WarpSystem.DebugTravelTesterInfo(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local def = XaouWarp_GetPlaceDefForKey(key)
    local lines = {
        "Warp Tester Info v2.6",
        "Keyword = " .. tostring(keyword or ""),
        "TestPlaceKey = " .. tostring(key),
        "Def = " .. tostring(def ~= nil),
        "Name = " .. tostring(XaouWarp_GetDisplayNameSafe(def)),
        "",
        "แนะนำทดสอบตามลำดับ:",
        "1) ทดสอบ Open/Show Place",
        "2) Test WorldLua หรือ WorldMapMgr",
        "3) Test GameMain / MapMgr",
        "",
        "ถ้า OK แล้วฉากเปลี่ยนหรือเปิดหน้าต่าง ให้แคปรูปผลลัพธ์มา"
    }
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp Tester")
end

function Xaou_WarpSystem.TestTravelApi(action, keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    action = tostring(action or "")

    if action == "test_open_place" then
        return XaouWarp_TestOnTargets(
            {"CS.XiaWorld.WorldLua.Instance", "CS.XiaWorld.WorldMapMgr.Instance", "CS.XiaWorld.GameMain.Instance", "CS.XiaWorld.MapMgr.Instance"},
            {"OpenPlace", "ShowPlace", "SelectPlace", "FocusPlace", "LookAtPlace", "Open", "Show", "Select"},
            key
        )
    elseif action == "test_gamemain" then
        return XaouWarp_TestOnTargets(
            {"CS.XiaWorld.GameMain.Instance", "CS.XiaWorld.GameMain", "GameMain"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "Enter", "Visit", "Goto", "GoTo"},
            key
        )
    elseif action == "test_mapmgr" then
        return XaouWarp_TestOnTargets(
            {"CS.XiaWorld.MapMgr.Instance", "CS.XiaWorld.MapMgr", "MapMgr"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "EnterMap", "LoadMap", "ChangeMap", "SwitchMap", "GotoMap"},
            key
        )
    elseif action == "test_worldmapmgr" then
        return XaouWarp_TestOnTargets(
            {"CS.XiaWorld.WorldMapMgr.Instance", "CS.XiaWorld.WorldMapMgr", "WorldMapMgr"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "EnterRegion", "GotoRegion", "TravelToRegion", "OpenPlace", "ShowPlace", "SelectPlace"},
            key
        )
    elseif action == "test_worldlua" then
        return XaouWarp_TestOnTargets(
            {"CS.XiaWorld.WorldLua.Instance", "CS.XiaWorld.WorldLua", "WorldLua", "World", "world"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "OpenPlace", "ShowPlace", "SelectPlace", "Enter", "Visit", "Goto", "GoTo"},
            key
        )
    elseif action == "test_travel_safe" then
        return XaouWarp_TestOnTargets(
            {"CS.XiaWorld.WorldLua.Instance", "CS.XiaWorld.WorldMapMgr.Instance", "CS.XiaWorld.GameMain.Instance", "CS.XiaWorld.MapMgr.Instance"},
            {"OpenPlace", "ShowPlace", "SelectPlace", "FocusPlace", "LookAtPlace"},
            key
        )
    end

    XaouWarp_Msg("ยังไม่รู้จัก action: " .. tostring(action), "Warp Tester")
    return false
end

--------------------------------------------------
-- Xaou_009 Warp System v2.7 patch
-- - แก้ตัวทดสอบที่เผลอเรียก Instance.Instance
-- - เพิ่ม Runtime Object Scan เพื่อหา object/field ที่ถือ Place/Map จริง
--------------------------------------------------

local function XaouWarp_GetManagerV27(name)
    name = tostring(name or "")
    local obj = nil
    if name == "GameMain" then
        obj = XaouWarp_GetGlobalSafe("GameMain") or XaouWarp_GetCSPathSafe("XiaWorld.GameMain")
    elseif name == "MapMgr" then
        obj = XaouWarp_GetGlobalSafe("MapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.MapMgr")
    elseif name == "WorldMapMgr" then
        obj = XaouWarp_GetGlobalSafe("WorldMapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.WorldMapMgr")
    elseif name == "WorldLua" then
        obj = XaouWarp_GetGlobalSafe("WorldLua") or XaouWarp_GetCSPathSafe("XiaWorld.WorldLua")
    elseif name == "PlacesMgr" then
        obj = XaouWarp_GetPlacesMgr() or XaouWarp_GetCSPathSafe("XiaWorld.PlacesMgr")
    elseif name == "OutspreadMgr" then
        obj = XaouWarp_GetGlobalSafe("OutspreadMgr") or XaouWarp_GetCSPathSafe("XiaWorld.OutspreadMgr")
    elseif name == "World" then
        obj = XaouWarp_GetGlobalSafe("World") or XaouWarp_GetGlobalSafe("world") or XaouWarp_GetCSPathSafe("XiaWorld.World")
    elseif name == "Map" then
        obj = XaouWarp_GetGlobalSafe("Map") or XaouWarp_GetCSPathSafe("XiaWorld.Map")
    end

    -- สำคัญ: เรียก Instance แค่ครั้งเดียว ห้ามเอา path .Instance มา TryInstance ซ้ำ
    local inst = nil
    pcall(function()
        if obj ~= nil and obj.Instance ~= nil then inst = obj.Instance end
    end)
    return inst or obj
end

local function XaouWarp_FieldTextV27(obj, field)
    local v = nil
    pcall(function() if obj ~= nil then v = obj[field] end end)
    if v == nil then return nil end
    local text = tostring(v)
    if string.len(text) > 48 then text = string.sub(text, 1, 48) .. "..." end
    return tostring(field) .. "=" .. text
end

function Xaou_WarpSystem.DebugRuntimeObjectScan()
    local managers = {"GameMain", "WorldLua", "WorldMapMgr", "MapMgr", "PlacesMgr", "OutspreadMgr", "World", "Map"}
    local fields = {
        "CurPlace", "CurrentPlace", "SelectPlace", "SelectedPlace", "Place", "place", "PlaceData", "CurPlaceData",
        "CurRegion", "CurrentRegion", "Region", "region", "SelectRegion", "SelectedRegion",
        "CurMap", "CurrentMap", "Map", "map", "WorldMap", "MainMap", "MapData",
        "CurArea", "CurrentArea", "Area", "area", "CurKey", "Key", "WorldKey"
    }
    local methods = {
        "EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace",
        "OpenPlace", "ShowPlace", "SelectPlace", "FocusPlace", "LookAtPlace",
        "EnterMap", "LoadMap", "ChangeMap", "SwitchMap", "GotoMap"
    }

    local lines = {"Runtime Object Scan v2.7", "หา object/field จริง ไม่เรียก Instance ซ้ำ", ""}
    for _, name in ipairs(managers) do
        local obj = XaouWarp_GetManagerV27(name)
        table.insert(lines, tostring(name) .. " = " .. tostring(obj ~= nil))
        if obj ~= nil then
            local foundFields = {}
            for _, f in ipairs(fields) do
                local txt = XaouWarp_FieldTextV27(obj, f)
                if txt ~= nil then table.insert(foundFields, txt) end
                if #foundFields >= 5 then break end
            end
            table.insert(lines, "  field = " .. (#foundFields > 0 and table.concat(foundFields, " | ") or "ไม่พบ field สำคัญ"))
            table.insert(lines, "  method = " .. tostring(XaouWarp_ScanMethods(obj, methods)))
        end
        table.insert(lines, "")
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "Runtime Object")
end

local function XaouWarp_TryCallMethodV27(target, method, key, def)
    if target == nil then return false, "target nil" end
    local fn = nil
    local okGet, errGet = pcall(function() fn = target[method] end)
    if (not okGet) then return false, "get method err: " .. tostring(errGet) end
    if fn == nil then return false, "method nil" end

    local variants = {
        {"colon(key)", function() return fn(target, key) end},
        {"colon(key,true)", function() return fn(target, key, true) end},
        {"colon(key,false)", function() return fn(target, key, false) end},
        {"colon(key,def)", function() return fn(target, key, def) end},
    }
    if def ~= nil then
        table.insert(variants, {"colon(def)", function() return fn(target, def) end})
        table.insert(variants, {"colon(def,true)", function() return fn(target, def, true) end})
    end

    local lastErr = ""
    for _, v in ipairs(variants) do
        local ok, ret = pcall(v[2])
        if ok then
            return true, tostring(method) .. " " .. tostring(v[1]) .. " OK ret=" .. tostring(ret)
        else
            lastErr = tostring(v[1]) .. " => " .. tostring(ret)
        end
    end
    return false, lastErr
end

local function XaouWarp_TestManagerV27(managerNames, methods, placeKey)
    local def = XaouWarp_GetPlaceDefForKey(placeKey)
    local lines = {
        "Warp Tester v2.7",
        "PlaceKey = " .. tostring(placeKey),
        "Def = " .. tostring(def ~= nil),
        "แก้แล้ว: ไม่เรียก Instance.Instance",
        ""
    }
    local tried = 0
    for _, mgrName in ipairs(managerNames or {}) do
        local obj = XaouWarp_GetManagerV27(mgrName)
        table.insert(lines, tostring(mgrName) .. " = " .. tostring(obj ~= nil))
        if obj ~= nil then
            for _, method in ipairs(methods or {}) do
                if XaouWarp_HasMethod(obj, method) then
                    tried = tried + 1
                    local ok, msg = XaouWarp_TryCallMethodV27(obj, method, placeKey, def)
                    table.insert(lines, "  " .. tostring(method) .. " -> " .. (ok and "OK" or "ERR"))
                    table.insert(lines, "    " .. tostring(msg))
                    if ok then
                        table.insert(lines, "")
                        table.insert(lines, "ถ้าหน้าจอ/แมพเปลี่ยน แปลว่าตัวนี้ใช้ได้")
                        XaouWarp_Msg(table.concat(lines, "\n"), "Warp Tester")
                        return true
                    end
                    if tried >= 12 then break end
                end
            end
        end
        if tried >= 12 then break end
    end
    if tried == 0 then table.insert(lines, "ไม่พบ method บน object จริงของชุดนี้") end
    table.insert(lines, "ยังไม่มีคำสั่งที่เรียกสำเร็จในชุดนี้")
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp Tester")
    return false
end

-- override v2.6: ใช้ resolver ใหม่ที่ไม่ทำ Instance ซ้ำ
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    action = tostring(action or "")
    if action == "test_open_place" then
        return XaouWarp_TestManagerV27(
            {"WorldMapMgr", "MapMgr", "GameMain", "WorldLua"},
            {"OpenPlace", "ShowPlace", "SelectPlace", "FocusPlace", "LookAtPlace", "Open", "Show", "Select"},
            key
        )
    elseif action == "test_gamemain" then
        return XaouWarp_TestManagerV27(
            {"GameMain"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "Enter", "Visit", "Goto", "GoTo"},
            key
        )
    elseif action == "test_mapmgr" then
        return XaouWarp_TestManagerV27(
            {"MapMgr"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "EnterMap", "LoadMap", "ChangeMap", "SwitchMap", "GotoMap"},
            key
        )
    elseif action == "test_worldmapmgr" then
        return XaouWarp_TestManagerV27(
            {"WorldMapMgr"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "EnterRegion", "GotoRegion", "TravelToRegion", "OpenPlace", "ShowPlace", "SelectPlace"},
            key
        )
    elseif action == "test_worldlua" then
        return XaouWarp_TestManagerV27(
            {"WorldLua", "World"},
            {"EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "OpenPlace", "ShowPlace", "SelectPlace", "Enter", "Visit", "Goto", "GoTo"},
            key
        )
    elseif action == "test_travel_safe" then
        return XaouWarp_TestManagerV27(
            {"WorldMapMgr", "MapMgr", "GameMain", "WorldLua"},
            {"OpenPlace", "ShowPlace", "SelectPlace", "FocusPlace", "LookAtPlace"},
            key
        )
    end
    XaouWarp_Msg("ยังไม่รู้จัก action: " .. tostring(action), "Warp Tester")
    return false
end

--------------------------------------------------
-- Xaou_009 Warp System v2.8 patch
-- Runtime Place Explorer + Invoke แบบใหม่
-- จุดประสงค์: ใช้ object/field จริงของ WorldMapMgr และลองเรียกแบบ dot ก่อน colon
--------------------------------------------------

local function XaouWarp_GetManagerV28(name)
    name = tostring(name or "")
    local obj = nil
    if name == "WorldMapMgr" then
        obj = XaouWarp_GetGlobalSafe("WorldMapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.WorldMapMgr")
    elseif name == "MapMgr" then
        obj = XaouWarp_GetGlobalSafe("MapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.MapMgr")
    elseif name == "GameMain" then
        obj = XaouWarp_GetGlobalSafe("GameMain") or XaouWarp_GetCSPathSafe("XiaWorld.GameMain")
    elseif name == "WorldLua" then
        obj = XaouWarp_GetGlobalSafe("WorldLua") or XaouWarp_GetCSPathSafe("XiaWorld.WorldLua")
    elseif name == "PlacesMgr" then
        obj = XaouWarp_GetPlacesMgr() or XaouWarp_GetGlobalSafe("PlacesMgr") or XaouWarp_GetCSPathSafe("XiaWorld.PlacesMgr")
    elseif name == "World" then
        obj = XaouWarp_GetGlobalSafe("World") or XaouWarp_GetGlobalSafe("world") or XaouWarp_GetCSPathSafe("XiaWorld.World")
    elseif name == "Map" then
        obj = XaouWarp_GetGlobalSafe("Map") or XaouWarp_GetCSPathSafe("XiaWorld.Map")
    end
    -- ไม่บังคับ Instance เพื่อกัน Instance.Instance แต่ถ้า obj ไม่มี field/method ค่อยลอง Instance หนึ่งครั้ง
    return obj
end

local function XaouWarp_GetFieldSafe(obj, field)
    local v = nil
    pcall(function() if obj ~= nil then v = obj[field] end end)
    return v
end

local function XaouWarp_ShortObj(v)
    if v == nil then return "nil" end
    local s = tostring(v)
    if string.len(s) > 52 then s = string.sub(s, 1, 52) .. "..." end
    return s
end

local function XaouWarp_ReadSomeFields(obj)
    local fields = {"Name", "DisplayName", "Key", "Place", "PlaceID", "Region", "RegionName", "Map", "MapName", "X", "Y", "WorldX", "WorldY", "GridKey", "Icon", "Desc"}
    local out = {}
    for _, f in ipairs(fields) do
        local v = XaouWarp_GetFieldSafe(obj, f)
        if v ~= nil then
            table.insert(out, tostring(f) .. "=" .. XaouWarp_ShortObj(v))
            if #out >= 6 then break end
        end
    end
    return (#out > 0) and table.concat(out, " | ") or "ไม่พบ field อ่านง่าย"
end

local function XaouWarp_GetRuntimePlaceObjectsV28(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local mgr = XaouWarp_GetManagerV28("WorldMapMgr")
    local mgrInst = nil
    pcall(function() if mgr ~= nil and mgr.Instance ~= nil then mgrInst = mgr.Instance end end)

    local pmgr = XaouWarp_GetPlacesMgr()
    local def = XaouWarp_GetPlaceDefForKey(key)
    local runtimePlace = nil
    pcall(function() if pmgr ~= nil and pmgr.Places ~= nil then runtimePlace = pmgr.Places[key] end end)

    local list = {}
    local function add(label, obj)
        if obj ~= nil then table.insert(list, {label=label, obj=obj}) end
    end

    add("WorldMapMgr", mgr)
    add("WorldMapMgr.Instance", mgrInst)
    if mgr ~= nil then
        for _, f in ipairs({"CurPlace", "CurrentPlace", "SelectPlace", "SelectedPlace", "Place", "PlaceData", "CurPlaceData", "CurRegion", "Region", "CurrentRegion", "Map", "WorldMap"}) do
            add("WorldMapMgr." .. f, XaouWarp_GetFieldSafe(mgr, f))
        end
    end
    if mgrInst ~= nil and mgrInst ~= mgr then
        for _, f in ipairs({"CurPlace", "CurrentPlace", "SelectPlace", "SelectedPlace", "Place", "PlaceData", "CurPlaceData", "CurRegion", "Region", "CurrentRegion", "Map", "WorldMap"}) do
            add("WorldMapMgr.Instance." .. f, XaouWarp_GetFieldSafe(mgrInst, f))
        end
    end
    add("PlacesMgr.Places[key]", runtimePlace)
    add("PlaceDef", def)
    return list, key, def
end

function Xaou_WarpSystem.DebugWorldMapFields(keyword)
    local list, key, def = XaouWarp_GetRuntimePlaceObjectsV28(keyword)
    local lines = {"Runtime Place Explorer v2.8", "PlaceKey = " .. tostring(key), "Def = " .. tostring(def ~= nil), ""}
    local shown = 0
    for _, it in ipairs(list) do
        table.insert(lines, tostring(it.label) .. " = " .. XaouWarp_ShortObj(it.obj))
        table.insert(lines, "  field: " .. XaouWarp_ReadSomeFields(it.obj))
        shown = shown + 1
        if shown >= 9 then break end
    end
    if shown == 0 then table.insert(lines, "ยังไม่พบ Runtime Place Object") end
    table.insert(lines, "")
    table.insert(lines, "ดูค่านี้เพื่อหา CurPlace/SelectedPlace ที่ใช้เดินทางจริง")
    XaouWarp_Msg(table.concat(lines, "\n"), "Runtime Place")
end

local function XaouWarp_TryInvokeV28(target, method, key, def, placeObj)
    if target == nil then return false, "target nil" end
    local fn = nil
    local okGet, errGet = pcall(function() fn = target[method] end)
    if not okGet then return false, "get method err: " .. tostring(errGet) end
    if fn == nil then return false, "method nil" end

    local variants = {}
    local function add(name, f) table.insert(variants, {name, f}) end

    -- บาง bridge ของมือถือ method proxy ต้องเรียกแบบ dot ไม่ส่ง self
    add("dot(key)", function() return fn(key) end)
    add("dot(key,true)", function() return fn(key, true) end)
    add("dot(key,false)", function() return fn(key, false) end)
    if def ~= nil then
        add("dot(def)", function() return fn(def) end)
        add("dot(def,true)", function() return fn(def, true) end)
        add("dot(key,def)", function() return fn(key, def) end)
    end
    if placeObj ~= nil then
        add("dot(placeObj)", function() return fn(placeObj) end)
        add("dot(placeObj,true)", function() return fn(placeObj, true) end)
    end

    -- fallback แบบ colon เดิม
    add("colon(key)", function() return fn(target, key) end)
    add("colon(key,true)", function() return fn(target, key, true) end)
    if def ~= nil then add("colon(def)", function() return fn(target, def) end) end
    if placeObj ~= nil then add("colon(placeObj)", function() return fn(target, placeObj) end) end

    local lastErr = ""
    for _, v in ipairs(variants) do
        local ok, ret = pcall(v[2])
        if ok then return true, tostring(method) .. " " .. tostring(v[1]) .. " OK ret=" .. tostring(ret) end
        lastErr = tostring(v[1]) .. " => " .. tostring(ret)
    end
    return false, lastErr
end

function Xaou_WarpSystem.TestInvokeV28(keyword)
    local list, key, def = XaouWarp_GetRuntimePlaceObjectsV28(keyword)
    local placeObj = nil
    for _, it in ipairs(list) do
        if tostring(it.label) == "PlacesMgr.Places[key]" then placeObj = it.obj end
    end

    local methods = {"OpenPlace", "ShowPlace", "SelectPlace", "FocusPlace", "LookAtPlace", "EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "Open", "Show", "Select", "Enter", "Visit", "Goto", "GoTo"}
    local lines = {"Invoke Tester v2.8", "PlaceKey = " .. tostring(key), "ลอง dot ก่อน colon / ใช้ field object จริง", ""}
    local tried = 0
    for _, it in ipairs(list) do
        local obj = it.obj
        local foundAny = false
        for _, m in ipairs(methods) do
            if XaouWarp_HasMethod(obj, m) then
                foundAny = true
                tried = tried + 1
                local ok, msg = XaouWarp_TryInvokeV28(obj, m, key, def, placeObj)
                table.insert(lines, tostring(it.label) .. ":" .. tostring(m) .. " -> " .. (ok and "OK" or "ERR"))
                table.insert(lines, "  " .. tostring(msg))
                if ok then
                    table.insert(lines, "")
                    table.insert(lines, "ถ้ามีหน้าต่าง/กล้อง/แผนที่เปลี่ยน ตัวนี้คือเบาะแสสำคัญ")
                    XaouWarp_Msg(table.concat(lines, "\n"), "Invoke v2.8")
                    return true
                end
                if tried >= 14 then break end
            end
        end
        if foundAny == false and tried < 6 then
            -- ไม่ต้องแสดงทุก object ที่ไม่มี method เดี๋ยวยาวเกิน
        end
        if tried >= 14 then break end
    end
    if tried == 0 then table.insert(lines, "ยังไม่พบ method บน object/field ที่ลอง") end
    table.insert(lines, "ยังไม่มีตัวที่ OK รอบนี้")
    XaouWarp_Msg(table.concat(lines, "\n"), "Invoke v2.8")
    return false
end

function Xaou_WarpSystem.TestCurrentPlaceObject(keyword)
    local list, key, def = XaouWarp_GetRuntimePlaceObjectsV28(keyword)
    local methods = {"Enter", "Visit", "Goto", "GoTo", "Travel", "Open", "Show", "Select", "Focus", "LookAt", "EnterPlace", "VisitPlace", "GotoPlace", "OpenPlace", "ShowPlace", "SelectPlace"}
    local lines = {"Current Place Object Test v2.8", "PlaceKey = " .. tostring(key), "ทดสอบ method บน CurPlace/SelectedPlace/Place", ""}
    local tried = 0
    for _, it in ipairs(list) do
        local label = tostring(it.label)
        if string.find(label, "Place") or string.find(label, "Region") then
            table.insert(lines, label .. " = " .. XaouWarp_ShortObj(it.obj))
            table.insert(lines, "  field: " .. XaouWarp_ReadSomeFields(it.obj))
            for _, m in ipairs(methods) do
                if XaouWarp_HasMethod(it.obj, m) then
                    tried = tried + 1
                    local ok, msg = XaouWarp_TryInvokeV28(it.obj, m, key, def, it.obj)
                    table.insert(lines, "  " .. tostring(m) .. " -> " .. (ok and "OK" or "ERR"))
                    table.insert(lines, "    " .. tostring(msg))
                    if ok then
                        XaouWarp_Msg(table.concat(lines, "\n"), "Current Place")
                        return true
                    end
                    if tried >= 10 then break end
                end
            end
        end
        if tried >= 10 then break end
    end
    if tried == 0 then table.insert(lines, "ยังไม่เจอ method บน Current/Selected Place object") end
    XaouWarp_Msg(table.concat(lines, "\n"), "Current Place")
    return false
end

-- override tester อีกครั้ง: ใช้ Invoke v2.8 ที่ลอง dot ก่อน colon
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "test_invoke_v28" then return Xaou_WarpSystem.TestInvokeV28(keyword) end
    if action == "test_current_place" then return Xaou_WarpSystem.TestCurrentPlaceObject(keyword) end
    if action == "test_open_place" then return Xaou_WarpSystem.TestInvokeV28(keyword) end

    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local def = XaouWarp_GetPlaceDefForKey(key)
    local targetNames = {}
    if action == "test_worldmapmgr" then targetNames = {"WorldMapMgr"}
    elseif action == "test_mapmgr" then targetNames = {"MapMgr"}
    elseif action == "test_gamemain" then targetNames = {"GameMain"}
    elseif action == "test_worldlua" then targetNames = {"WorldLua", "World"}
    else return Xaou_WarpSystem.TestInvokeV28(keyword) end

    local methods = {"OpenPlace", "ShowPlace", "SelectPlace", "FocusPlace", "LookAtPlace", "EnterPlace", "VisitPlace", "GotoPlace", "GoToPlace", "Travel", "StartTravel", "MoveToPlace", "Open", "Show", "Select", "Enter", "Visit", "Goto", "GoTo"}
    local lines = {"Warp Tester v2.8", "PlaceKey = " .. tostring(key), "Def = " .. tostring(def ~= nil), "ลอง dot ก่อน colon", ""}
    local tried = 0
    for _, n in ipairs(targetNames) do
        local obj = XaouWarp_GetManagerV28(n)
        local inst = nil
        pcall(function() if obj ~= nil and obj.Instance ~= nil then inst = obj.Instance end end)
        local targets = {{n, obj}}
        if inst ~= nil and inst ~= obj then table.insert(targets, {n .. ".Instance", inst}) end
        for _, it in ipairs(targets) do
            table.insert(lines, tostring(it[1]) .. " = " .. tostring(it[2] ~= nil))
            for _, m in ipairs(methods) do
                if XaouWarp_HasMethod(it[2], m) then
                    tried = tried + 1
                    local ok, msg = XaouWarp_TryInvokeV28(it[2], m, key, def, nil)
                    table.insert(lines, "  " .. tostring(m) .. " -> " .. (ok and "OK" or "ERR"))
                    table.insert(lines, "    " .. tostring(msg))
                    if ok then
                        XaouWarp_Msg(table.concat(lines, "\n"), "Warp Tester")
                        return true
                    end
                    if tried >= 12 then break end
                end
            end
            if tried >= 12 then break end
        end
    end
    if tried == 0 then table.insert(lines, "ไม่พบ method บน target ชุดนี้") end
    table.insert(lines, "ยังไม่มีตัวที่ OK")
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp Tester")
    return false
end


--------------------------------------------------
-- Xaou_009 Warp System v2.9 patch
-- RPGMapMgr + Wnd_SelectNpc4Map + WorldLuaHelper Tester
-- หมายเหตุ: รอบนี้ไม่พึ่ง WorldMapMgr เป็นหลักแล้ว เพราะ .dat ชี้ว่าเส้นทางจริงคือ
-- Wnd_SelectNpc4Map -> EnterPlace/EnterWorld/ClickYes -> RPGMapMgr.EnterRPGWorld
--------------------------------------------------

local function XaouWarp_GetObjV29(name)
    name = tostring(name or "")
    local candidates = {}
    local function add(v) if v ~= nil then table.insert(candidates, v) end end

    if name == "RPGMapMgr" then
        add(XaouWarp_GetGlobalSafe("RPGMapMgr"))
        add(XaouWarp_GetGlobalSafe("rpgMapMgr"))
        add(XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr"))
        add(XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr.Instance"))
    elseif name == "WorldLuaHelper" then
        add(XaouWarp_GetGlobalSafe("WorldLuaHelper"))
        add(XaouWarp_GetCSPathSafe("XiaWorld.WorldLuaHelper"))
        add(XaouWarp_GetCSPathSafe("WorldLuaHelper"))
    elseif name == "Wnd_SelectNpc4Map" then
        add(XaouWarp_GetGlobalSafe("Wnd_SelectNpc4Map"))
        add(XaouWarp_GetGlobalSafe("wnd_SelectNpc4Map"))
        add(XaouWarp_GetCSPathSafe("XiaWorld.Wnd_SelectNpc4Map"))
        add(XaouWarp_GetCSPathSafe("XiaWorld.Wnd_SelectNpc4Map.Instance"))
        add(XaouWarp_GetCSPathSafe("Wnd_SelectNpc4Map"))
    elseif name == "WindowManage" or name == "WindowMgr" then
        add(XaouWarp_GetGlobalSafe("WindowManage"))
        add(XaouWarp_GetGlobalSafe("WindowMgr"))
        add(XaouWarp_GetCSPathSafe("XiaWorld.WindowManage"))
        add(XaouWarp_GetCSPathSafe("XiaWorld.WindowMgr"))
        add(XaouWarp_GetCSPathSafe("WindowManage"))
        add(XaouWarp_GetCSPathSafe("WindowMgr"))
    end

    for _, obj in ipairs(candidates) do
        if obj ~= nil then return obj end
    end
    return nil
end

local function XaouWarp_GetFirstWorldFromPlaceV29(placeKey)
    local mgr = XaouWarp_GetObjV29("RPGMapMgr")
    local worlds = nil
    local first = nil
    local err = nil

    local function try(label, fn)
        if worlds ~= nil or first ~= nil then return end
        local ok, ret = pcall(fn)
        if ok then
            worlds = ret
        else
            err = tostring(label) .. " => " .. tostring(ret)
        end
    end

    if mgr ~= nil then
        local fn = nil
        pcall(function() fn = mgr.GetWorldsInPlace end)
        if fn ~= nil then
            try("dot(placeKey)", function() return fn(placeKey) end)
            try("colon(placeKey)", function() return fn(mgr, placeKey) end)
        end
    end

    pcall(function()
        if worlds ~= nil then
            if worlds[0] ~= nil then first = worlds[0] end
            if first == nil and worlds[1] ~= nil then first = worlds[1] end
            if first == nil then
                for _, v in pairs(worlds) do first = v; break end
            end
        end
    end)
    return first, worlds, err
end

local function XaouWarp_CallVariantsV29(obj, method, args)
    local fn = nil
    local getOk, getErr = pcall(function() if obj ~= nil then fn = obj[method] end end)
    if not getOk then return false, "get method err: " .. tostring(getErr) end
    if fn == nil then return false, "method nil" end

    args = args or {}
    local variants = {}
    local function add(label, f) table.insert(variants, {label, f}) end

    -- dot/static style
    add("dot()", function() return fn() end)
    if #args >= 1 then add("dot(a1)", function() return fn(args[1]) end) end
    if #args >= 2 then add("dot(a1,a2)", function() return fn(args[1], args[2]) end) end
    if #args >= 3 then add("dot(a1,a2,a3)", function() return fn(args[1], args[2], args[3]) end) end

    -- colon/instance style
    add("colon()", function() return fn(obj) end)
    if #args >= 1 then add("colon(a1)", function() return fn(obj, args[1]) end) end
    if #args >= 2 then add("colon(a1,a2)", function() return fn(obj, args[1], args[2]) end) end
    if #args >= 3 then add("colon(a1,a2,a3)", function() return fn(obj, args[1], args[2], args[3]) end) end

    local last = ""
    for _, v in ipairs(variants) do
        local ok, ret = pcall(v[2])
        if ok then return true, tostring(v[1]) .. " OK ret=" .. tostring(ret) end
        last = tostring(v[1]) .. " => " .. tostring(ret)
    end
    return false, last
end

function Xaou_WarpSystem.DebugRPGMapMgrV29(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local def = XaouWarp_GetPlaceDefForKey(key)
    local mgr = XaouWarp_GetObjV29("RPGMapMgr")
    local helper = XaouWarp_GetObjV29("WorldLuaHelper")
    local wnd = XaouWarp_GetObjV29("Wnd_SelectNpc4Map")
    local firstWorld, worlds, werr = XaouWarp_GetFirstWorldFromPlaceV29(key)

    local methods = {"EnterRPGWorld", "_EnterRPGWorld", "SwitchMap", "GetWorldsInPlace", "IsWorldUnlock", "HasUnlockWorldInPlace", "UnlockWorld"}
    local helperMethods = {"UnLockPlace", "CheckPlaceUnLock", "UnLockWorld", "GetPlaceName", "GetPlaceSchool", "GetFightMapPlace", "GetFightMapHelper", "GetFightMapSchoolID"}
    local wndMethods = {"ShowPlace", "SelectPlace", "ClickPlace", "ClickYes", "EnterPlace", "EnterWorld", "ClickWorld", "SelectWorld", "GetWorldsInPlace"}

    local lines = {"RPGMapMgr Probe v2.9", "PlaceKey = " .. tostring(key), "Def = " .. tostring(def ~= nil), ""}
    table.insert(lines, "RPGMapMgr = " .. tostring(mgr ~= nil))
    table.insert(lines, "  method = " .. tostring(XaouWarp_ScanMethods(mgr, methods)))
    table.insert(lines, "WorldLuaHelper = " .. tostring(helper ~= nil))
    table.insert(lines, "  method = " .. tostring(XaouWarp_ScanMethods(helper, helperMethods)))
    table.insert(lines, "Wnd_SelectNpc4Map = " .. tostring(wnd ~= nil))
    table.insert(lines, "  method = " .. tostring(XaouWarp_ScanMethods(wnd, wndMethods)))
    table.insert(lines, "")
    table.insert(lines, "WorldsInPlace = " .. tostring(worlds ~= nil))
    table.insert(lines, "FirstWorld = " .. XaouWarp_ShortObj(firstWorld))
    if werr ~= nil then table.insert(lines, "GetWorlds err = " .. tostring(werr)) end
    table.insert(lines, "")
    table.insert(lines, "ถ้า FirstWorld มีค่า ให้ลองปุ่ม Test RPGMapMgr ต่อ")
    XaouWarp_Msg(table.concat(lines, "\n"), "RPGMapMgr")
end

function Xaou_WarpSystem.TestWorldLuaHelperV29(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local helper = XaouWarp_GetObjV29("WorldLuaHelper")
    local firstWorld = XaouWarp_GetFirstWorldFromPlaceV29(key)
    local lines = {"WorldLuaHelper Test v2.9", "PlaceKey = " .. tostring(key), "Helper = " .. tostring(helper ~= nil), "FirstWorld = " .. XaouWarp_ShortObj(firstWorld), ""}

    local tests = {
        {"GetPlaceName", {key}},
        {"GetPlaceSchool", {key}},
        {"CheckPlaceUnLock", {key}},
        {"UnLockPlace", {key}},
    }
    if firstWorld ~= nil then
        table.insert(tests, {"UnLockWorld", {firstWorld}})
        table.insert(tests, {"GetFightMapPlace", {firstWorld}})
        table.insert(tests, {"GetFightMapHelper", {firstWorld}})
        table.insert(tests, {"GetFightMapSchoolID", {firstWorld}})
    end

    for _, t in ipairs(tests) do
        local ok, msg = XaouWarp_CallVariantsV29(helper, t[1], t[2])
        table.insert(lines, tostring(t[1]) .. " -> " .. (ok and "OK" or "ERR"))
        table.insert(lines, "  " .. tostring(msg))
        if #lines > 18 then break end
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "WorldLuaHelper")
end

function Xaou_WarpSystem.TestRPGMapMgrV29(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local mgr = XaouWarp_GetObjV29("RPGMapMgr")
    local def = XaouWarp_GetPlaceDefForKey(key)
    local firstWorld, worlds, werr = XaouWarp_GetFirstWorldFromPlaceV29(key)
    local lines = {"RPGMapMgr Invoke v2.9", "PlaceKey = " .. tostring(key), "RPGMapMgr = " .. tostring(mgr ~= nil), "Worlds = " .. tostring(worlds ~= nil), "FirstWorld = " .. XaouWarp_ShortObj(firstWorld), ""}
    if werr ~= nil then table.insert(lines, "GetWorlds err = " .. tostring(werr)) end

    local tests = {
        {"GetWorldsInPlace", {key}},
        {"HasUnlockWorldInPlace", {key}},
        {"IsWorldUnlock", {firstWorld or key}},
        {"UnlockWorld", {firstWorld or key}},
        {"SwitchMap", {firstWorld or key}},
        {"EnterRPGWorld", {firstWorld or key}},
        {"_EnterRPGWorld", {firstWorld or key}},
    }

    for _, t in ipairs(tests) do
        local ok, msg = XaouWarp_CallVariantsV29(mgr, t[1], t[2])
        table.insert(lines, tostring(t[1]) .. " -> " .. (ok and "OK" or "ERR"))
        table.insert(lines, "  " .. tostring(msg))
        if ok and (t[1] == "EnterRPGWorld" or t[1] == "_EnterRPGWorld" or t[1] == "SwitchMap") then
            table.insert(lines, "")
            table.insert(lines, "ถ้าแผนที่เปลี่ยน/โหลดฉาก แสดงว่าเจอคำสั่งเข้าแผนที่แล้ว")
            XaouWarp_Msg(table.concat(lines, "\n"), "RPGMapMgr")
            return true
        end
        if #lines > 20 then break end
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "RPGMapMgr")
    return false
end

function Xaou_WarpSystem.TestSelectNpc4MapV29(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local wnd = XaouWarp_GetObjV29("Wnd_SelectNpc4Map")
    local firstWorld = XaouWarp_GetFirstWorldFromPlaceV29(key)
    local lines = {"Wnd_SelectNpc4Map Test v2.9", "PlaceKey = " .. tostring(key), "Wnd = " .. tostring(wnd ~= nil), "FirstWorld = " .. XaouWarp_ShortObj(firstWorld), ""}

    local tests = {
        {"ShowPlace", {key}},
        {"SelectPlace", {key}},
        {"ClickPlace", {key}},
        {"GetWorldsInPlace", {key}},
    }
    if firstWorld ~= nil then
        table.insert(tests, {"SelectWorld", {firstWorld}})
        table.insert(tests, {"ClickWorld", {firstWorld}})
    end
    table.insert(tests, {"ClickYes", {}})
    table.insert(tests, {"EnterPlace", {key}})
    if firstWorld ~= nil then table.insert(tests, {"EnterWorld", {firstWorld}}) end

    for _, t in ipairs(tests) do
        local ok, msg = XaouWarp_CallVariantsV29(wnd, t[1], t[2])
        table.insert(lines, tostring(t[1]) .. " -> " .. (ok and "OK" or "ERR"))
        table.insert(lines, "  " .. tostring(msg))
        if ok and (t[1] == "ClickYes" or t[1] == "EnterPlace" or t[1] == "EnterWorld") then
            table.insert(lines, "")
            table.insert(lines, "ถ้าเปิดหน้าต่างเลือก NPC/เข้าแมพ แสดงว่าเส้นทางนี้ใช่")
            XaouWarp_Msg(table.concat(lines, "\n"), "Wnd_SelectNpc4Map")
            return true
        end
        if #lines > 20 then break end
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "Wnd_SelectNpc4Map")
    return false
end

-- override tester v2.9: เพิ่ม action ชุด RPGMapMgr โดยไม่ลบของเดิม
local Xaou_Old_TestTravelApi_v29 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "rpg_probe" then return Xaou_WarpSystem.DebugRPGMapMgrV29(keyword) end
    if action == "test_helper_v29" then return Xaou_WarpSystem.TestWorldLuaHelperV29(keyword) end
    if action == "test_rpg_v29" then return Xaou_WarpSystem.TestRPGMapMgrV29(keyword) end
    if action == "test_wndmap_v29" then return Xaou_WarpSystem.TestSelectNpc4MapV29(keyword) end
    if Xaou_Old_TestTravelApi_v29 ~= nil then return Xaou_Old_TestTravelApi_v29(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end

--------------------------------------------------
-- Xaou_009 Warp System v3.0 patch
-- Instance Finder + RPGMapMgr Target Invoke
-- จุดประสงค์: แก้ปัญหา Non-static method requires a target
--------------------------------------------------

local function XaouWarp_AddUniqueV30(list, label, obj)
    if obj == nil then return end
    local s = tostring(obj)
    for _, it in ipairs(list) do
        if tostring(it.obj) == s then return end
    end
    table.insert(list, {label = tostring(label or "?"), obj = obj})
end

local function XaouWarp_GetFieldV30(obj, field)
    local v = nil
    pcall(function() if obj ~= nil then v = obj[field] end end)
    return v
end

local function XaouWarp_GetInstanceCandidatesV30()
    local list = {}
    local bases = {
        {"RPGMapMgr", XaouWarp_GetGlobalSafe("RPGMapMgr")},
        {"CS.XiaWorld.RPGMapMgr", XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr")},
        {"WorldMapMgr", XaouWarp_GetGlobalSafe("WorldMapMgr")},
        {"WorldMapMgr.Instance", XaouWarp_GetFieldV30(XaouWarp_GetGlobalSafe("WorldMapMgr"), "Instance")},
        {"MapMgr", XaouWarp_GetGlobalSafe("MapMgr")},
        {"GameMain", XaouWarp_GetGlobalSafe("GameMain")},
        {"GameMain.Instance", XaouWarp_GetFieldV30(XaouWarp_GetGlobalSafe("GameMain"), "Instance")},
        {"World", XaouWarp_GetGlobalSafe("World") or XaouWarp_GetGlobalSafe("world")},
        {"Map", XaouWarp_GetGlobalSafe("Map")},
    }
    local instNames = {"Instance", "Inst", "instance", "ins", "m_Instance", "Mgr", "mgr", "RPGMapMgr", "rpgMapMgr", "MapMgr", "mapMgr", "WorldMapMgr", "worldMapMgr"}
    for _, b in ipairs(bases) do
        XaouWarp_AddUniqueV30(list, b[1], b[2])
        for _, f in ipairs(instNames) do
            local v = XaouWarp_GetFieldV30(b[2], f)
            XaouWarp_AddUniqueV30(list, b[1] .. "." .. f, v)
        end
    end
    -- บางเวอร์ชันมี singleton เป็น method
    local callNames = {"GetInstance", "get_Instance", "GetMgr", "GetRPGMapMgr"}
    for _, b in ipairs(bases) do
        for _, m in ipairs(callNames) do
            local fn = XaouWarp_GetFieldV30(b[2], m)
            if fn ~= nil then
                local ok, ret = pcall(function() return fn() end)
                if ok then XaouWarp_AddUniqueV30(list, b[1] .. ":" .. m .. "()", ret) end
                ok, ret = pcall(function() return fn(b[2]) end)
                if ok then XaouWarp_AddUniqueV30(list, b[1] .. "." .. m .. "(self)", ret) end
            end
        end
    end
    return list
end

function Xaou_WarpSystem.DebugRPGInstanceFinderV30(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local list = XaouWarp_GetInstanceCandidatesV30()
    local methods = {"GetWorldsInPlace", "EnterRPGWorld", "SwitchMap", "IsWorldUnlock", "HasUnlockWorldInPlace", "UnlockWorld"}
    local lines = {"RPGMapMgr Instance Finder v3.0", "PlaceKey = " .. tostring(key), "จำนวน candidates = " .. tostring(#list), ""}
    local shown = 0
    for _, it in ipairs(list) do
        local found = XaouWarp_ScanMethods(it.obj, methods)
        local fields = XaouWarp_ReadSomeFields(it.obj)
        table.insert(lines, tostring(it.label) .. " = " .. XaouWarp_ShortObj(it.obj))
        table.insert(lines, "  field = " .. tostring(fields))
        table.insert(lines, "  method = " .. tostring(found))
        shown = shown + 1
        if shown >= 8 then break end
    end
    table.insert(lines, "")
    table.insert(lines, "ถ้ามี method GetWorldsInPlace บน candidate ไหน ให้กด Test Target Invoke v3.0 ต่อ")
    XaouWarp_Msg(table.concat(lines, "\n"), "RPG Instance")
end

local function XaouWarp_TryGetWorldsWithTargetV30(target, key)
    local classObj = XaouWarp_GetGlobalSafe("RPGMapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr")
    local methods = {}
    local function add(label, fn) if fn ~= nil then table.insert(methods, {label, fn}) end end
    add("target.GetWorldsInPlace", XaouWarp_GetFieldV30(target, "GetWorldsInPlace"))
    add("class.GetWorldsInPlace", XaouWarp_GetFieldV30(classObj, "GetWorldsInPlace"))

    local last = nil
    for _, m in ipairs(methods) do
        local fn = m[2]
        local tries = {
            {m[1] .. "(key)", function() return fn(key) end},
            {m[1] .. "(target,key)", function() return fn(target, key) end},
            {m[1] .. "(target,key,true)", function() return fn(target, key, true) end},
        }
        for _, t in ipairs(tries) do
            local ok, ret = pcall(t[2])
            if ok then return true, t[1], ret end
            last = t[1] .. " => " .. tostring(ret)
        end
    end
    return false, tostring(last or "no method"), nil
end

local function XaouWarp_FirstFromWorldsV30(worlds)
    local first = nil
    pcall(function()
        if worlds ~= nil then
            if worlds[0] ~= nil then first = worlds[0] end
            if first == nil and worlds[1] ~= nil then first = worlds[1] end
            if first == nil then for _, v in pairs(worlds) do first = v; break end end
        end
    end)
    return first
end

function Xaou_WarpSystem.TestRPGTargetInvokeV30(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local list = XaouWarp_GetInstanceCandidatesV30()
    local lines = {"RPGMapMgr Target Invoke v3.0", "PlaceKey = " .. tostring(key), "แก้ปัญหา Non-static method requires a target", ""}
    local foundWorlds = nil
    local foundTarget = nil
    local firstWorld = nil
    local tried = 0

    for _, it in ipairs(list) do
        tried = tried + 1
        local ok, label, worlds = XaouWarp_TryGetWorldsWithTargetV30(it.obj, key)
        table.insert(lines, tostring(it.label) .. " -> " .. (ok and "OK" or "ERR"))
        table.insert(lines, "  " .. tostring(label))
        if ok then
            foundWorlds = worlds
            foundTarget = it.obj
            firstWorld = XaouWarp_FirstFromWorldsV30(worlds)
            table.insert(lines, "  Worlds = " .. XaouWarp_ShortObj(worlds))
            table.insert(lines, "  FirstWorld = " .. XaouWarp_ShortObj(firstWorld))
            break
        end
        if tried >= 8 then break end
    end

    if firstWorld == nil then
        table.insert(lines, "")
        table.insert(lines, "ยังไม่ได้ FirstWorld / Target ที่ใช้ได้")
        XaouWarp_Msg(table.concat(lines, "\n"), "RPG Target")
        return false
    end

    local classObj = XaouWarp_GetGlobalSafe("RPGMapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr")
    local enterTests = {"IsWorldUnlock", "UnlockWorld", "EnterRPGWorld", "_EnterRPGWorld", "SwitchMap"}
    table.insert(lines, "")
    table.insert(lines, "ลองเรียก world action:")
    for _, m in ipairs(enterTests) do
        local fn = XaouWarp_GetFieldV30(foundTarget, m) or XaouWarp_GetFieldV30(classObj, m)
        if fn ~= nil then
            local ok, ret = pcall(function() return fn(foundTarget, firstWorld) end)
            if not ok then ok, ret = pcall(function() return fn(firstWorld) end) end
            table.insert(lines, tostring(m) .. " -> " .. (ok and "OK" or "ERR"))
            table.insert(lines, "  " .. tostring(ret))
            if ok and (m == "EnterRPGWorld" or m == "_EnterRPGWorld" or m == "SwitchMap") then
                table.insert(lines, "ถ้าโหลดฉาก/เปลี่ยนแผนที่ แปลว่าเจอแล้ว")
                break
            end
        end
        if #lines > 20 then break end
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "RPG Target")
    return true
end

function Xaou_WarpSystem.TestWorldLuaGlobalV30(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local lines = {"WorldLuaHelper Global Probe v3.0", "PlaceKey = " .. tostring(key), "ลองชื่อ global/wrapper ที่อาจถูก register", ""}
    local names = {"WorldLuaHelper", "WorldLua", "worldLua", "LuaHelper", "World", "world", "me"}
    local methods = {"GetPlaceName", "GetPlaceSchool", "CheckPlaceUnLock", "UnLockPlace", "UnLockWorld"}
    for _, n in ipairs(names) do
        local obj = XaouWarp_GetGlobalSafe(n)
        table.insert(lines, tostring(n) .. " = " .. tostring(obj ~= nil))
        if obj ~= nil then
            table.insert(lines, "  method = " .. tostring(XaouWarp_ScanMethods(obj, methods)))
            for _, m in ipairs(methods) do
                local fn = XaouWarp_GetFieldV30(obj, m)
                if fn ~= nil then
                    local ok, ret = pcall(function() return fn(key) end)
                    if not ok then ok, ret = pcall(function() return fn(obj, key) end) end
                    table.insert(lines, "  " .. m .. " -> " .. (ok and "OK" or "ERR") .. " " .. XaouWarp_ShortObj(ret))
                    break
                end
            end
        end
        if #lines > 18 then break end
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "WorldLua Global")
end

-- override tester v3.0
local Xaou_Old_TestTravelApi_v30 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "rpg_instance_v30" then return Xaou_WarpSystem.DebugRPGInstanceFinderV30(keyword) end
    if action == "rpg_target_v30" then return Xaou_WarpSystem.TestRPGTargetInvokeV30(keyword) end
    if action == "worldlua_global_v30" then return Xaou_WarpSystem.TestWorldLuaGlobalV30(keyword) end
    if Xaou_Old_TestTravelApi_v30 ~= nil then return Xaou_Old_TestTravelApi_v30(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end

--------------------------------------------------
-- Xaou_009 Warp System v3.1 patch
-- Place Object -> GetWorldsInPlace / EnterRPGWorld
-- จุดประสงค์: ใช้ Place object จริงแทน PlaceKey string
--------------------------------------------------

XaouWarp_LastRPGTarget_v31 = XaouWarp_LastRPGTarget_v31 or nil
XaouWarp_LastWorlds_v31 = XaouWarp_LastWorlds_v31 or nil
XaouWarp_LastFirstWorld_v31 = XaouWarp_LastFirstWorld_v31 or nil
XaouWarp_LastPlaceObj_v31 = XaouWarp_LastPlaceObj_v31 or nil
XaouWarp_LastCallLabel_v31 = XaouWarp_LastCallLabel_v31 or nil

local function XaouWarp_FieldV31(obj, field)
    local v = nil
    pcall(function() if obj ~= nil then v = obj[field] end end)
    return v
end

local function XaouWarp_AddUniqueObjV31(list, label, obj)
    if obj == nil then return end
    local s = tostring(obj)
    for _, it in ipairs(list) do
        if tostring(it.obj) == s then return end
    end
    table.insert(list, {label=tostring(label or "?"), obj=obj})
end

local function XaouWarp_GetRPGTargetsV31()
    local list = {}
    local bases = {
        {"RPGMapMgr", XaouWarp_GetGlobalSafe("RPGMapMgr")},
        {"RPGMapMgr.Instance", XaouWarp_FieldV31(XaouWarp_GetGlobalSafe("RPGMapMgr"), "Instance")},
        {"CS.XiaWorld.RPGMapMgr", XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr")},
        {"CS.XiaWorld.RPGMapMgr.Instance", XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr.Instance")},
        {"WorldMapMgr", XaouWarp_GetGlobalSafe("WorldMapMgr")},
        {"WorldMapMgr.Instance", XaouWarp_FieldV31(XaouWarp_GetGlobalSafe("WorldMapMgr"), "Instance")},
        {"WorldLua", XaouWarp_GetGlobalSafe("WorldLua")},
        {"world", XaouWarp_GetGlobalSafe("world")},
        {"World", XaouWarp_GetGlobalSafe("World")},
    }
    local fields = {"Instance","Inst","Mgr","mgr","RPGMapMgr","rpgMapMgr","MapMgr","mapMgr"}
    for _, b in ipairs(bases) do
        XaouWarp_AddUniqueObjV31(list, b[1], b[2])
        for _, f in ipairs(fields) do
            XaouWarp_AddUniqueObjV31(list, b[1].."."..f, XaouWarp_FieldV31(b[2], f))
        end
    end
    return list
end

local function XaouWarp_GetPlaceObjectsV31(key)
    local list = {}
    local wm = XaouWarp_GetGlobalSafe("WorldMapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.WorldMapMgr")
    local wmInst = XaouWarp_FieldV31(wm, "Instance")
    local pm = XaouWarp_GetGlobalSafe("PlacesMgr") or XaouWarp_GetCSPathSafe("XiaWorld.PlacesMgr")
    local pmInst = XaouWarp_FieldV31(pm, "Instance")

    local function addDeep(label, obj)
        XaouWarp_AddUniqueObjV31(list, label, obj)
        XaouWarp_AddUniqueObjV31(list, label..".Place", XaouWarp_FieldV31(obj, "Place"))
        XaouWarp_AddUniqueObjV31(list, label..".Def", XaouWarp_FieldV31(obj, "Def"))
        XaouWarp_AddUniqueObjV31(list, label..".Data", XaouWarp_FieldV31(obj, "Data"))
        XaouWarp_AddUniqueObjV31(list, label..".PlaceData", XaouWarp_FieldV31(obj, "PlaceData"))
        XaouWarp_AddUniqueObjV31(list, label..".World", XaouWarp_FieldV31(obj, "World"))
    end

    for _, owner in ipairs({{"WorldMapMgr", wm}, {"WorldMapMgr.Instance", wmInst}}) do
        for _, f in ipairs({"CurPlace","CurrentPlace","SelectedPlace","SelectPlace","Place","TargetPlace","curPlace","place"}) do
            addDeep(owner[1].."."..f, XaouWarp_FieldV31(owner[2], f))
        end
    end

    -- อ่านจาก PlacesMgr ด้วย key เผื่อ GetWorldsInPlace ต้องการ Def/Data
    for _, owner in ipairs({{"PlacesMgr", pm}, {"PlacesMgr.Instance", pmInst}}) do
        local obj = owner[2]
        if obj ~= nil then
            for _, m in ipairs({"GetPlaceDef","GetPlaceData","GetDef","GetData"}) do
                local fn = XaouWarp_FieldV31(obj, m)
                if fn ~= nil then
                    local ok, ret = pcall(function() return fn(key) end)
                    if not ok then ok, ret = pcall(function() return fn(obj, key) end) end
                    if ok then addDeep(owner[1]..":"..m.."("..tostring(key)..")", ret) end
                end
            end
        end
    end

    -- ใส่ key string ไว้ท้ายสุดเพื่อเทียบผล
    XaouWarp_AddUniqueObjV31(list, "PlaceKey string", key)
    return list
end

local function XaouWarp_FirstWorldV31(worlds)
    local first = nil
    pcall(function()
        if worlds ~= nil then
            if worlds[0] ~= nil then first = worlds[0] end
            if first == nil and worlds[1] ~= nil then first = worlds[1] end
            if first == nil then
                local cnt = 0
                for _, v in pairs(worlds) do
                    cnt = cnt + 1
                    if first == nil then first = v end
                    if cnt > 20 then break end
                end
            end
        end
    end)
    return first
end

local function XaouWarp_TryWorldsV31(target, placeObj)
    local classObj = XaouWarp_GetGlobalSafe("RPGMapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr")
    local fns = {}
    local function add(label, fn) if fn ~= nil then table.insert(fns, {label=label, fn=fn}) end end
    add("target.GetWorldsInPlace", XaouWarp_FieldV31(target, "GetWorldsInPlace"))
    add("class.GetWorldsInPlace", XaouWarp_FieldV31(classObj, "GetWorldsInPlace"))

    local last = nil
    for _, item in ipairs(fns) do
        local fn = item.fn
        local tries = {
            {item.label.."(placeObj)", function() return fn(placeObj) end},
            {item.label.."(target,placeObj)", function() return fn(target, placeObj) end},
            {item.label.."(target,placeObj,true)", function() return fn(target, placeObj, true) end},
            {item.label.."(placeObj,true)", function() return fn(placeObj, true) end},
        }
        for _, t in ipairs(tries) do
            local ok, ret = pcall(t[2])
            if ok and ret ~= nil then return true, t[1], ret end
            if ok and ret == nil then last = t[1] .. " => nil" else last = t[1] .. " => " .. tostring(ret) end
        end
    end
    return false, tostring(last or "no GetWorldsInPlace"), nil
end

function Xaou_WarpSystem.TestRPGPlaceObjV31(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local targets = XaouWarp_GetRPGTargetsV31()
    local places = XaouWarp_GetPlaceObjectsV31(key)
    local lines = {"RPG PlaceObj Test v3.1", "PlaceKey = "..tostring(key), "ลองส่ง Place object เข้า GetWorldsInPlace", ""}

    table.insert(lines, "Place candidates = "..tostring(#places))
    for i=1, math.min(#places, 6) do
        table.insert(lines, "  "..tostring(i)..") "..places[i].label.." = "..XaouWarp_ShortObj(places[i].obj))
    end
    table.insert(lines, "")

    XaouWarp_LastRPGTarget_v31 = nil
    XaouWarp_LastWorlds_v31 = nil
    XaouWarp_LastFirstWorld_v31 = nil
    XaouWarp_LastPlaceObj_v31 = nil
    XaouWarp_LastCallLabel_v31 = nil

    local attempts = 0
    for _, tg in ipairs(targets) do
        local has = tostring(XaouWarp_ScanMethods(tg.obj, {"GetWorldsInPlace"}))
        if has ~= "ไม่พบ candidate method" then
            table.insert(lines, "Target: "..tg.label.." method="..has)
            for _, po in ipairs(places) do
                attempts = attempts + 1
                local ok, label, worlds = XaouWarp_TryWorldsV31(tg.obj, po.obj)
                table.insert(lines, "  "..po.label.." -> "..(ok and "OK" or "nil/ERR"))
                table.insert(lines, "    "..tostring(label))
                if ok then
                    local first = XaouWarp_FirstWorldV31(worlds)
                    table.insert(lines, "    Worlds="..XaouWarp_ShortObj(worlds))
                    table.insert(lines, "    FirstWorld="..XaouWarp_ShortObj(first))
                    XaouWarp_LastRPGTarget_v31 = tg.obj
                    XaouWarp_LastWorlds_v31 = worlds
                    XaouWarp_LastFirstWorld_v31 = first
                    XaouWarp_LastPlaceObj_v31 = po.obj
                    XaouWarp_LastCallLabel_v31 = tg.label.." / "..po.label.." / "..label
                    table.insert(lines, "")
                    table.insert(lines, "เจอ Worlds แล้ว! ต่อไปกด Test Enter World v3.1")
                    XaouWarp_Msg(table.concat(lines, "\n"), "RPG PlaceObj")
                    return true
                end
                if attempts >= 12 then break end
            end
        end
        if attempts >= 12 then break end
    end

    table.insert(lines, "")
    table.insert(lines, "ยังไม่เจอ Worlds จาก Place object ชุดนี้")
    XaouWarp_Msg(table.concat(lines, "\n"), "RPG PlaceObj")
    return false
end

local function XaouWarp_TryEnterRPGV31(target, world, placeObj)
    local classObj = XaouWarp_GetGlobalSafe("RPGMapMgr") or XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr")
    local methods = {"IsWorldUnlock", "UnlockWorld", "EnterRPGWorld", "_EnterRPGWorld", "SwitchMap"}
    local lines = {}
    for _, m in ipairs(methods) do
        local fn = XaouWarp_FieldV31(target, m) or XaouWarp_FieldV31(classObj, m)
        if fn ~= nil then
            local tries = {
                {m.."(target,world)", function() return fn(target, world) end},
                {m.."(world)", function() return fn(world) end},
                {m.."(target,placeObj,world)", function() return fn(target, placeObj, world) end},
                {m.."(target,world,true)", function() return fn(target, world, true) end},
                {m.."(target,placeObj)", function() return fn(target, placeObj) end},
            }
            for _, t in ipairs(tries) do
                local ok, ret = pcall(t[2])
                table.insert(lines, t[1].." -> "..(ok and "OK" or "ERR"))
                table.insert(lines, "  "..XaouWarp_ShortObj(ret))
                if ok and (m == "EnterRPGWorld" or m == "_EnterRPGWorld" or m == "SwitchMap") then
                    return true, lines
                end
                if #lines >= 16 then return false, lines end
            end
        end
    end
    return false, lines
end

function Xaou_WarpSystem.TestEnterWorldV31(keyword)
    local lines = {"Enter FirstWorld Test v3.1", "ใช้ผลจากปุ่ม RPG PlaceObj Test v3.1", ""}
    local target = XaouWarp_LastRPGTarget_v31
    local world = XaouWarp_LastFirstWorld_v31
    local placeObj = XaouWarp_LastPlaceObj_v31
    table.insert(lines, "LastCall = "..tostring(XaouWarp_LastCallLabel_v31))
    table.insert(lines, "Target = "..XaouWarp_ShortObj(target))
    table.insert(lines, "FirstWorld = "..XaouWarp_ShortObj(world))
    table.insert(lines, "PlaceObj = "..XaouWarp_ShortObj(placeObj))
    table.insert(lines, "")

    if target == nil or world == nil then
        table.insert(lines, "ยังไม่มี FirstWorld")
        table.insert(lines, "ให้กด RPG PlaceObj Test v3.1 ก่อน")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter World")
        return false
    end

    local ok, out = XaouWarp_TryEnterRPGV31(target, world, placeObj)
    for _, s in ipairs(out) do table.insert(lines, s) end
    if ok then table.insert(lines, "ถ้าเปลี่ยนแผนที่/โหลดฉาก แปลว่าเจอทางเข้าแล้ว") end
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter World")
    return ok
end

function Xaou_WarpSystem.WorldLuaUnlockV31(keyword)
    local key = XaouWarp_ResolveTestPlaceKey(keyword)
    local obj = XaouWarp_GetGlobalSafe("WorldLua") or XaouWarp_GetGlobalSafe("world") or XaouWarp_GetGlobalSafe("World")
    local lines = {"WorldLua Unlock Test v3.1", "PlaceKey = "..tostring(key), ""}
    if obj == nil then
        table.insert(lines, "ไม่พบ WorldLua/world")
        XaouWarp_Msg(table.concat(lines,"\n"), "WorldLua")
        return false
    end
    for _, m in ipairs({"CheckPlaceUnLock","CheckPlaceUnlock","UnLockPlace","UnlockPlace","GetPlaceName","GetPlaceSchool"}) do
        local fn = XaouWarp_FieldV31(obj, m)
        if fn ~= nil then
            local ok, ret = pcall(function() return fn(key) end)
            if not ok then ok, ret = pcall(function() return fn(obj, key) end) end
            table.insert(lines, m.." -> "..(ok and "OK" or "ERR").." "..XaouWarp_ShortObj(ret))
        end
    end
    XaouWarp_Msg(table.concat(lines,"\n"), "WorldLua")
    return true
end

-- override tester v3.1
local Xaou_Old_TestTravelApi_v31 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "rpg_placeobj_v31" then return Xaou_WarpSystem.TestRPGPlaceObjV31(keyword) end
    if action == "enter_world_v31" then return Xaou_WarpSystem.TestEnterWorldV31(keyword) end
    if action == "worldlua_unlock_v31" then return Xaou_WarpSystem.WorldLuaUnlockV31(keyword) end
    if Xaou_Old_TestTravelApi_v31 ~= nil then return Xaou_Old_TestTravelApi_v31(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end

-- =========================================================
-- Xaou Warp v3.2 - Runtime Object Walker / FirstWorld finder
-- เพิ่มโดย Xaou_009 debug line: วนหา object ที่ GetWorldsInPlace ต้องการจริง
-- =========================================================
Xaou_WarpSystem = Xaou_WarpSystem or {}

local XaouWarp_LastRPGTarget_v32 = nil
local XaouWarp_LastWorlds_v32 = nil
local XaouWarp_LastFirstWorld_v32 = nil
local XaouWarp_LastPlaceObj_v32 = nil
local XaouWarp_LastCallLabel_v32 = nil

local function XaouWarp_FieldV32(obj, name)
    if obj == nil then return nil end
    local ok, ret = pcall(function() return obj[name] end)
    if ok then return ret end
    return nil
end

local function XaouWarp_AddObjV32(list, seen, label, obj)
    if obj == nil then return end
    local key = tostring(obj)
    if seen[key] then return end
    seen[key] = true
    table.insert(list, {label=label, obj=obj})
end

local function XaouWarp_TryFieldPathV32(root, rootLabel, path, list, seen)
    local obj = root
    local label = rootLabel
    if obj == nil then return end
    for _, f in ipairs(path) do
        obj = XaouWarp_FieldV32(obj, f)
        label = label .. "." .. f
        if obj == nil then return end
    end
    XaouWarp_AddObjV32(list, seen, label, obj)
end

local function XaouWarp_GetRPGTargetsV32()
    local list, seen = {}, {}
    local candidates = {
        {"RPGMapMgr", XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("RPGMapMgr") or nil},
        {"rpgMapMgr", XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("rpgMapMgr") or nil},
        {"RPGMapMgrMgr", XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("RPGMapMgrMgr") or nil},
        {"CS.XiaWorld.RPGMapMgr", XaouWarp_GetCSPathSafe and XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr") or nil},
    }
    for _, it in ipairs(candidates) do
        local label, obj = it[1], it[2]
        XaouWarp_AddObjV32(list, seen, label, obj)
        XaouWarp_AddObjV32(list, seen, label..".Instance", XaouWarp_FieldV32(obj, "Instance"))
        XaouWarp_AddObjV32(list, seen, label..".instance", XaouWarp_FieldV32(obj, "instance"))
        XaouWarp_AddObjV32(list, seen, label..".Ins", XaouWarp_FieldV32(obj, "Ins"))
    end
    return list
end

local function XaouWarp_GetPlaceCandidatesV32(keyword)
    local key = XaouWarp_ResolveTestPlaceKey and XaouWarp_ResolveTestPlaceKey(keyword) or tostring(keyword or "Place_BigBamboo")
    local list, seen = {}, {}
    local wmm = (XaouWarp_GetGlobalSafe and (XaouWarp_GetGlobalSafe("WorldMapMgr") or XaouWarp_GetGlobalSafe("worldMapMgr"))) or nil
    local wmmcs = XaouWarp_GetCSPathSafe and XaouWarp_GetCSPathSafe("XiaWorld.WorldMapMgr") or nil
    local roots = {
        {"WorldMapMgr", wmm},
        {"WorldMapMgr.Instance", XaouWarp_FieldV32(wmm, "Instance")},
        {"CS.WorldMapMgr", wmmcs},
        {"CS.WorldMapMgr.Instance", XaouWarp_FieldV32(wmmcs, "Instance")},
    }

    local baseFields = {"CurPlace", "CurrentPlace", "SelectPlace", "SelectedPlace", "Place", "place", "curPlace", "currentPlace"}
    local subPaths = {
        {},
        {"Place"}, {"Def"}, {"Data"}, {"PlaceData"}, {"World"}, {"Region"},
        {"Place", "World"}, {"Place", "Data"}, {"Place", "Def"}, {"Place", "PlaceData"},
        {"Def", "World"}, {"Data", "World"}, {"PlaceData", "World"},
    }

    for _, r in ipairs(roots) do
        for _, bf in ipairs(baseFields) do
            for _, sp in ipairs(subPaths) do
                local path = {bf}
                for _, x in ipairs(sp) do table.insert(path, x) end
                XaouWarp_TryFieldPathV32(r[2], r[1], path, list, seen)
            end
        end
    end

    -- จาก PlacesMgr: เผื่อ GetWorldsInPlace ต้องการ PlaceDef/PlaceData โดยตรง
    local pm = (XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("PlacesMgr")) or nil
    local pmcs = XaouWarp_GetCSPathSafe and XaouWarp_GetCSPathSafe("XiaWorld.PlacesMgr") or nil
    for _, it in ipairs({{"PlacesMgr", pm}, {"PlacesMgr.Instance", XaouWarp_FieldV32(pm,"Instance")}, {"CS.PlacesMgr", pmcs}, {"CS.PlacesMgr.Instance", XaouWarp_FieldV32(pmcs,"Instance")}}) do
        local label, obj = it[1], it[2]
        for _, m in ipairs({"GetPlaceDef", "GetPlaceData", "GetDef", "GetData"}) do
            local fn = XaouWarp_FieldV32(obj, m)
            if fn ~= nil then
                local ok, ret = pcall(function() return fn(key) end)
                if (not ok) or ret == nil then ok, ret = pcall(function() return fn(obj, key) end) end
                if ok and ret ~= nil then XaouWarp_AddObjV32(list, seen, label..":"..m.."("..tostring(key)..")", ret) end
            end
        end
    end

    -- เก็บ string key ไว้ท้ายสุดเพื่อเทียบ
    XaouWarp_AddObjV32(list, seen, "PlaceKey string", key)
    return key, list
end

local function XaouWarp_FirstWorldV32(worlds)
    local first = nil
    pcall(function()
        if worlds ~= nil then
            first = worlds.First or worlds.first or worlds[0] or worlds[1]
            if first == nil then
                local n = 0
                for _, v in pairs(worlds) do
                    n = n + 1
                    if first == nil then first = v end
                    if n >= 30 then break end
                end
            end
        end
    end)
    return first
end

local function XaouWarp_TryGetWorldsV32(target, placeObj)
    local fn = XaouWarp_FieldV32(target, "GetWorldsInPlace")
    if fn == nil then return false, "no GetWorldsInPlace", nil end
    local tries = {
        {"fn(target,obj)", function() return fn(target, placeObj) end},
        {"fn(target,obj,true)", function() return fn(target, placeObj, true) end},
        {"fn(obj)", function() return fn(placeObj) end},
        {"fn(obj,true)", function() return fn(placeObj, true) end},
    }
    local last = ""
    for _, t in ipairs(tries) do
        local ok, ret = pcall(t[2])
        if ok and ret ~= nil then return true, t[1], ret end
        if ok then
            last = t[1] .. " => nil"
        else
            last = t[1] .. " => " .. tostring(ret)
        end
    end
    return false, last, nil
end

function Xaou_WarpSystem.RPGObjectWalkerV32(keyword)
    local key, objs = XaouWarp_GetPlaceCandidatesV32(keyword)
    local targets = XaouWarp_GetRPGTargetsV32()
    local lines = {"Object Walker v3.2", "PlaceKey = "..tostring(key), "วนหา object ที่ GetWorldsInPlace รับได้", ""}
    table.insert(lines, "Targets = "..tostring(#targets).." | Objects = "..tostring(#objs))
    for i=1, math.min(#objs, 8) do
        table.insert(lines, tostring(i)..") "..objs[i].label.." = "..(XaouWarp_ShortObj and XaouWarp_ShortObj(objs[i].obj) or tostring(objs[i].obj)))
    end
    table.insert(lines, "")

    XaouWarp_LastRPGTarget_v32 = nil
    XaouWarp_LastWorlds_v32 = nil
    XaouWarp_LastFirstWorld_v32 = nil
    XaouWarp_LastPlaceObj_v32 = nil
    XaouWarp_LastCallLabel_v32 = nil

    local attempt = 0
    local nilCount, errCount = 0, 0
    for _, tg in ipairs(targets) do
        local fn = XaouWarp_FieldV32(tg.obj, "GetWorldsInPlace")
        if fn ~= nil then
            table.insert(lines, "Target: "..tg.label)
            for _, po in ipairs(objs) do
                attempt = attempt + 1
                local ok, label, worlds = XaouWarp_TryGetWorldsV32(tg.obj, po.obj)
                if ok then
                    local first = XaouWarp_FirstWorldV32(worlds)
                    table.insert(lines, "OK #"..attempt.." "..po.label)
                    table.insert(lines, "call = "..label)
                    table.insert(lines, "Worlds = "..(XaouWarp_ShortObj and XaouWarp_ShortObj(worlds) or tostring(worlds)))
                    table.insert(lines, "FirstWorld = "..(XaouWarp_ShortObj and XaouWarp_ShortObj(first) or tostring(first)))
                    XaouWarp_LastRPGTarget_v32 = tg.obj
                    XaouWarp_LastWorlds_v32 = worlds
                    XaouWarp_LastFirstWorld_v32 = first
                    XaouWarp_LastPlaceObj_v32 = po.obj
                    XaouWarp_LastCallLabel_v32 = tg.label.." / "..po.label.." / "..label
                    table.insert(lines, "")
                    table.insert(lines, "เจอ Worlds แล้ว! ต่อไปกด Test Enter World v3.2")
                    XaouWarp_Msg(table.concat(lines, "\n"), "Object Walker")
                    return true
                else
                    if string.find(tostring(label), "nil", 1, true) then nilCount = nilCount + 1 else errCount = errCount + 1 end
                    if attempt <= 10 then table.insert(lines, "#"..attempt.." "..po.label.." -> "..tostring(label)) end
                end
                if attempt >= 40 then break end
            end
        end
        if attempt >= 40 then break end
    end

    table.insert(lines, "")
    table.insert(lines, "ยังไม่เจอ Worlds")
    table.insert(lines, "attempt="..attempt.." nil="..nilCount.." err="..errCount)
    table.insert(lines, "ถ้าส่งรูปมา ขอให้เห็นบรรทัด error ช่วงท้ายด้วยจ้า")
    XaouWarp_Msg(table.concat(lines, "\n"), "Object Walker")
    return false
end

local function XaouWarp_TryEnterV32(target, world, placeObj)
    local lines = {}
    local methods = {"IsWorldUnlock", "UnlockWorld", "EnterRPGWorld", "_EnterRPGWorld", "SwitchMap"}
    for _, m in ipairs(methods) do
        local fn = XaouWarp_FieldV32(target, m)
        if fn ~= nil then
            local tries = {
                {m.."(target,world)", function() return fn(target, world) end},
                {m.."(target,world,true)", function() return fn(target, world, true) end},
                {m.."(world)", function() return fn(world) end},
                {m.."(target,placeObj,world)", function() return fn(target, placeObj, world) end},
                {m.."(target,placeObj)", function() return fn(target, placeObj) end},
            }
            for _, t in ipairs(tries) do
                local ok, ret = pcall(t[2])
                table.insert(lines, t[1].." -> "..(ok and "OK" or "ERR"))
                table.insert(lines, "  "..(XaouWarp_ShortObj and XaouWarp_ShortObj(ret) or tostring(ret)))
                if ok and (m == "EnterRPGWorld" or m == "_EnterRPGWorld" or m == "SwitchMap") then
                    return true, lines
                end
                if #lines >= 18 then return false, lines end
            end
        end
    end
    return false, lines
end

function Xaou_WarpSystem.TestEnterWorldV32(keyword)
    local lines = {"Enter World Test v3.2", "ใช้ผลจาก Object Walker v3.2", ""}
    table.insert(lines, "LastCall = "..tostring(XaouWarp_LastCallLabel_v32))
    table.insert(lines, "Target = "..(XaouWarp_ShortObj and XaouWarp_ShortObj(XaouWarp_LastRPGTarget_v32) or tostring(XaouWarp_LastRPGTarget_v32)))
    table.insert(lines, "FirstWorld = "..(XaouWarp_ShortObj and XaouWarp_ShortObj(XaouWarp_LastFirstWorld_v32) or tostring(XaouWarp_LastFirstWorld_v32)))
    table.insert(lines, "PlaceObj = "..(XaouWarp_ShortObj and XaouWarp_ShortObj(XaouWarp_LastPlaceObj_v32) or tostring(XaouWarp_LastPlaceObj_v32)))
    table.insert(lines, "")
    if XaouWarp_LastRPGTarget_v32 == nil or XaouWarp_LastFirstWorld_v32 == nil then
        table.insert(lines, "ยังไม่มี FirstWorld")
        table.insert(lines, "ให้กด Object Walker v3.2 ก่อน")
        XaouWarp_Msg(table.concat(lines,"\n"), "Enter World")
        return false
    end
    local ok, out = XaouWarp_TryEnterV32(XaouWarp_LastRPGTarget_v32, XaouWarp_LastFirstWorld_v32, XaouWarp_LastPlaceObj_v32)
    for _, s in ipairs(out) do table.insert(lines, s) end
    if ok then table.insert(lines, "ถ้าเกมโหลด/เปลี่ยนแผนที่ แปลว่าเข้าได้แล้ว") end
    XaouWarp_Msg(table.concat(lines,"\n"), "Enter World")
    return ok
end

-- override tester v3.2
local Xaou_Old_TestTravelApi_v32 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "rpg_object_walker_v32" then return Xaou_WarpSystem.RPGObjectWalkerV32(keyword) end
    if action == "enter_world_v32" then return Xaou_WarpSystem.TestEnterWorldV32(keyword) end
    if Xaou_Old_TestTravelApi_v32 ~= nil then return Xaou_Old_TestTravelApi_v32(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end

-- ============================================================
-- Xaou Warp v3.3 - World String Enumerator / EnterRPGWorld tester
-- ใช้ข้อมูลที่ยืนยันแล้ว:
--   GetWorldsInPlace(string place) -> List<string>
--   EnterRPGWorld(List<Npc> npcs, string world, string p)
-- ============================================================
local function XaouWarp_FieldV33(obj, name)
    local v = nil
    pcall(function() if obj ~= nil then v = obj[name] end end)
    return v
end

local function XaouWarp_AddUniqueTargetV33(list, label, obj)
    if obj == nil then return end
    for _, it in ipairs(list) do
        if it.obj == obj then return end
    end
    table.insert(list, {label = label, obj = obj})
end

local function XaouWarp_GetRPGTargetsV33()
    local list = {}
    local g = XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("RPGMapMgr") or nil
    local cs = XaouWarp_GetCSPathSafe and XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr") or nil
    XaouWarp_AddUniqueTargetV33(list, "RPGMapMgr", g)
    XaouWarp_AddUniqueTargetV33(list, "RPGMapMgr.Instance", XaouWarp_FieldV33(g, "Instance"))
    XaouWarp_AddUniqueTargetV33(list, "CS.XiaWorld.RPGMapMgr", cs)
    XaouWarp_AddUniqueTargetV33(list, "CS.XiaWorld.RPGMapMgr.Instance", XaouWarp_FieldV33(cs, "Instance"))
    -- เผื่อเกมผูก instance ไว้ชื่ออื่นใน global
    for _, nm in ipairs({"rpgMapMgr", "RPGMgr", "RpgMapMgr"}) do
        XaouWarp_AddUniqueTargetV33(list, nm, XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe(nm) or nil)
    end
    return list
end

local function XaouWarp_ListCountV33(list)
    local c = nil
    pcall(function() if list ~= nil and list.Count ~= nil then c = tonumber(list.Count) end end)
    pcall(function() if c == nil and list ~= nil and list.count ~= nil then c = tonumber(list.count) end end)
    if c ~= nil then return c end
    local n = 0
    pcall(function()
        if list ~= nil then
            for _, _ in pairs(list) do
                n = n + 1
                if n > 200 then break end
            end
        end
    end)
    return n
end

local function XaouWarp_GetListItemV33(list, idx)
    local v = nil
    pcall(function() if list ~= nil then v = list[idx] end end)
    pcall(function() if v == nil and list ~= nil and list.get_Item ~= nil then v = list:get_Item(idx) end end)
    pcall(function() if v == nil and list ~= nil and list.GetItem ~= nil then v = list:GetItem(idx) end end)
    return v
end

local function XaouWarp_CollectWorldStringsV33(worlds)
    local out, seen = {}, {}
    local function add(v)
        if v == nil then return end
        local s = tostring(v)
        if s == "" or s == "nil" then return end
        if seen[s] then return end
        seen[s] = true
        table.insert(out, s)
    end
    local count = XaouWarp_ListCountV33(worlds)
    if count ~= nil and count > 0 then
        for i = 0, math.min(count - 1, 30) do add(XaouWarp_GetListItemV33(worlds, i)) end
        for i = 1, math.min(count, 30) do add(XaouWarp_GetListItemV33(worlds, i)) end
    end
    pcall(function()
        if worlds ~= nil then
            local n = 0
            for _, v in pairs(worlds) do
                add(v)
                n = n + 1
                if n >= 30 then break end
            end
        end
    end)
    return out, count
end

local function XaouWarp_ResolvePlaceListV33(keyword)
    local first = XaouWarp_ResolveTestPlaceKey and XaouWarp_ResolveTestPlaceKey(keyword) or tostring(keyword or "")
    if first == nil or first == "" then first = "Place_BigBamboo" end
    local list, seen = {}, {}
    local function add(k)
        if k == nil then return end
        k = tostring(k)
        if k == "" or seen[k] then return end
        seen[k] = true
        table.insert(list, k)
    end
    add(first)
    -- ชุดที่ใช้เทียบเร็ว ไม่เยอะเกินไป
    for _, k in ipairs({
        "Place_BigBamboo", "Place_LongHu", "Place_KunLun", "Place_DanXia", "Place_JiuHua",
        "Place_HeHuan", "Place_WuDang", "Place_BaiMan", "Place_Desert", "Place_Snowfield"
    }) do add(k) end
    return list
end

local function XaouWarp_TryGetWorldsStringV33(target, placeKey)
    local fn = XaouWarp_FieldV33(target, "GetWorldsInPlace")
    if fn == nil then return false, "no GetWorldsInPlace", nil end
    local tries = {
        {"fn(place)", function() return fn(placeKey) end},
        {"fn(target,place)", function() return fn(target, placeKey) end},
        {"target:GetWorldsInPlace(place)", function() return target:GetWorldsInPlace(placeKey) end},
    }
    local last = ""
    for _, t in ipairs(tries) do
        local ok, ret = pcall(t[2])
        if ok and ret ~= nil then return true, t[1], ret end
        if ok then last = t[1] .. " => nil" else last = t[1] .. " => " .. tostring(ret) end
    end
    return false, last, nil
end

function Xaou_WarpSystem.DumpWorldsV33(keyword)
    local places = XaouWarp_ResolvePlaceListV33(keyword)
    local targets = XaouWarp_GetRPGTargetsV33()
    local lines = {"World Enumerator v3.3", "GetWorldsInPlace(string place) -> List<string>", "ใช้ช่องค้นหาเป็น PlaceKey ได้", ""}
    table.insert(lines, "Targets = " .. tostring(#targets))
    table.insert(lines, "Places = " .. tostring(#places))
    table.insert(lines, "")

    XaouWarp_LastV33Target = nil
    XaouWarp_LastV33Place = nil
    XaouWarp_LastV33Worlds = nil
    XaouWarp_LastV33World = nil
    XaouWarp_LastV33Call = nil

    local attempts = 0
    for _, tg in ipairs(targets) do
        local hasFn = XaouWarp_FieldV33(tg.obj, "GetWorldsInPlace") ~= nil
        table.insert(lines, "Target: " .. tostring(tg.label) .. " GetWorlds=" .. tostring(hasFn))
        if hasFn then
            for _, place in ipairs(places) do
                attempts = attempts + 1
                local ok, call, worlds = XaouWarp_TryGetWorldsStringV33(tg.obj, place)
                if ok then
                    local arr, count = XaouWarp_CollectWorldStringsV33(worlds)
                    table.insert(lines, "OK place=" .. tostring(place))
                    table.insert(lines, "call=" .. tostring(call))
                    table.insert(lines, "raw=" .. (XaouWarp_ShortObj and XaouWarp_ShortObj(worlds) or tostring(worlds)))
                    table.insert(lines, "count=" .. tostring(count) .. " strings=" .. tostring(#arr))
                    for i=1, math.min(#arr, 8) do
                        table.insert(lines, "  World["..tostring(i).."]=" .. tostring(arr[i]))
                    end
                    if #arr > 0 then
                        XaouWarp_LastV33Target = tg.obj
                        XaouWarp_LastV33Place = place
                        XaouWarp_LastV33Worlds = worlds
                        XaouWarp_LastV33World = arr[1]
                        XaouWarp_LastV33Call = tg.label .. " / " .. place .. " / " .. call
                        table.insert(lines, "")
                        table.insert(lines, "เจอ FirstWorld แล้ว! ต่อไปกด Test EnterRPGWorld v3.3")
                        XaouWarp_Msg(table.concat(lines, "\n"), "Worlds v3.3")
                        return true
                    else
                        table.insert(lines, "ไม่มี string world ในผลลัพธ์")
                    end
                else
                    if attempts <= 8 then table.insert(lines, "  "..tostring(place).." -> "..tostring(call)) end
                end
                if attempts >= 20 then break end
            end
        end
        if attempts >= 20 then break end
    end
    table.insert(lines, "")
    table.insert(lines, "ยังไม่เจอ world string")
    table.insert(lines, "attempts=" .. tostring(attempts))
    XaouWarp_Msg(table.concat(lines, "\n"), "Worlds v3.3")
    return false
end

local function XaouWarp_BuildNpcListCandidatesV33()
    local list = {}
    local function add(label, obj) table.insert(list, {label=label, obj=obj}) end
    add("nil", nil)
    add("lua {}", {})
    local targetNpc = Xaou_CurrentNpcTarget or me
    add("{targetNpc}", {targetNpc})
    add("targetNpc", targetNpc)

    -- พยายามสร้าง System.Collections.Generic.List<XiaWorld.Npc>
    pcall(function()
        if CS ~= nil and CS.System ~= nil and CS.System.Collections ~= nil and CS.System.Collections.Generic ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.Npc ~= nil then
            local ltype = CS.System.Collections.Generic.List(CS.XiaWorld.Npc)
            local l = ltype()
            if targetNpc ~= nil and l.Add ~= nil then l:Add(targetNpc) end
            add("List<Npc> + target", l)
        end
    end)
    pcall(function()
        if CS ~= nil and CS.System ~= nil and CS.System.Collections ~= nil and CS.System.Collections.Generic ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.Npc ~= nil then
            local ltype = CS.System.Collections.Generic.List(CS.XiaWorld.Npc)
            local l = ltype()
            add("List<Npc> empty", l)
        end
    end)
    return list
end

local function XaouWarp_TryEnterRPGV33(target, npcs, world, p)
    local fn = XaouWarp_FieldV33(target, "EnterRPGWorld")
    if fn == nil then return false, "no EnterRPGWorld", nil end
    local tries = {
        {"fn(target,npcs,world,p)", function() return fn(target, npcs, world, p) end},
        {"target:EnterRPGWorld(npcs,world,p)", function() return target:EnterRPGWorld(npcs, world, p) end},
        {"fn(npcs,world,p)", function() return fn(npcs, world, p) end},
    }
    local last = ""
    for _, t in ipairs(tries) do
        local ok, ret = pcall(t[2])
        if ok then return true, t[1], ret end
        last = t[1] .. " => " .. tostring(ret)
    end
    return false, last, nil
end

function Xaou_WarpSystem.TestEnterRPGWorldV33(keyword)
    local lines = {"EnterRPGWorld Test v3.3", "signature: List<Npc>, string world, string p", ""}
    local target = XaouWarp_LastV33Target
    local world = XaouWarp_LastV33World
    local place = XaouWarp_LastV33Place or (XaouWarp_ResolveTestPlaceKey and XaouWarp_ResolveTestPlaceKey(keyword) or "")
    table.insert(lines, "LastCall = " .. tostring(XaouWarp_LastV33Call))
    table.insert(lines, "Target = " .. (XaouWarp_ShortObj and XaouWarp_ShortObj(target) or tostring(target)))
    table.insert(lines, "World = " .. tostring(world))
    table.insert(lines, "Place/p = " .. tostring(place))
    table.insert(lines, "")
    if target == nil or world == nil or tostring(world) == "" then
        table.insert(lines, "ยังไม่มี World string")
        table.insert(lines, "ให้กด Dump Worlds v3.3 ก่อน")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.3")
        return false
    end

    local npcsList = XaouWarp_BuildNpcListCandidatesV33()
    local pList = {place, "", tostring(world)}
    local attempts = 0
    for _, nc in ipairs(npcsList) do
        for _, p in ipairs(pList) do
            attempts = attempts + 1
            local ok, call, ret = XaouWarp_TryEnterRPGV33(target, nc.obj, world, p)
            table.insert(lines, "#"..attempts.." npcs="..tostring(nc.label).." p="..tostring(p))
            table.insert(lines, "  "..(ok and "OK " or "ERR ")..tostring(call))
            table.insert(lines, "  ret="..(XaouWarp_ShortObj and XaouWarp_ShortObj(ret) or tostring(ret)))
            if ok then
                table.insert(lines, "")
                table.insert(lines, "ถ้าเกมโหลด/เข้า RPG Map แปลว่าเจอทางวาร์ปแล้ว")
                XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.3")
                return true
            end
            if attempts >= 12 then break end
        end
        if attempts >= 12 then break end
    end
    table.insert(lines, "")
    table.insert(lines, "ยังไม่เข้าได้ แต่ error ด้านบนจะบอกชนิด npcs/p ที่ถูก")
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.3")
    return false
end

-- override tester v3.3
local Xaou_Old_TestTravelApi_v33 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "dump_worlds_v33" then return Xaou_WarpSystem.DumpWorldsV33(keyword) end
    if action == "enter_rpg_v33" then return Xaou_WarpSystem.TestEnterRPGWorldV33(keyword) end
    if Xaou_Old_TestTravelApi_v33 ~= nil then return Xaou_Old_TestTravelApi_v33(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end

-- ============================================================
-- Xaou Warp v3.4 - RPGWorldInfoDef / Known RPG Place Enumerator
-- ข้อมูลจาก Settings/RPG/Info/RpgInfo.xml:
--   RpgTower -> Place_YiJieLieFeng
--   RpgArena -> Place_SouthMount
--   RpgQianKun / RpgArena_YingTian ไม่มี Places ใน xml
-- จุดประสงค์: ไม่วน Place ทั่วไปแล้ว แต่ใช้ place ที่มี RPG world ผูกจริง
-- ============================================================
XaouWarp_LastV34Target = XaouWarp_LastV34Target or nil
XaouWarp_LastV34Place = XaouWarp_LastV34Place or nil
XaouWarp_LastV34World = XaouWarp_LastV34World or nil
XaouWarp_LastV34Call = XaouWarp_LastV34Call or nil

local function XaouWarp_FieldV34(obj, name)
    local v = nil
    pcall(function() if obj ~= nil then v = obj[name] end end)
    return v
end

local function XaouWarp_SafeStrV34(v)
    if v == nil then return "nil" end
    local ok, s = pcall(function() return tostring(v) end)
    if ok then return s end
    return "<tostring err>"
end

local function XaouWarp_AddUniqueV34(list, label, obj)
    if obj == nil then return end
    for _, it in ipairs(list) do if it.obj == obj then return end end
    table.insert(list, {label=label, obj=obj})
end

local function XaouWarp_GetRPGTargetsV34()
    local list = {}
    local g = XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("RPGMapMgr") or nil
    local cs = XaouWarp_GetCSPathSafe and XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr") or nil
    XaouWarp_AddUniqueV34(list, "RPGMapMgr", g)
    XaouWarp_AddUniqueV34(list, "RPGMapMgr.Instance", XaouWarp_FieldV34(g, "Instance"))
    XaouWarp_AddUniqueV34(list, "CS.XiaWorld.RPGMapMgr", cs)
    XaouWarp_AddUniqueV34(list, "CS.XiaWorld.RPGMapMgr.Instance", XaouWarp_FieldV34(cs, "Instance"))
    return list
end

local function XaouWarp_ListCountV34(list)
    local c = nil
    pcall(function() if list ~= nil and list.Count ~= nil then c = tonumber(list.Count) end end)
    pcall(function() if c == nil and list ~= nil and list.count ~= nil then c = tonumber(list.count) end end)
    if c ~= nil then return c end
    local n = 0
    pcall(function()
        if list ~= nil then
            for _, _ in pairs(list) do
                n = n + 1
                if n > 200 then break end
            end
        end
    end)
    return n
end

local function XaouWarp_GetListItemV34(list, idx)
    local v = nil
    pcall(function() if list ~= nil then v = list[idx] end end)
    pcall(function() if v == nil and list ~= nil and list.get_Item ~= nil then v = list:get_Item(idx) end end)
    pcall(function() if v == nil and list ~= nil and list.GetItem ~= nil then v = list:GetItem(idx) end end)
    return v
end

local function XaouWarp_CollectStringsV34(worlds)
    local out, seen = {}, {}
    local function add(v)
        if v == nil then return end
        local s = XaouWarp_SafeStrV34(v)
        if s == "" or s == "nil" then return end
        if seen[s] then return end
        seen[s] = true
        table.insert(out, s)
    end
    local count = XaouWarp_ListCountV34(worlds)
    if count ~= nil and count > 0 then
        for i=0, math.min(count - 1, 40) do add(XaouWarp_GetListItemV34(worlds, i)) end
        for i=1, math.min(count, 40) do add(XaouWarp_GetListItemV34(worlds, i)) end
    end
    pcall(function()
        if worlds ~= nil then
            local n = 0
            for _, v in pairs(worlds) do
                add(v)
                n = n + 1
                if n >= 40 then break end
            end
        end
    end)
    return out, count
end

local function XaouWarp_KnownRPGPlacesV34(keyword)
    local list, seen = {}, {}
    local function add(place, why)
        if place == nil then return end
        place = tostring(place)
        if place == "" or seen[place] then return end
        seen[place] = true
        table.insert(list, {place=place, why=why or ""})
    end
    local k = XaouWarp_ResolveTestPlaceKey and XaouWarp_ResolveTestPlaceKey(keyword) or tostring(keyword or "")
    if k ~= nil and k ~= "" then add(k, "search/input") end

    -- ยืนยันจาก Settings/RPG/Info/RpgInfo.xml
    add("Place_SouthMount", "RpgArena จาก RpgInfo.xml")
    add("Place_YiJieLieFeng", "RpgTower จาก RpgInfo.xml")

    -- สำรองจากฐาน place ที่ผู้ใช้มี/เคยใช้ เผื่อมือถือใช้ชื่อคนละชุด
    add("Place_BigBamboo", "ทดสอบเดิม")
    add("Place_LongHu", "สำนัก/Place สำรอง")
    add("Place_DanXia", "สำนัก/Place สำรอง")
    add("Place_KunLun", "สำนัก/Place สำรอง")
    add("Place_WuDang", "DLC/Place สำรอง")
    return list
end

local function XaouWarp_TryGetWorldsV34(target, place)
    local fn = XaouWarp_FieldV34(target, "GetWorldsInPlace")
    if fn == nil then return false, "no GetWorldsInPlace", nil end
    local tries = {
        {"target:GetWorldsInPlace(place)", function() return target:GetWorldsInPlace(place) end},
        {"fn(target,place)", function() return fn(target, place) end},
        {"fn(place)", function() return fn(place) end},
    }
    local last = ""
    for _, t in ipairs(tries) do
        local ok, ret = pcall(t[2])
        if ok and ret ~= nil then return true, t[1], ret end
        if ok then last = t[1] .. " => nil" else last = t[1] .. " => " .. tostring(ret) end
    end
    return false, last, nil
end

function Xaou_WarpSystem.DumpRPGWorldDefsV34(keyword)
    local targets = XaouWarp_GetRPGTargetsV34()
    local places = XaouWarp_KnownRPGPlacesV34(keyword)
    local lines = {"RPG World Finder v3.4", "ใช้ Place ที่มี RPG world ผูกจริงจาก RpgInfo.xml", "", "Targets="..tostring(#targets), "Places="..tostring(#places), ""}

    XaouWarp_LastV34Target = nil
    XaouWarp_LastV34Place = nil
    XaouWarp_LastV34World = nil
    XaouWarp_LastV34Call = nil

    local attempt = 0
    for _, tg in ipairs(targets) do
        local has = XaouWarp_FieldV34(tg.obj, "GetWorldsInPlace") ~= nil
        table.insert(lines, "Target: "..tostring(tg.label).." GetWorlds="..tostring(has))
        if has then
            for _, pi in ipairs(places) do
                attempt = attempt + 1
                local ok, call, worlds = XaouWarp_TryGetWorldsV34(tg.obj, pi.place)
                if ok then
                    local arr, count = XaouWarp_CollectStringsV34(worlds)
                    table.insert(lines, "OK place="..tostring(pi.place).."  ("..tostring(pi.why)..")")
                    table.insert(lines, "call="..tostring(call))
                    table.insert(lines, "raw="..(XaouWarp_ShortObj and XaouWarp_ShortObj(worlds) or XaouWarp_SafeStrV34(worlds)))
                    table.insert(lines, "count="..tostring(count).." strings="..tostring(#arr))
                    for i=1, math.min(#arr, 8) do table.insert(lines, "  World["..i.."]="..tostring(arr[i])) end
                    if #arr > 0 then
                        XaouWarp_LastV34Target = tg.obj
                        XaouWarp_LastV34Place = pi.place
                        XaouWarp_LastV34World = arr[1]
                        XaouWarp_LastV34Call = tostring(tg.label).." / "..tostring(pi.place).." / "..tostring(call)
                        table.insert(lines, "")
                        table.insert(lines, "เจอ FirstWorld แล้ว: "..tostring(arr[1]))
                        table.insert(lines, "ต่อไปกด Test Enter v3.4")
                        XaouWarp_Msg(table.concat(lines, "\n"), "RPG Worlds v3.4")
                        return true
                    end
                else
                    table.insert(lines, "  "..tostring(pi.place).." -> "..tostring(call))
                end
                if attempt >= 24 then break end
            end
        end
        if attempt >= 24 then break end
    end

    table.insert(lines, "")
    table.insert(lines, "ยังไม่เจอ world string")
    table.insert(lines, "ถ้าไม่เจอ ให้ลองพิมพ์ PlaceKey อื่นในช่องค้นหาแล้วกดใหม่")
    XaouWarp_Msg(table.concat(lines, "\n"), "RPG Worlds v3.4")
    return false
end

local function XaouWarp_BuildNpcListV34()
    local out = {}
    local function add(label, obj) table.insert(out, {label=label, obj=obj}) end
    local npc = Xaou_CurrentNpcTarget or me

    -- List<Npc> ว่าง / มี npc เป้าหมาย ถ้าสร้างได้
    pcall(function()
        if CS and CS.System and CS.System.Collections and CS.System.Collections.Generic and CS.XiaWorld and CS.XiaWorld.Npc then
            local T = CS.System.Collections.Generic.List(CS.XiaWorld.Npc)
            local l0 = T()
            add("List<Npc> empty", l0)
            local l1 = T()
            if npc ~= nil and l1.Add ~= nil then l1:Add(npc) end
            add("List<Npc> + target", l1)
        end
    end)

    add("lua {}", {})
    if npc ~= nil then add("lua {target}", {npc}) end
    add("nil", nil)
    return out
end

local function XaouWarp_TryEnterV34(target, npcs, world, p)
    local fn = XaouWarp_FieldV34(target, "EnterRPGWorld")
    if fn == nil then return false, "no EnterRPGWorld", nil end
    local tries = {
        {"target:EnterRPGWorld(npcs,world,p)", function() return target:EnterRPGWorld(npcs, world, p) end},
        {"fn(target,npcs,world,p)", function() return fn(target, npcs, world, p) end},
        {"fn(npcs,world,p)", function() return fn(npcs, world, p) end},
    }
    local last = ""
    for _, t in ipairs(tries) do
        local ok, ret = pcall(t[2])
        if ok then return true, t[1], ret end
        last = t[1] .. " => " .. tostring(ret)
    end
    return false, last, nil
end

function Xaou_WarpSystem.TestEnterRPGWorldV34(keyword)
    local lines = {"EnterRPGWorld Test v3.4", "ใช้ FirstWorld จาก RPG World Finder v3.4", ""}
    local target = XaouWarp_LastV34Target
    local world = XaouWarp_LastV34World
    local place = XaouWarp_LastV34Place
    if (world == nil or tostring(world) == "") and keyword ~= nil and tostring(keyword) ~= "" then
        world = tostring(keyword)
    end
    table.insert(lines, "LastCall="..tostring(XaouWarp_LastV34Call))
    table.insert(lines, "World="..tostring(world))
    table.insert(lines, "Place/p="..tostring(place))
    table.insert(lines, "Target="..(XaouWarp_ShortObj and XaouWarp_ShortObj(target) or XaouWarp_SafeStrV34(target)))
    table.insert(lines, "")

    if target == nil or world == nil or tostring(world) == "" then
        table.insert(lines, "ยังไม่มี FirstWorld")
        table.insert(lines, "ให้กด Dump RPG Worlds v3.4 ก่อน")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.4")
        return false
    end

    local npcLists = XaouWarp_BuildNpcListV34()
    local pList = {tostring(place or ""), "", tostring(world)}
    local attempt = 0
    for _, nc in ipairs(npcLists) do
        for _, p in ipairs(pList) do
            attempt = attempt + 1
            local ok, call, ret = XaouWarp_TryEnterV34(target, nc.obj, world, p)
            table.insert(lines, "#"..attempt.." npcs="..tostring(nc.label).." p="..tostring(p))
            table.insert(lines, "  "..(ok and "OK " or "ERR ")..tostring(call))
            table.insert(lines, "  ret="..(XaouWarp_ShortObj and XaouWarp_ShortObj(ret) or XaouWarp_SafeStrV34(ret)))
            if ok then
                table.insert(lines, "")
                table.insert(lines, "ถ้าเกมเปลี่ยนแผนที่/โหลด แปลว่าเส้นทางนี้ใช้ได้")
                XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.4")
                return true
            end
            if attempt >= 12 then break end
        end
        if attempt >= 12 then break end
    end
    table.insert(lines, "")
    table.insert(lines, "ยังไม่สำเร็จ ส่งรูป error ช่วงท้ายมาได้เลย")
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.4")
    return false
end

-- override tester v3.4
local Xaou_Old_TestTravelApi_v34 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "dump_rpg_worlds_v34" then return Xaou_WarpSystem.DumpRPGWorldDefsV34(keyword) end
    if action == "enter_rpg_v34" then return Xaou_WarpSystem.TestEnterRPGWorldV34(keyword) end
    if Xaou_Old_TestTravelApi_v34 ~= nil then return Xaou_Old_TestTravelApi_v34(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end

-- ============================================================
-- Xaou Warp v3.5 - Runtime Field Dumper / Known World Key Tester
-- จุดประสงค์:
-- 1) ไม่หาไฟล์เพิ่มแล้ว ให้เกม dump field/property ของ RPGWorldInfoDef/runtime object เอง
-- 2) ทดสอบ world key ที่ยืนยันจาก RpgInfo.xml: RpgArena / RpgTower
-- ============================================================
XaouWarp_LastV35Target = XaouWarp_LastV35Target or nil
XaouWarp_LastV35World = XaouWarp_LastV35World or nil
XaouWarp_LastV35Place = XaouWarp_LastV35Place or nil
XaouWarp_LastV35Call = XaouWarp_LastV35Call or nil

local function XaouWarp_FieldV35(obj, name)
    local v = nil
    pcall(function() if obj ~= nil then v = obj[name] end end)
    return v
end

local function XaouWarp_SafeStrV35(v)
    if v == nil then return "nil" end
    local ok, s = pcall(function() return tostring(v) end)
    if ok then return s end
    return "<tostring err>"
end

local function XaouWarp_AddUniqueV35(list, label, obj)
    if obj == nil then return end
    for _, it in ipairs(list) do if it.obj == obj then return end end
    table.insert(list, {label=label, obj=obj})
end

local function XaouWarp_GetRPGTargetsV35()
    local list = {}
    local g = XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("RPGMapMgr") or nil
    local cs = XaouWarp_GetCSPathSafe and XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr") or nil
    XaouWarp_AddUniqueV35(list, "RPGMapMgr", g)
    XaouWarp_AddUniqueV35(list, "RPGMapMgr.Instance", XaouWarp_FieldV35(g, "Instance"))
    XaouWarp_AddUniqueV35(list, "CS.XiaWorld.RPGMapMgr", cs)
    XaouWarp_AddUniqueV35(list, "CS.XiaWorld.RPGMapMgr.Instance", XaouWarp_FieldV35(cs, "Instance"))
    return list
end

local function XaouWarp_ListCountV35(list)
    local c = nil
    pcall(function() if list ~= nil and list.Count ~= nil then c = tonumber(list.Count) end end)
    pcall(function() if c == nil and list ~= nil and list.count ~= nil then c = tonumber(list.count) end end)
    if c ~= nil then return c end
    local n = 0
    pcall(function()
        if list ~= nil then
            for _, _ in pairs(list) do
                n = n + 1
                if n > 200 then break end
            end
        end
    end)
    return n
end

local function XaouWarp_GetListItemV35(list, idx)
    local v = nil
    pcall(function() if list ~= nil then v = list[idx] end end)
    pcall(function() if v == nil and list ~= nil and list.get_Item ~= nil then v = list:get_Item(idx) end end)
    pcall(function() if v == nil and list ~= nil and list.GetItem ~= nil then v = list:GetItem(idx) end end)
    return v
end

local function XaouWarp_DumpObjectFieldsV35(obj, label, maxFields)
    local lines = {}
    maxFields = maxFields or 18
    table.insert(lines, tostring(label) .. " = " .. XaouWarp_SafeStrV35(obj))
    if obj == nil then return lines end

    local names = {
        "Name", "Key", "ID", "Title", "Desc", "Places", "NeedUnlock",
        "MaxEnterNpc", "MinEnterNpc", "NpcType", "EnterFlag", "Parent",
        "DisplayName", "Place", "PlaceID", "World", "Def", "Data", "PlaceData"
    }
    for _, n in ipairs(names) do
        local v = XaouWarp_FieldV35(obj, n)
        if v ~= nil then
            local s = XaouWarp_SafeStrV35(v)
            if n == "Places" then
                local c = XaouWarp_ListCountV35(v)
                s = s .. " Count=" .. tostring(c)
                local tmp = {}
                for i=0, math.min((tonumber(c or 0) or 0)-1, 5) do
                    table.insert(tmp, XaouWarp_SafeStrV35(XaouWarp_GetListItemV35(v, i)))
                end
                if #tmp > 0 then s = s .. " [" .. table.concat(tmp, ", ") .. "]" end
            end
            table.insert(lines, "  ."..tostring(n).." = "..s)
        end
    end

    local n = 0
    pcall(function()
        for k, v in pairs(obj) do
            local ks = tostring(k)
            local already = false
            for _, nn in ipairs(names) do if ks == nn then already = true break end end
            if not already then
                n = n + 1
                table.insert(lines, "  ["..ks.."] = "..XaouWarp_SafeStrV35(v))
                if n >= maxFields then break end
            end
        end
    end)
    return lines
end

local function XaouWarp_KnownWorldPairsV35(keyword)
    local out = {}
    local function add(world, place, why)
        table.insert(out, {world=world, place=place, why=why})
    end
    -- ยืนยันจาก RpgInfo.xml / DummyDll: RPGWorldInfoDef.Name คือ world key ที่น่าจะใช้
    add("RpgArena", "Place_SouthMount", "RpgArena จาก RpgInfo.xml")
    add("RpgTower", "Place_YiJieLieFeng", "RpgTower จาก RpgInfo.xml")
    -- สำรอง เผื่อชื่อ key ในมือถือมี prefix/variant
    add("RpgArena_YingTian", "Place_SouthMount", "variant ที่เจอในไฟล์")
    add("RpgQianKun", "Place_SouthMount", "variant ที่เจอในไฟล์")
    local kw = tostring(keyword or "")
    if kw ~= "" then
        -- ถ้าผู้ใช้พิมพ์ world เอง ให้ใช้ place ปัจจุบัน/Place_SouthMount เป็น p
        add(kw, "Place_SouthMount", "จากช่องค้นหา")
    end
    return out
end

local function XaouWarp_CallMethodV35(target, method, args)
    local fn = XaouWarp_FieldV35(target, method)
    if fn == nil then return false, "no "..tostring(method), nil end
    local tries = {}
    if #args == 1 then
        table.insert(tries, {"target:"..method.."(a)", function() return target[method](target, args[1]) end})
        table.insert(tries, {"fn(target,a)", function() return fn(target, args[1]) end})
        table.insert(tries, {"fn(a)", function() return fn(args[1]) end})
    elseif #args == 3 then
        table.insert(tries, {"target:"..method.."(a,b,c)", function() return target[method](target, args[1], args[2], args[3]) end})
        table.insert(tries, {"fn(target,a,b,c)", function() return fn(target, args[1], args[2], args[3]) end})
        table.insert(tries, {"fn(a,b,c)", function() return fn(args[1], args[2], args[3]) end})
    end
    local last = ""
    for _, t in ipairs(tries) do
        local ok, ret = pcall(t[2])
        if ok then return true, t[1], ret end
        last = t[1] .. " => " .. tostring(ret)
    end
    return false, last, nil
end

function Xaou_WarpSystem.DumpRuntimeWorldFieldsV35(keyword)
    local lines = {"Runtime World Field Dumper v3.5", "ดึง field/property ของ world runtime + ทดสอบ key ที่รู้จาก RpgInfo.xml", ""}
    local targets = XaouWarp_GetRPGTargetsV35()
    local pairs35 = XaouWarp_KnownWorldPairsV35(keyword)
    table.insert(lines, "Targets="..tostring(#targets).."  KnownWorlds="..tostring(#pairs35))

    XaouWarp_LastV35Target = nil
    XaouWarp_LastV35World = nil
    XaouWarp_LastV35Place = nil
    XaouWarp_LastV35Call = nil

    for _, tg in ipairs(targets) do
        table.insert(lines, "")
        table.insert(lines, "Target: "..tostring(tg.label).." = "..XaouWarp_SafeStrV35(tg.obj))
        local methods = {"GetWorldsInPlace", "IsWorldUnlock", "UnlockWorld", "EnterRPGWorld"}
        local ms = {}
        for _, m in ipairs(methods) do if XaouWarp_FieldV35(tg.obj, m) ~= nil then table.insert(ms, m) end end
        table.insert(lines, "method="..(#ms>0 and table.concat(ms, ", ") or "ไม่พบ"))

        for _, wp in ipairs(pairs35) do
            table.insert(lines, "- world="..tostring(wp.world).." place="..tostring(wp.place))
            local okU, callU, retU = XaouWarp_CallMethodV35(tg.obj, "IsWorldUnlock", {wp.world})
            table.insert(lines, "  IsUnlock: "..(okU and "OK " or "ERR ")..tostring(callU).." => "..XaouWarp_SafeStrV35(retU))
            local okG, callG, retG = XaouWarp_CallMethodV35(tg.obj, "GetWorldsInPlace", {wp.place})
            table.insert(lines, "  GetWorlds: "..(okG and "OK " or "ERR ")..tostring(callG).." => "..XaouWarp_SafeStrV35(retG))
            if okG and retG ~= nil then
                local c = XaouWarp_ListCountV35(retG)
                table.insert(lines, "  worlds.Count="..tostring(c))
                for i=0, math.min((tonumber(c or 0) or 0)-1, 4) do
                    table.insert(lines, "    ["..i.."] "..XaouWarp_SafeStrV35(XaouWarp_GetListItemV35(retG, i)))
                end
            end
            -- ถ้า key นี้เช็กไม่ error ให้เก็บเป็น candidate สำหรับปุ่ม Enter
            if XaouWarp_LastV35World == nil and XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil then
                XaouWarp_LastV35Target = tg.obj
                XaouWarp_LastV35World = wp.world
                XaouWarp_LastV35Place = wp.place
                XaouWarp_LastV35Call = tostring(tg.label).." / "..tostring(wp.world).." / "..tostring(wp.place)
            end
            if #lines > 32 then break end
        end
        if #lines > 32 then break end
    end

    table.insert(lines, "")
    table.insert(lines, "Candidate Enter:")
    table.insert(lines, "World="..tostring(XaouWarp_LastV35World).."  p/place="..tostring(XaouWarp_LastV35Place))
    table.insert(lines, "ถ้ามี Candidate ให้ลอง Test Enter v3.5")
    XaouWarp_Msg(table.concat(lines, "\n"), "World Fields v3.5")
    return XaouWarp_LastV35World ~= nil
end

local function XaouWarp_BuildNpcListV35()
    local out = {}
    local function add(label, obj) table.insert(out, {label=label, obj=obj}) end
    local npc = Xaou_CurrentNpcTarget or me
    pcall(function()
        if CS and CS.System and CS.System.Collections and CS.System.Collections.Generic and CS.XiaWorld and CS.XiaWorld.Npc then
            local T = CS.System.Collections.Generic.List(CS.XiaWorld.Npc)
            local l0 = T()
            add("List<Npc> empty", l0)
            local l1 = T()
            if npc ~= nil and l1.Add ~= nil then l1:Add(npc) end
            add("List<Npc> + target", l1)
        end
    end)
    add("lua {}", {})
    if npc ~= nil then add("lua {target}", {npc}) end
    add("nil", nil)
    return out
end

function Xaou_WarpSystem.TestEnterRPGWorldV35(keyword)
    local lines = {"EnterRPGWorld Test v3.5", "ใช้ world key จาก RpgInfo.xml / Runtime Field Dumper", ""}
    local target = XaouWarp_LastV35Target
    local world = XaouWarp_LastV35World
    local place = XaouWarp_LastV35Place
    local kw = tostring(keyword or "")
    if kw ~= "" then world = kw end
    if target == nil then
        local targets = XaouWarp_GetRPGTargetsV35()
        for _, tg in ipairs(targets) do
            if XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil then
                target = tg.obj
                break
            end
        end
    end
    if world == nil or tostring(world) == "" then world = "RpgArena" end
    if place == nil or tostring(place) == "" then place = "Place_SouthMount" end

    table.insert(lines, "LastCall="..tostring(XaouWarp_LastV35Call))
    table.insert(lines, "World="..tostring(world))
    table.insert(lines, "p/place="..tostring(place))
    table.insert(lines, "Target="..XaouWarp_SafeStrV35(target))
    table.insert(lines, "")

    if target == nil then
        table.insert(lines, "ไม่พบ target ที่มี EnterRPGWorld")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.5")
        return false
    end

    local npcLists = XaouWarp_BuildNpcListV35()
    local pList = {tostring(place), "", tostring(world), "place", "world"}
    local attempt = 0
    for _, nc in ipairs(npcLists) do
        for _, p in ipairs(pList) do
            attempt = attempt + 1
            local ok, call, ret = XaouWarp_CallMethodV35(target, "EnterRPGWorld", {nc.obj, world, p})
            table.insert(lines, "#"..attempt.." npcs="..tostring(nc.label).." p="..tostring(p))
            table.insert(lines, "  "..(ok and "OK " or "ERR ")..tostring(call))
            table.insert(lines, "  ret="..XaouWarp_SafeStrV35(ret))
            if ok then
                table.insert(lines, "")
                table.insert(lines, "ถ้าเกมโหลด/เปิดหน้าต่าง/เปลี่ยนแมพ แปลว่าค่านี้ใช้ได้")
                XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.5")
                return true
            end
            if attempt >= 15 then break end
        end
        if attempt >= 15 then break end
    end
    table.insert(lines, "")
    table.insert(lines, "ยังไม่สำเร็จ ส่งรูป error ช่วงท้ายมาได้เลย")
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.5")
    return false
end

-- override tester v3.5
local Xaou_Old_TestTravelApi_v35 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "dump_world_fields_v35" then return Xaou_WarpSystem.DumpRuntimeWorldFieldsV35(keyword) end
    if action == "enter_rpg_v35" then return Xaou_WarpSystem.TestEnterRPGWorldV35(keyword) end
    if Xaou_Old_TestTravelApi_v35 ~= nil then return Xaou_Old_TestTravelApi_v35(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end


-- ============================================================
-- Xaou Warp v3.6 - World Key Tester จาก RpgInfo.xml
-- จุดประสงค์:
-- 1) ใช้ world key ที่ยืนยันจาก RpgInfo.xml โดยตรง
-- 2) ไล่ทดสอบ IsWorldUnlock / UnlockWorld / GetWorldsInPlace
-- 3) ทดสอบ EnterRPGWorld(List<Npc>, world:string, p:string) แบบปลอดภัยเป็นชุดสั้น ๆ
-- ============================================================
XaouWarp_LastV36Target = XaouWarp_LastV36Target or nil
XaouWarp_LastV36World = XaouWarp_LastV36World or nil
XaouWarp_LastV36Place = XaouWarp_LastV36Place or nil
XaouWarp_LastV36Call = XaouWarp_LastV36Call or nil

local function XaouWarp_KnownWorldPairsV36(keyword)
    local out = {}
    local function add(world, place, why)
        if world == nil or tostring(world) == "" then return end
        table.insert(out, {world=tostring(world), place=tostring(place or ""), why=tostring(why or "")})
    end

    -- key จาก RpgInfo.xml ที่ส่งมา
    add("RpgArena", "Place_SouthMount", "RpgInfo.xml: Dojo")
    add("RpgArena_YingTian", "Place_SouthMount", "RpgInfo.xml: Heaven Echo Altar")
    add("RpgTower", "Place_YiJieLieFeng", "RpgInfo.xml: Rift Between Worlds")
    add("RpgQianKun", "Place_QianKun", "RpgInfo.xml: Rift of the Universe")

    -- สำรอง place ที่เคยเห็นในระบบ map/settings เผื่อ p ต้องเป็น place ที่เปิดอยู่จริง
    add("RpgArena", "Place_BigBamboo", "fallback current test place")
    add("RpgTower", "Place_BigBamboo", "fallback current test place")
    add("RpgQianKun", "Place_BigBamboo", "fallback current test place")

    local kw = tostring(keyword or "")
    if kw ~= "" then
        -- ถ้าพิมพ์ชื่อเองในช่องค้นหา จะเอามาลองเป็น world key ด้วย
        add(kw, "Place_SouthMount", "จากช่องค้นหา")
        add(kw, "Place_BigBamboo", "จากช่องค้นหา fallback")
    end
    return out
end

local function XaouWarp_GetRPGTargetsV36()
    -- ใช้ helper เดิมของ v3.5 ถ้ามี
    if XaouWarp_GetRPGTargetsV35 ~= nil then
        return XaouWarp_GetRPGTargetsV35()
    end
    local list = {}
    local function add(label, obj)
        if obj == nil then return end
        for _, it in ipairs(list) do if it.obj == obj then return end end
        table.insert(list, {label=label, obj=obj})
    end
    local function f(obj, name)
        local v=nil; pcall(function() if obj~=nil then v=obj[name] end end); return v
    end
    local g = XaouWarp_GetGlobalSafe and XaouWarp_GetGlobalSafe("RPGMapMgr") or nil
    local cs = XaouWarp_GetCSPathSafe and XaouWarp_GetCSPathSafe("XiaWorld.RPGMapMgr") or nil
    add("RPGMapMgr", g)
    add("RPGMapMgr.Instance", f(g,"Instance"))
    add("CS.XiaWorld.RPGMapMgr", cs)
    add("CS.XiaWorld.RPGMapMgr.Instance", f(cs,"Instance"))
    return list
end

function Xaou_WarpSystem.ScanWorldKeysV36(keyword)
    local lines = {"World Key Scanner v3.6", "ใช้ key จาก RpgInfo.xml โดยตรง", ""}
    local targets = XaouWarp_GetRPGTargetsV36()
    local keys = XaouWarp_KnownWorldPairsV36(keyword)
    table.insert(lines, "Targets="..tostring(#targets).."  TestKeys="..tostring(#keys))

    XaouWarp_LastV36Target = nil
    XaouWarp_LastV36World = nil
    XaouWarp_LastV36Place = nil
    XaouWarp_LastV36Call = nil

    for _, tg in ipairs(targets) do
        table.insert(lines, "")
        table.insert(lines, "Target: "..tostring(tg.label).." = "..XaouWarp_SafeStrV35(tg.obj))
        local hasEnter = XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil
        local hasUnlock = XaouWarp_FieldV35(tg.obj, "UnlockWorld") ~= nil
        table.insert(lines, "method Enter="..tostring(hasEnter).." Unlock="..tostring(hasUnlock))

        for _, wp in ipairs(keys) do
            local okI, callI, retI = XaouWarp_CallMethodV35(tg.obj, "IsWorldUnlock", {wp.world})
            local okU, callU, retU = XaouWarp_CallMethodV35(tg.obj, "UnlockWorld", {wp.world})
            local okG, callG, retG = XaouWarp_CallMethodV35(tg.obj, "GetWorldsInPlace", {wp.place})

            table.insert(lines, "- "..wp.world.." / p="..wp.place)
            table.insert(lines, "  IsUnlock: "..(okI and "OK " or "ERR ")..XaouWarp_SafeStrV35(retI))
            table.insert(lines, "  Unlock: "..(okU and "OK " or "ERR ")..XaouWarp_SafeStrV35(retU))
            table.insert(lines, "  GetWorlds: "..(okG and "OK " or "ERR ")..XaouWarp_SafeStrV35(retG))

            -- เลือก candidate ตัวแรกที่ target มี EnterRPGWorld และ world เรียก Is/Unlock ไม่ error อย่างใดอย่างหนึ่ง
            if XaouWarp_LastV36World == nil and hasEnter and (okI or okU) then
                XaouWarp_LastV36Target = tg.obj
                XaouWarp_LastV36World = wp.world
                XaouWarp_LastV36Place = wp.place
                XaouWarp_LastV36Call = tostring(tg.label).." / "..wp.world.." / "..wp.place
            end
            if #lines > 33 then break end
        end
        if #lines > 33 then break end
    end

    table.insert(lines, "")
    table.insert(lines, "Candidate:")
    table.insert(lines, "World="..tostring(XaouWarp_LastV36World).."  p="..tostring(XaouWarp_LastV36Place))
    table.insert(lines, "ต่อไปกด Test Enter v3.6")
    XaouWarp_Msg(table.concat(lines, "\n"), "WorldKey v3.6")
    return XaouWarp_LastV36World ~= nil
end

function Xaou_WarpSystem.TestEnterRPGWorldV36(keyword)
    local lines = {"EnterRPGWorld Test v3.6", "ลอง world key จาก RpgInfo.xml", ""}
    local targets = XaouWarp_GetRPGTargetsV36()
    local keys = XaouWarp_KnownWorldPairsV36(keyword)
    local target = XaouWarp_LastV36Target
    local world = XaouWarp_LastV36World
    local place = XaouWarp_LastV36Place

    if target == nil then
        for _, tg in ipairs(targets) do
            if XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil then
                target = tg.obj
                break
            end
        end
    end
    if world == nil or tostring(world) == "" then
        world = keys[1] and keys[1].world or "RpgArena"
        place = keys[1] and keys[1].place or "Place_SouthMount"
    end

    table.insert(lines, "Last="..tostring(XaouWarp_LastV36Call))
    table.insert(lines, "Target="..XaouWarp_SafeStrV35(target))
    table.insert(lines, "World="..tostring(world))
    table.insert(lines, "p="..tostring(place))
    table.insert(lines, "")

    if target == nil then
        table.insert(lines, "ไม่พบ target ที่มี EnterRPGWorld")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.6")
        return false
    end

    -- ลองชุดสั้น ๆ ก่อน ลดความเสี่ยงโหลดผิดหลายครั้ง
    local npcLists = XaouWarp_BuildNpcListV35()
    local pList = {tostring(place or ""), "", tostring(world), "Place_SouthMount", "Place_BigBamboo"}
    local attempt = 0
    for _, nc in ipairs(npcLists) do
        for _, p in ipairs(pList) do
            attempt = attempt + 1
            table.insert(lines, "#"..attempt.." npcs="..tostring(nc.label).." p="..tostring(p))
            local ok, call, ret = XaouWarp_CallMethodV35(target, "EnterRPGWorld", {nc.obj, tostring(world), tostring(p)})
            table.insert(lines, "  "..(ok and "OK " or "ERR ")..tostring(call))
            table.insert(lines, "  ret="..XaouWarp_SafeStrV35(ret))
            if ok then
                table.insert(lines, "")
                table.insert(lines, "ถ้าเกมโหลด/เปลี่ยนฉาก/เปิดเลือก NPC แปลว่า world+p นี้ใช้ได้")
                XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.6")
                return true
            end
            if attempt >= 12 then break end
        end
        if attempt >= 12 then break end
    end

    table.insert(lines, "")
    table.insert(lines, "ยังไม่สำเร็จ ส่งรูป error ช่วงท้ายมาได้เลย")
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.6")
    return false
end

-- override tester v3.6
local Xaou_Old_TestTravelApi_v36 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "scan_world_keys_v36" then return Xaou_WarpSystem.ScanWorldKeysV36(keyword) end
    if action == "enter_rpg_v36" then return Xaou_WarpSystem.TestEnterRPGWorldV36(keyword) end
    if Xaou_Old_TestTravelApi_v36 ~= nil then return Xaou_Old_TestTravelApi_v36(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end


-- ============================================================
-- Xaou Warp v3.7 - ใช้ Wnd_SelectNpc4Map ของเกมสร้าง List<Npc> เอง
-- จาก DummyDll:
--   Wnd_SelectNpc4Map.ShowRPGWorld(string[] worlds)
--   Wnd_SelectNpc4Map.ShowPlace(string place)
--   RPGMapMgr.EnterRPGWorld(List<Npc> npcs, string world, string p)
-- แนวคิด v3.7:
--   1) เปิดหน้าต่างเลือก NPC ของเกมโดยตรง เพื่อให้เกมสร้าง selectnpc/List<Npc> เอง
--   2) มีปุ่ม Direct Enter สำรอง โดยสร้าง List<Npc> จาก me/target เท่านั้น
-- ============================================================
XaouWarp_LastV37World = XaouWarp_LastV37World or nil
XaouWarp_LastV37Place = XaouWarp_LastV37Place or nil
XaouWarp_LastV37Target = XaouWarp_LastV37Target or nil

local function XaouWarp_KnownWorldPairsV37(keyword)
    local out = {}
    local function add(world, place, why)
        if world == nil or tostring(world) == "" then return end
        table.insert(out, {world=tostring(world), place=tostring(place or ""), why=tostring(why or "")})
    end
    -- key ที่ยืนยันจาก RpgInfo.xml
    add("RpgArena", "Place_SouthMount", "RpgInfo.xml")
    add("RpgArena_YingTian", "Place_SouthMount", "RpgInfo.xml")
    add("RpgTower", "Place_YiJieLieFeng", "RpgInfo.xml")
    add("RpgQianKun", "Place_QianKun", "RpgInfo.xml")
    -- fallback จากที่ทดสอบในสำนัก
    add("RpgArena", "Place_BigBamboo", "fallback")
    add("RpgTower", "Place_BigBamboo", "fallback")
    add("RpgQianKun", "Place_BigBamboo", "fallback")
    local kw = tostring(keyword or "")
    if kw ~= "" then
        add(kw, "Place_SouthMount", "จากช่องค้นหา")
        add(kw, "Place_BigBamboo", "จากช่องค้นหา fallback")
    end
    return out
end

local function XaouWarp_GetWndSelectNpc4MapV37()
    local list = {}
    local function add(label, obj)
        if obj == nil then return end
        for _, it in ipairs(list) do if it.obj == obj then return end end
        table.insert(list, {label=label, obj=obj})
    end
    if XaouWarp_GetGlobalSafe ~= nil then
        add("Wnd_SelectNpc4Map", XaouWarp_GetGlobalSafe("Wnd_SelectNpc4Map"))
    end
    if XaouWarp_GetCSPathSafe ~= nil then
        add("CS.Wnd_SelectNpc4Map", XaouWarp_GetCSPathSafe("Wnd_SelectNpc4Map"))
        add("CS.XiaWorld.UI.InGame.Wnd_SelectNpc4Map", XaouWarp_GetCSPathSafe("XiaWorld.UI.InGame.Wnd_SelectNpc4Map"))
        add("CS.XiaWorld.Wnd_SelectNpc4Map", XaouWarp_GetCSPathSafe("XiaWorld.Wnd_SelectNpc4Map"))
    end
    pcall(function() if CS ~= nil and CS.Wnd_SelectNpc4Map ~= nil then add("CS.Wnd_SelectNpc4Map direct", CS.Wnd_SelectNpc4Map) end end)
    return list
end

local function XaouWarp_MakeStringArrayV37(values)
    local arr = nil
    -- XLua ส่วนมากรับ Lua table แปลงเป็น string[] ได้ จึงเก็บ table เป็น fallback ด้วย
    pcall(function()
        if CS ~= nil and CS.System ~= nil and CS.System.Array ~= nil and CS.System.String ~= nil and typeof ~= nil then
            arr = CS.System.Array.CreateInstance(typeof(CS.System.String), #values)
            for i, v in ipairs(values) do arr:SetValue(tostring(v), i-1) end
        end
    end)
    return arr or values
end

local function XaouWarp_TryCallWndStaticV37(wnd, method, args)
    local fn = nil
    pcall(function() if wnd ~= nil then fn = wnd[method] end end)
    if fn == nil then return false, "no "..tostring(method), nil end
    local tries = {}
    if #args == 1 then
        table.insert(tries, {"wnd."..method.."(a)", function() return wnd[method](args[1]) end})
        table.insert(tries, {"fn(a)", function() return fn(args[1]) end})
        table.insert(tries, {"wnd:"..method.."(a)", function() return wnd[method](wnd, args[1]) end})
    elseif #args == 2 then
        table.insert(tries, {"wnd."..method.."(a,b)", function() return wnd[method](args[1], args[2]) end})
        table.insert(tries, {"fn(a,b)", function() return fn(args[1], args[2]) end})
        table.insert(tries, {"wnd:"..method.."(a,b)", function() return wnd[method](wnd, args[1], args[2]) end})
    end
    local last = ""
    for _, t in ipairs(tries) do
        local ok, ret = pcall(t[2])
        if ok then return true, t[1], ret end
        last = t[1] .. " => " .. tostring(ret)
    end
    return false, last, nil
end

function Xaou_WarpSystem.OpenSelectNpc4MapV37(keyword)
    local lines = {"Open SelectNpc4Map v3.7", "ใช้หน้าต่างของเกม เพื่อให้เกมสร้าง List<Npc> เอง", ""}
    local pairs37 = XaouWarp_KnownWorldPairsV37(keyword)
    local wndList = XaouWarp_GetWndSelectNpc4MapV37()
    local worlds = {}
    local added = {}
    for _, wp in ipairs(pairs37) do
        if not added[wp.world] then
            table.insert(worlds, wp.world)
            added[wp.world] = true
        end
    end
    local arr = XaouWarp_MakeStringArrayV37(worlds)
    XaouWarp_LastV37World = worlds[1] or "RpgArena"
    XaouWarp_LastV37Place = pairs37[1] and pairs37[1].place or "Place_SouthMount"

    table.insert(lines, "Worlds="..table.concat(worlds, ", "))
    table.insert(lines, "Place fallback="..tostring(XaouWarp_LastV37Place))
    table.insert(lines, "Wnd candidates="..tostring(#wndList))

    -- ปลดล็อก world/place ก่อน เผื่อเกมซ่อนปุ่มถ้ายังไม่ปลด
    pcall(function()
        local targets = XaouWarp_GetRPGTargetsV36 and XaouWarp_GetRPGTargetsV36() or {}
        for _, tg in ipairs(targets) do
            for _, w in ipairs(worlds) do
                XaouWarp_CallMethodV35(tg.obj, "UnlockWorld", {w})
            end
        end
    end)
    pcall(function()
        if Xaou_WarpSystem.UnlockPlaceSafe ~= nil then Xaou_WarpSystem.UnlockPlaceSafe(XaouWarp_LastV37Place) end
    end)

    local success = false
    for _, w in ipairs(wndList) do
        table.insert(lines, "")
        table.insert(lines, "Wnd: "..tostring(w.label).." = "..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(w.obj) or tostring(w.obj)))
        local ok1, call1, ret1 = XaouWarp_TryCallWndStaticV37(w.obj, "ShowRPGWorld", {arr})
        table.insert(lines, "ShowRPGWorld: "..(ok1 and "OK " or "ERR ")..tostring(call1))
        if ok1 then success = true; break end
        local ok2, call2, ret2 = XaouWarp_TryCallWndStaticV37(w.obj, "ShowPlace", {XaouWarp_LastV37Place})
        table.insert(lines, "ShowPlace: "..(ok2 and "OK " or "ERR ")..tostring(call2))
        if ok2 then success = true; break end
    end

    table.insert(lines, "")
    if success then
        table.insert(lines, "ถ้าหน้าต่างเลือก NPC ของเกมเปิดขึ้น ให้เลือก NPC แล้วกดตกลง")
        table.insert(lines, "นี่คือทางที่ควรสำเร็จสุด เพราะเกมจะสร้าง List<Npc> เอง")
    else
        table.insert(lines, "ยังเปิดหน้าต่างไม่ได้ ส่ง error ช่วง ShowRPGWorld/ShowPlace มา")
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "Wnd v3.7")
    return success
end

local function XaouWarp_BuildRealNpcListV37()
    local out = {}
    local function add(label, obj) table.insert(out, {label=label, obj=obj}) end
    local candidates = {}
    local function addNpc(n)
        if n == nil then return end
        for _, x in ipairs(candidates) do if x == n then return end end
        table.insert(candidates, n)
    end
    addNpc(Xaou_CurrentNpcTarget)
    addNpc(me)
    pcall(function() addNpc(GameMain ~= nil and GameMain.SelectedThing or nil) end)
    pcall(function() addNpc(CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.GameMain ~= nil and CS.XiaWorld.GameMain.Instance ~= nil and CS.XiaWorld.GameMain.Instance.SelectedThing or nil) end)

    -- สร้าง List<Npc> ตาม signature จริง
    pcall(function()
        if CS and CS.System and CS.System.Collections and CS.System.Collections.Generic and CS.XiaWorld and CS.XiaWorld.Npc then
            local T = CS.System.Collections.Generic.List(CS.XiaWorld.Npc)
            local empty = T()
            add("List<Npc> empty", empty)
            for i, npc in ipairs(candidates) do
                local l = T()
                pcall(function() l:Add(npc) end)
                add("List<Npc> npc#"..tostring(i).." "..tostring(npc.Name or npc.DisplayName or npc), l)
            end
        end
    end)
    return out
end

function Xaou_WarpSystem.TestEnterRPGWorldV37(keyword)
    local lines = {"Direct EnterRPGWorld v3.7", "ใช้ List<Npc> จริงจาก me/target ถ้าสร้างได้", ""}
    local targets = XaouWarp_GetRPGTargetsV36 and XaouWarp_GetRPGTargetsV36() or {}
    local pairs37 = XaouWarp_KnownWorldPairsV37(keyword)
    local target = XaouWarp_LastV37Target
    if target == nil then
        for _, tg in ipairs(targets) do
            if XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil then target = tg.obj; break end
        end
    end
    local world = XaouWarp_LastV37World or (pairs37[1] and pairs37[1].world) or "RpgArena"
    local place = XaouWarp_LastV37Place or (pairs37[1] and pairs37[1].place) or "Place_SouthMount"
    table.insert(lines, "Target="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(target) or tostring(target)))
    table.insert(lines, "World="..tostring(world).."  p="..tostring(place))

    if target == nil then
        table.insert(lines, "ไม่พบ RPGMapMgr target")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.7")
        return false
    end

    pcall(function() XaouWarp_CallMethodV35(target, "UnlockWorld", {world}) end)
    local npcLists = XaouWarp_BuildRealNpcListV37()
    table.insert(lines, "NpcList candidates="..tostring(#npcLists))
    if #npcLists == 0 then
        table.insert(lines, "สร้าง List<Npc> ไม่ได้ ให้ใช้ปุ่ม เปิดเลือก NPC v3.7 ก่อน")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.7")
        return false
    end
    local pList = {tostring(place), "", tostring(world)}
    local attempt = 0
    for _, nc in ipairs(npcLists) do
        for _, p in ipairs(pList) do
            attempt = attempt + 1
            table.insert(lines, "#"..attempt.." "..tostring(nc.label).." p="..tostring(p))
            local ok, call, ret = XaouWarp_CallMethodV35(target, "EnterRPGWorld", {nc.obj, tostring(world), tostring(p)})
            table.insert(lines, "  "..(ok and "OK " or "ERR ")..tostring(call))
            table.insert(lines, "  ret="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(ret) or tostring(ret)))
            if ok then
                table.insert(lines, "")
                table.insert(lines, "ถ้าเกมโหลด/เปลี่ยนฉาก แปลว่าสำเร็จ")
                XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.7")
                return true
            end
            if attempt >= 10 then break end
        end
        if attempt >= 10 then break end
    end
    table.insert(lines, "")
    table.insert(lines, "ยังไม่สำเร็จ แนะนำใช้ปุ่ม เปิดเลือก NPC v3.7 เพราะเป็นเส้นทางเกมจริง")
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.7")
    return false
end

-- override tester v3.7
local Xaou_Old_TestTravelApi_v37 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "open_selectnpc_v37" then return Xaou_WarpSystem.OpenSelectNpc4MapV37(keyword) end
    if action == "enter_rpg_v37" then return Xaou_WarpSystem.TestEnterRPGWorldV37(keyword) end
    if Xaou_Old_TestTravelApi_v37 ~= nil then return Xaou_Old_TestTravelApi_v37(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end


-- ============================================================
-- Xaou Warp v3.8 - Direct Enter แบบไม่ใช้ List ว่าง
-- เป้าหมาย: แก้ค้างหลัง Saving โดยสร้าง List<Npc> ที่มี NPC จริงก่อนเรียก EnterRPGWorld
-- ============================================================
XaouWarp_LastV38World = XaouWarp_LastV38World or nil
XaouWarp_LastV38Place = XaouWarp_LastV38Place or nil

local function XaouWarp_GetNpcNameV38(npc)
    local name = nil
    pcall(function() if npc ~= nil then name = npc.DisplayName or npc.Name or npc.name end end)
    if name == nil then name = tostring(npc) end
    return tostring(name)
end

local function XaouWarp_ListCountV38(list)
    local c = nil
    pcall(function() if list ~= nil then c = list.Count end end)
    pcall(function() if c == nil and list ~= nil then c = list:Count() end end)
    return tonumber(c) or 0
end

local function XaouWarp_AddNpcCandidateV38(arr, npc, label)
    if npc == nil then return end
    for _, it in ipairs(arr) do
        if it.obj == npc then return end
    end
    table.insert(arr, {obj=npc, label=tostring(label or "npc")})
end

local function XaouWarp_AddNpcFromThingV38(arr, thing, label)
    if thing == nil then return end
    XaouWarp_AddNpcCandidateV38(arr, thing, label)
    -- บาง object เป็น wrapper/Thing จึงลอง field ที่อาจชี้ไป Npc จริง
    local fields = {"Npc", "npc", "NPC", "Thing", "thing", "Unit", "unit", "Actor", "actor", "Parent", "parent"}
    for _, f in ipairs(fields) do
        pcall(function()
            local v = thing[f]
            if v ~= nil and v ~= thing then XaouWarp_AddNpcCandidateV38(arr, v, tostring(label).."."..f) end
        end)
    end
end

local function XaouWarp_GetThingAtGridNpcV38(key)
    local obj = nil
    key = XaouWarp_ToNum(key)
    if key == nil then return nil end
    pcall(function()
        if Map ~= nil and Map.Things ~= nil and g_emThingType ~= nil and g_emThingType.Npc ~= nil then
            obj = Map.Things:GetThingAtGrid(key, g_emThingType.Npc)
        end
    end)
    pcall(function()
        if obj == nil and Map ~= nil and Map.Things ~= nil then
            obj = Map.Things:GetThingAtGrid(key)
        end
    end)
    return obj
end

local function XaouWarp_CollectNpcCandidatesV38()
    local arr = {}
    XaouWarp_AddNpcFromThingV38(arr, Xaou_CurrentNpcTarget, "Xaou_CurrentNpcTarget")
    XaouWarp_AddNpcFromThingV38(arr, me, "me")
    pcall(function() XaouWarp_AddNpcFromThingV38(arr, target, "target") end)
    pcall(function() if GameMain ~= nil then XaouWarp_AddNpcFromThingV38(arr, GameMain.SelectedThing, "GameMain.SelectedThing") end end)
    pcall(function()
        if CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.GameMain ~= nil and CS.XiaWorld.GameMain.Instance ~= nil then
            XaouWarp_AddNpcFromThingV38(arr, CS.XiaWorld.GameMain.Instance.SelectedThing, "CS.GameMain.SelectedThing")
            XaouWarp_AddNpcFromThingV38(arr, CS.XiaWorld.GameMain.Instance.Player, "CS.GameMain.Player")
            XaouWarp_AddNpcFromThingV38(arr, CS.XiaWorld.GameMain.Instance.PlayerNpc, "CS.GameMain.PlayerNpc")
        end
    end)

    -- ดึง NPC จากตำแหน่ง grid ที่รู้จัก เพราะ object ที่คลิกใน UI บางทีไม่ใช่ Npc ตรง ๆ
    local keys = {}
    local function addKey(k) k = XaouWarp_ToNum(k); if k ~= nil then table.insert(keys, k) end end
    addKey(XaouWarp_GetThingKey(Xaou_CurrentNpcTarget))
    addKey(XaouWarp_GetThingKey(me))
    pcall(function() addKey(XaouWarp_GetHomeKey()) end)
    pcall(function() if Map ~= nil then addKey(Map.BornCenter) end end)
    pcall(function() if Map ~= nil then addKey(Map.Center) end end)

    local size = XaouWarp_GetMapSize()
    for _, base in ipairs(keys) do
        local got = XaouWarp_GetThingAtGridNpcV38(base)
        XaouWarp_AddNpcFromThingV38(arr, got, "Map.Things key="..tostring(base))
        if size > 0 then
            local bx = base % size
            local by = math.floor(base / size)
            for dy=-2,2 do
                for dx=-2,2 do
                    local x, y = bx+dx, by+dy
                    if x >= 0 and y >= 0 and x < size and y < size then
                        local k = x + y * size
                        local obj = XaouWarp_GetThingAtGridNpcV38(k)
                        XaouWarp_AddNpcFromThingV38(arr, obj, "Map.Things near="..tostring(k))
                    end
                end
            end
        end
    end
    return arr
end

local function XaouWarp_BuildRealNpcListV38()
    local out = {}
    local npcCandidates = XaouWarp_CollectNpcCandidatesV38()
    local T = nil
    pcall(function()
        if CS and CS.System and CS.System.Collections and CS.System.Collections.Generic and CS.XiaWorld and CS.XiaWorld.Npc then
            T = CS.System.Collections.Generic.List(CS.XiaWorld.Npc)
        end
    end)
    if T == nil then return out, npcCandidates, "สร้างชนิด List<Npc> ไม่ได้" end

    for i, nc in ipairs(npcCandidates) do
        local l = nil
        local okAdd = false
        pcall(function()
            l = T()
            l:Add(nc.obj)
            okAdd = true
        end)
        local count = XaouWarp_ListCountV38(l)
        if okAdd and l ~= nil and count > 0 then
            table.insert(out, {label="List<Npc> + "..tostring(nc.label).." / "..XaouWarp_GetNpcNameV38(nc.obj).." Count="..tostring(count), obj=l, npc=nc.obj})
        end
    end
    return out, npcCandidates, nil
end

function Xaou_WarpSystem.TestEnterRPGWorldV38(keyword)
    local lines = {"Direct EnterRPGWorld v3.8", "ไม่ใช้ List ว่างแล้ว: ต้องมี NPC จริงอย่างน้อย 1 ตัว", ""}
    local targets = XaouWarp_GetRPGTargetsV36 and XaouWarp_GetRPGTargetsV36() or {}
    local pairs37 = XaouWarp_KnownWorldPairsV37 and XaouWarp_KnownWorldPairsV37(keyword) or {}
    local targetObj = XaouWarp_LastV37Target
    if targetObj == nil then
        for _, tg in ipairs(targets) do
            if XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil then targetObj = tg.obj; break end
        end
    end
    local world = XaouWarp_LastV38World or XaouWarp_LastV37World or (pairs37[1] and pairs37[1].world) or "RpgArena"
    local place = XaouWarp_LastV38Place or XaouWarp_LastV37Place or (pairs37[1] and pairs37[1].place) or "Place_SouthMount"
    XaouWarp_LastV38World = world
    XaouWarp_LastV38Place = place

    table.insert(lines, "Target="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(targetObj) or tostring(targetObj)))
    table.insert(lines, "World="..tostring(world))
    table.insert(lines, "p="..tostring(place))
    if targetObj == nil then
        table.insert(lines, "ไม่พบ RPGMapMgr target")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.8")
        return false
    end

    pcall(function() XaouWarp_CallMethodV35(targetObj, "UnlockWorld", {world}) end)
    pcall(function() if Xaou_WarpSystem.UnlockPlaceSafe ~= nil then Xaou_WarpSystem.UnlockPlaceSafe(place) end end)

    local npcLists, rawNpcs, err = XaouWarp_BuildRealNpcListV38()
    table.insert(lines, "Raw NPC candidates="..tostring(#(rawNpcs or {})))
    for i, nc in ipairs(rawNpcs or {}) do
        if i <= 8 then table.insert(lines, "  npc#"..i.." "..tostring(nc.label).." = "..XaouWarp_GetNpcNameV38(nc.obj)) end
    end
    table.insert(lines, "NpcList usable="..tostring(#npcLists))
    if err ~= nil then table.insert(lines, "List err="..tostring(err)) end
    if #npcLists <= 0 then
        table.insert(lines, "ยังไม่มี List<Npc> ที่มีสมาชิก")
        table.insert(lines, "ให้เลือกตัวละครในเกมก่อน หรือกดเปิดหน้าต่างเลือก NPC ของเกม")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.8")
        return false
    end

    -- v3.8: ลองเฉพาะ list ที่มี NPC จริงเท่านั้น ป้องกันค้างแบบ List ว่าง
    local pList = {tostring(place), "", tostring(world)}
    local attempt = 0
    for _, nc in ipairs(npcLists) do
        for _, p in ipairs(pList) do
            attempt = attempt + 1
            table.insert(lines, "#"..attempt.." "..tostring(nc.label).." p="..tostring(p))
            local ok, call, ret = XaouWarp_CallMethodV35(targetObj, "EnterRPGWorld", {nc.obj, tostring(world), tostring(p)})
            table.insert(lines, "  "..(ok and "OK " or "ERR ")..tostring(call))
            table.insert(lines, "  ret="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(ret) or tostring(ret)))
            if ok then
                table.insert(lines, "")
                table.insert(lines, "ถ้าขึ้นบันทึก/โหลด ให้รอดู ถ้าค้างอีก แปลว่า NPC ผ่านแล้วแต่ p/world ยังไม่ตรง")
                XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.8")
                return true
            end
            if attempt >= 6 then break end
        end
        if attempt >= 6 then break end
    end
    table.insert(lines, "ยังไม่สำเร็จ ส่ง error v3.8 มา")
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.8")
    return false
end

-- override tester v3.8: ให้ปุ่ม Direct Enter v3.7 เดิมเรียกตัวใหม่ เพื่อไม่ต้องแก้ UI มาก
local Xaou_Old_TestTravelApi_v38 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "enter_rpg_v37" or action == "enter_rpg_v38" then return Xaou_WarpSystem.TestEnterRPGWorldV38(keyword) end
    if Xaou_Old_TestTravelApi_v38 ~= nil then return Xaou_Old_TestTravelApi_v38(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end


-- ============================================================
-- Xaou Warp v3.9 - Safe Direct Enter: ไม่ส่ง Place_SouthMount เป็น p ก่อน
-- เหตุผล: v3.8 เรียกสำเร็จจนเกมขึ้นบันทึก แต่ค้าง เพราะ p=Place อาจไม่ใช่ค่า spawn ที่ถูก
-- รอบนี้ใช้ NPC จริง 1 ตัว และลอง EnterRPGWorld(npcs, world) / p=nil / p="" แบบสั้น ๆ
-- ============================================================
local function XaouWarp_PickBestNpcListV39()
    local npcLists, rawNpcs, err = XaouWarp_BuildRealNpcListV38()
    if npcLists == nil then npcLists = {} end
    -- เลือก candidate แรกที่ v3.8 สร้างเป็น List<Npc> ได้ โดยไม่วนหลายตัวเพื่อกันค้าง
    return npcLists[1], npcLists, rawNpcs or {}, err
end

function Xaou_WarpSystem.TestEnterRPGWorldV39(keyword)
    local lines = {"Direct EnterRPGWorld v3.9", "แก้จาก v3.8: ไม่ส่ง Place เป็น p รอบแรก", ""}
    local targets = XaouWarp_GetRPGTargetsV36 and XaouWarp_GetRPGTargetsV36() or {}
    local pairs37 = XaouWarp_KnownWorldPairsV37 and XaouWarp_KnownWorldPairsV37(keyword) or {}
    local targetObj = XaouWarp_LastV37Target
    if targetObj == nil then
        for _, tg in ipairs(targets) do
            if XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil then targetObj = tg.obj; break end
        end
    end

    local world = XaouWarp_LastV38World or XaouWarp_LastV37World or (pairs37[1] and pairs37[1].world) or "RpgArena"
    local place = XaouWarp_LastV38Place or XaouWarp_LastV37Place or (pairs37[1] and pairs37[1].place) or "Place_SouthMount"
    XaouWarp_LastV38World = world
    XaouWarp_LastV38Place = place

    table.insert(lines, "Target="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(targetObj) or tostring(targetObj)))
    table.insert(lines, "World="..tostring(world))
    table.insert(lines, "Place เก็บไว้เฉย ๆ="..tostring(place))
    if targetObj == nil then
        table.insert(lines, "ไม่พบ RPGMapMgr target")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.9")
        return false
    end

    pcall(function() XaouWarp_CallMethodV35(targetObj, "UnlockWorld", {world}) end)
    pcall(function() if Xaou_WarpSystem.UnlockPlaceSafe ~= nil then Xaou_WarpSystem.UnlockPlaceSafe(place) end end)

    local best, npcLists, rawNpcs, err = XaouWarp_PickBestNpcListV39()
    table.insert(lines, "Raw NPC candidates="..tostring(#rawNpcs))
    for i, nc in ipairs(rawNpcs) do
        if i <= 5 then table.insert(lines, "  npc#"..i.." "..tostring(nc.label).." = "..XaouWarp_GetNpcNameV38(nc.obj)) end
    end
    table.insert(lines, "NpcList usable="..tostring(#npcLists))
    if err ~= nil then table.insert(lines, "List err="..tostring(err)) end
    if best == nil or best.obj == nil then
        table.insert(lines, "ยังไม่มี List<Npc> ที่ใช้ได้")
        XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.9")
        return false
    end

    table.insert(lines, "ใช้ NPCList="..tostring(best.label))
    table.insert(lines, "")
    table.insert(lines, "รอบนี้จะลองแบบปลอดภัย:")
    table.insert(lines, "1) EnterRPGWorld(npcs, world)  ไม่ส่ง p")
    table.insert(lines, "ถ้าขึ้นบันทึกแล้วโหลดผ่าน = สำเร็จ")
    table.insert(lines, "ถ้าค้างอีก ให้ปิดเกมแล้วกลับมาบอกจ้า")
    XaouWarp_Msg(table.concat(lines, "\n"), "Enter v3.9")

    -- หน่วงเล็กน้อยให้ผู้เล่นอ่านข้อความก่อน แล้วค่อยเรียกจริง
    local function doCall()
        local ok, call, ret = XaouWarp_CallMethodV35(targetObj, "EnterRPGWorld", {best.obj, tostring(world)})
        if not ok then
            local lines2 = {"Direct EnterRPGWorld v3.9", "แบบ 2 args ไม่ผ่าน จึงลอง p ว่าง", "", tostring(call), tostring(ret)}
            local ok2, call2, ret2 = XaouWarp_CallMethodV35(targetObj, "EnterRPGWorld", {best.obj, tostring(world), ""})
            table.insert(lines2, "")
            table.insert(lines2, (ok2 and "OK " or "ERR ")..tostring(call2))
            table.insert(lines2, "ret="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(ret2) or tostring(ret2)))
            XaouWarp_Msg(table.concat(lines2, "\n"), "Enter v3.9")
        end
    end
    pcall(function()
        if CS and CS.XiaWorld and CS.XiaWorld.World and CS.XiaWorld.World.Instance and CS.XiaWorld.World.Instance.DelayCall then
            CS.XiaWorld.World.Instance:DelayCall(0.2, doCall)
        else
            doCall()
        end
    end)
    return true
end

local Xaou_Old_TestTravelApi_v39 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if action == "enter_rpg_v37" or action == "enter_rpg_v38" or action == "enter_rpg_v39" then return Xaou_WarpSystem.TestEnterRPGWorldV39(keyword) end
    if Xaou_Old_TestTravelApi_v39 ~= nil then return Xaou_Old_TestTravelApi_v39(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end

-- ============================================================
-- Xaou Warp v4.0 - Button Matrix Tester
-- กดทีละปุ่ม: world / p / NPC source / unlock/noUnlock
-- ============================================================
local function XaouWarp_V40GetTarget()
    local targetObj = XaouWarp_LastV37Target
    if targetObj ~= nil then return targetObj end
    local targets = XaouWarp_GetRPGTargetsV36 and XaouWarp_GetRPGTargetsV36() or {}
    for _, tg in ipairs(targets) do
        if XaouWarp_FieldV35 ~= nil and XaouWarp_FieldV35(tg.obj, "EnterRPGWorld") ~= nil then return tg.obj end
    end
    return nil
end

local function XaouWarp_V40BuildNpcByIndex(idx)
    idx = tonumber(idx or 1) or 1
    local npcLists, rawNpcs, err = XaouWarp_BuildRealNpcListV38()
    npcLists = npcLists or {}
    rawNpcs = rawNpcs or {}
    local picked = npcLists[idx] or npcLists[1]
    return picked, npcLists, rawNpcs, err
end

local function XaouWarp_V40Unlock(targetObj, world, place)
    local lines = {}
    local okU, callU, retU = false, "", nil
    if targetObj ~= nil and XaouWarp_CallMethodV35 ~= nil then
        okU, callU, retU = XaouWarp_CallMethodV35(targetObj, "UnlockWorld", {tostring(world)})
        table.insert(lines, "UnlockWorld: "..(okU and "OK " or "ERR ")..tostring(callU).." => "..tostring(retU))
    end
    pcall(function()
        if Xaou_WarpSystem.UnlockPlaceSafe ~= nil and place ~= nil and tostring(place) ~= "" then
            Xaou_WarpSystem.UnlockPlaceSafe(tostring(place))
            table.insert(lines, "UnlockPlaceSafe: OK "..tostring(place))
        end
    end)
    return lines
end

local function XaouWarp_V40Spec(code)
    local t = {
        A1={world="RpgArena", p=nil, pMode="nil", unlock=true, npc=1},
        A2={world="RpgArena", p="", pMode="empty", unlock=true, npc=1},
        A3={world="RpgArena", p="RpgArena", pMode="world", unlock=true, npc=1},
        A4={world="RpgArena", p="Place_SouthMount", pMode="south", unlock=true, npc=1},
        A5={world="RpgArena", p="Place_BigBamboo", pMode="bamboo", unlock=true, npc=1},
        A6={world="RpgTower", p=nil, pMode="nil", unlock=true, npc=1},
        A7={world="RpgQianKun", p=nil, pMode="nil", unlock=true, npc=1},
        A8={world="RpgArena_YingTian", p=nil, pMode="nil", unlock=true, npc=1},
        B1={world="RpgArena", p="0", pMode="0", unlock=true, npc=1},
        B2={world="RpgArena", p="1", pMode="1", unlock=true, npc=1},
        B3={world="RpgArena", p="Default", pMode="Default", unlock=true, npc=1},
        B4={world="RpgArena", p="Main", pMode="Main", unlock=true, npc=1},
        B5={world="RpgTower", p="Place_SouthMount", pMode="south", unlock=true, npc=1},
        B6={world="RpgTower", p="RpgTower", pMode="world", unlock=true, npc=1},
        B7={world="RpgQianKun", p="RpgQianKun", pMode="world", unlock=true, npc=1},
        B8={world="RpgArena_YingTian", p="RpgArena_YingTian", pMode="world", unlock=true, npc=1},
        B9={world="RpgArena", p=nil, pMode="nil", unlock=false, npc=1},
        B10={world="RpgArena", p="", pMode="empty", unlock=false, npc=1},
        N1={world="RpgArena", p=nil, pMode="nil", unlock=true, npc=1},
        N2={world="RpgArena", p=nil, pMode="nil", unlock=true, npc=2},
        N3={world="RpgArena", p=nil, pMode="nil", unlock=true, npc=3},
        N4={world="RpgArena", p=nil, pMode="nil", unlock=true, npc=4},
        N5={world="RpgArena", p=nil, pMode="nil", unlock=true, npc=5},
        N6={world="RpgTower", p=nil, pMode="nil", unlock=true, npc=1},
        N7={world="RpgQianKun", p=nil, pMode="nil", unlock=true, npc=1},
        N8={world="RpgArena_YingTian", p=nil, pMode="nil", unlock=true, npc=1},
        P1={world="RpgArena", p=nil, pMode="nil", unlock=true, npc=1},
        P2={world="RpgArena", p="Place_SouthMount", pMode="south", unlock=true, npc=1},
    }
    return t[tostring(code or "")]
end

local function XaouWarp_V40Info()
    local lines = {"Warp v4.0 Candidate Info", "ไม่เรียก EnterRPGWorld แค่ตรวจข้อมูล", ""}
    local targetObj = XaouWarp_V40GetTarget()
    table.insert(lines, "Target="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(targetObj) or tostring(targetObj)))
    local picked, npcLists, rawNpcs, err = XaouWarp_V40BuildNpcByIndex(1)
    table.insert(lines, "Raw NPC candidates="..tostring(#rawNpcs))
    for i, nc in ipairs(rawNpcs) do
        if i <= 12 then table.insert(lines, "npc#"..i.." "..tostring(nc.label).." = "..XaouWarp_GetNpcNameV38(nc.obj)) end
    end
    table.insert(lines, "NpcList usable="..tostring(#npcLists))
    for i, nc in ipairs(npcLists) do
        if i <= 8 then table.insert(lines, "list#"..i.." "..tostring(nc.label)) end
    end
    if err ~= nil then table.insert(lines, "err="..tostring(err)) end
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp v4.0 Info")
    return true
end

local function XaouWarp_V40UnlockAll()
    local lines = {"Warp v4.0 Unlock", "ปลดล็อก world/place ที่รู้จัก", ""}
    local targetObj = XaouWarp_V40GetTarget()
    local pairs = {
        {"RpgArena", "Place_SouthMount"}, {"RpgArena", "Place_BigBamboo"},
        {"RpgArena_YingTian", "Place_SouthMount"}, {"RpgTower", "Place_YiJieLieFeng"},
        {"RpgQianKun", "Place_QianKun"}, {"RpgTower", "Place_BigBamboo"},
    }
    for _, p in ipairs(pairs) do
        table.insert(lines, "- "..p[1].." / "..p[2])
        local ls = XaouWarp_V40Unlock(targetObj, p[1], p[2])
        for _, x in ipairs(ls) do table.insert(lines, "  "..x) end
        if #lines > 30 then break end
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp v4.0 Unlock")
    return true
end

local function XaouWarp_V40Check(code)
    local lines = {"Warp v4.0 Check", "ตรวจอย่างเดียว ไม่เรียกเข้าโลก", ""}
    local targetObj = XaouWarp_V40GetTarget()
    table.insert(lines, "Target="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(targetObj) or tostring(targetObj)))
    local tests = {{"RpgArena","Place_SouthMount"},{"RpgTower","Place_YiJieLieFeng"},{"RpgQianKun","Place_QianKun"},{"RpgArena_YingTian","Place_SouthMount"},{"RpgArena","Place_BigBamboo"}}
    for _, it in ipairs(tests) do
        local w, p = it[1], it[2]
        table.insert(lines, "- "..w.." / "..p)
        if targetObj ~= nil and XaouWarp_CallMethodV35 ~= nil then
            local okI, callI, retI = XaouWarp_CallMethodV35(targetObj, "IsWorldUnlock", {w})
            table.insert(lines, "  IsUnlock="..(okI and "OK " or "ERR ")..tostring(retI))
            local okG, callG, retG = XaouWarp_CallMethodV35(targetObj, "GetWorldsInPlace", {p})
            table.insert(lines, "  GetWorlds="..(okG and "OK " or "ERR ")..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(retG) or tostring(retG)))
        end
    end
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp v4.0 Check")
    return true
end

function Xaou_WarpSystem.TestWarpV40(action, keyword)
    local code = tostring(action or ""):gsub("warp_v40_", "")
    if code == "INFO" or code == "NPCINFO" then return XaouWarp_V40Info() end
    if code == "UNLOCK" then return XaouWarp_V40UnlockAll() end
    if code == "P3" or code == "P4" or code == "P5" then return XaouWarp_V40Check(code) end
    local spec = XaouWarp_V40Spec(code)
    if spec == nil then
        XaouWarp_Msg("ยังไม่มีชุดทดสอบสำหรับ action="..tostring(action), "Warp v4.0")
        return false
    end

    local lines = {"Warp v4.0 Test "..code, "กดทีละปุ่ม ถ้าค้างให้จำรหัสปุ่มนี้ไว้", ""}
    local targetObj = XaouWarp_V40GetTarget()
    table.insert(lines, "Target="..(XaouWarp_SafeStrV35 and XaouWarp_SafeStrV35(targetObj) or tostring(targetObj)))
    table.insert(lines, "World="..tostring(spec.world))
    table.insert(lines, "pMode="..tostring(spec.pMode).." p="..tostring(spec.p))
    table.insert(lines, "unlock="..tostring(spec.unlock).." npcIndex="..tostring(spec.npc))
    if targetObj == nil then
        table.insert(lines, "ไม่พบ target EnterRPGWorld")
        XaouWarp_Msg(table.concat(lines, "\n"), "Warp v4.0")
        return false
    end

    local picked, npcLists, rawNpcs, err = XaouWarp_V40BuildNpcByIndex(spec.npc)
    table.insert(lines, "RawNPC="..tostring(#rawNpcs).." ListNPC="..tostring(#npcLists))
    if picked ~= nil then table.insert(lines, "Use="..tostring(picked.label)) end
    if err ~= nil then table.insert(lines, "ListErr="..tostring(err)) end
    if picked == nil or picked.obj == nil then
        table.insert(lines, "ไม่มี List<Npc> ที่ใช้ได้")
        XaouWarp_Msg(table.concat(lines, "\n"), "Warp v4.0")
        return false
    end

    if spec.unlock then
        local ls = XaouWarp_V40Unlock(targetObj, spec.world, spec.p)
        for _, x in ipairs(ls) do table.insert(lines, x) end
    end
    table.insert(lines, "")
    table.insert(lines, "หลังปิดกล่องนี้จะลองเรียก EnterRPGWorld")
    table.insert(lines, "ถ้าเกมค้าง ให้บอกว่าค้างที่ปุ่ม "..code)
    XaouWarp_Msg(table.concat(lines, "\n"), "Warp v4.0 "..code)

    local function callEnter()
        if spec.p == nil then
            XaouWarp_CallMethodV35(targetObj, "EnterRPGWorld", {picked.obj, tostring(spec.world)})
        else
            XaouWarp_CallMethodV35(targetObj, "EnterRPGWorld", {picked.obj, tostring(spec.world), tostring(spec.p)})
        end
    end
    local delayed = false
    pcall(function()
        if CS and CS.XiaWorld and CS.XiaWorld.World and CS.XiaWorld.World.Instance and CS.XiaWorld.World.Instance.DelayCall then
            delayed = true
            CS.XiaWorld.World.Instance:DelayCall(0.3, callEnter)
        end
    end)
    if not delayed then pcall(callEnter) end
    return true
end

local Xaou_Old_TestTravelApi_v40 = Xaou_WarpSystem.TestTravelApi
function Xaou_WarpSystem.TestTravelApi(action, keyword)
    action = tostring(action or "")
    if string.sub(action, 1, 9) == "warp_v40_" then return Xaou_WarpSystem.TestWarpV40(action, keyword) end
    if Xaou_Old_TestTravelApi_v40 ~= nil then return Xaou_Old_TestTravelApi_v40(action, keyword) end
    XaouWarp_Msg("ไม่พบ TestTravelApi เดิม", "ระบบวาร์ป")
    return false
end
