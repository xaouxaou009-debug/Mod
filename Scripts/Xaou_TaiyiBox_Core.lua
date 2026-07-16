-- Opens Taiyi reward boxes on the current map using the original story reward APIs.

local XTB_BOX_STORIES = {
    Item_E_FaBaoBox = "Story_Item_E_FaBaoBox",
    Item_E_DanBox = "Story_Item_E_DanBox",
    Item_E_MiJiBox = "Story_Item_E_MiJiBox",
    Item_E_FuBox = "Story_Item_E_FuBox",
}

local function xtb_t(thai, english)
    if Xaou_IsEnglish and Xaou_IsEnglish() then return english or thai end
    return thai
end

local function xtb_show(text)
    pcall(function() world:ShowMsgBox(tostring(text or "")) end)
end

local function xtb_count(list)
    if list == nil then return 0 end
    local value = nil
    pcall(function() value = list.Count end)
    if value == nil then pcall(function() value = list:get_Count() end) end
    return tonumber(value) or 0
end

local function xtb_item(list, index)
    if list == nil then return nil end
    local value = nil
    pcall(function() value = list:get_Item(index) end)
    if value == nil then pcall(function() value = list[index] end) end
    return value
end

local function xtb_select_index(result)
    local direct = tonumber(result)
    if direct ~= nil then return direct end
    if xtb_count(result) > 0 then return tonumber(xtb_item(result, 0)) end
    return nil
end

local function xtb_real_npc(npc)
    if Xaou_GetRealNpcObject then
        local ok, value = pcall(function() return Xaou_GetRealNpcObject(npc) end)
        if ok and value ~= nil then return value end
    end
    local real = npc
    pcall(function() if npc.npcObj ~= nil then real = npc.npcObj end end)
    return real
end

local function xtb_def_name(item)
    local name = nil
    pcall(function() name = item.def.Name end)
    if name == nil then pcall(function() name = item.DefName end) end
    return name ~= nil and tostring(name) or nil
end

local function xtb_is_on_map(item)
    if item == nil then return false end
    local valid = true
    pcall(function() valid = item.IsValid end)
    if valid == false then return false end

    local at_ground = nil
    pcall(function() at_ground = item.AtG end)
    if at_ground == false then return false end

    local owner = 0
    pcall(function() owner = tonumber(item.InWhoseBag) or 0 end)
    return owner <= 0
end

local function xtb_scan()
    local mgr = nil
    pcall(function() mgr = CS.XiaWorld.ThingMgr.Instance end)
    if mgr == nil then return nil, xtb_t("ไม่พบ ThingMgr.Instance", "ThingMgr.Instance was not found") end

    local list = nil
    local ok = pcall(function() list = mgr:GetThingList(CS.XiaWorld.g_emThingType.Item) end)
    if not ok or list == nil then
        pcall(function() list = mgr:GetThingList(2) end)
    end
    if list == nil then return nil, xtb_t("อ่านรายการไอเทมบนแผนที่ไม่ได้", "Could not read map items") end

    local boxes = {}
    for i = 0, xtb_count(list) - 1 do
        local item = xtb_item(list, i)
        local name = xtb_def_name(item)
        if name ~= nil and XTB_BOX_STORIES[name] ~= nil and xtb_is_on_map(item) then
            boxes[#boxes + 1] = { item = item, name = name, story = XTB_BOX_STORIES[name] }
        end
    end
    return boxes, nil
end

local function xtb_remove(mgr, item)
    local ok, value = pcall(function() return mgr:RemoveThing(item, false, false) end)
    if ok and value ~= false then return true end
    ok, value = pcall(function() return mgr:RemoveThing(item) end)
    return ok and value ~= false
end

local function xtb_open_reward(entry, npc, story_mgr)
    local helper = nil
    pcall(function() helper = npc.LuaHelper end)
    if helper == nil then return false, "Npc.LuaHelper=nil" end

    local story_def = nil
    pcall(function() story_def = story_mgr:GetStoryDef(entry.story) end)
    if story_def == nil then return false, "StoryDef=nil: " .. tostring(entry.story) end

    local ok, err = pcall(function()
        if entry.name == "Item_E_FaBaoBox" then
            helper:DropFabao(0, "Item_WeaponSword", nil, nil, nil, 0.95, helper:RandomInt(1, 5))
            helper:DropFabao(0, "Item_WeaponSword", nil, nil, nil, 0.95, helper:RandomInt(1, 5))
            helper:DropFabao(0, "Item_WeaponSword", nil, nil, nil, 0.95, helper:RandomInt(6, 8))
        elseif entry.name == "Item_E_DanBox" then
            helper:DropAwardItemFromCache(story_def.ItemCache4, 1)
            helper:DropAwardItemFromCache(story_def.ItemCache4, 1)
            helper:DropAwardItemFromCache(story_def.ItemCache4, 1)
            helper:DropAwardItem("Item_Dan_ExtremeLofty", 1)
        elseif entry.name == "Item_E_MiJiBox" then
            helper:DropEsotericFromCache(story_def.ItemCache, 1)
            helper:DropEsotericFromCache(story_def.ItemCache, 1)
            helper:DropRandomItem("Esoterica")
            helper:DropEsoteric("SeachSoul")
        elseif entry.name == "Item_E_FuBox" then
            helper:DropSpell(1, "Spell_RecoveryPower", 0.95)
            helper:DropSpell(1, "Spell_GlobalEfficiency", 0.95)
            helper:DropSpell(1, "Spell_VisionRadius", 0.95)
            helper:DropSpell(1, "Spell_MoveSpeed2", 0.95)
        else
            error("Unsupported box: " .. tostring(entry.name))
        end
    end)
    return ok, err
end

function Xaou_OpenAllTaiyiBoxes(npc)
    local target = xtb_real_npc(npc)
    if target == nil then
        return false, xtb_t("กรุณาเลือก NPC ก่อน", "Please select an NPC first")
    end

    local boxes, scan_error = xtb_scan()
    if boxes == nil then return false, scan_error end
    if #boxes == 0 then
        return false, xtb_t("ไม่พบกล่องไท่อี้บนแผนที่", "No Taiyi boxes were found on the map")
    end

    local thing_mgr, story_mgr = nil, nil
    pcall(function() thing_mgr = CS.XiaWorld.ThingMgr.Instance end)
    pcall(function() story_mgr = CS.XiaWorld.MapStoryMgr.Instance end)
    if thing_mgr == nil or story_mgr == nil then
        return false, xtb_t("ไม่พบระบบกล่องของเกม", "The game's box system was not found")
    end

    local opened, removed, failed = 0, 0, 0
    local errors = {}
    for _, entry in ipairs(boxes) do
        local ok, detail = xtb_open_reward(entry, target, story_mgr)
        if ok then
            opened = opened + 1
            if xtb_remove(thing_mgr, entry.item) then
                removed = removed + 1
            else
                failed = failed + 1
                errors[#errors + 1] = entry.name .. ": RemoveThing failed"
            end
        else
            failed = failed + 1
            errors[#errors + 1] = entry.name .. ": " .. tostring(detail)
        end
    end

    local summary = xtb_t(
        "พบ " .. #boxes .. " กล่อง | เปิดสำเร็จ " .. opened .. " | ลบกล่อง " .. removed,
        "Found " .. #boxes .. " | Opened " .. opened .. " | Removed " .. removed
    )
    if failed > 0 then summary = summary .. xtb_t(" | ล้มเหลว ", " | Failed ") .. failed end
    return failed == 0 and opened > 0, summary, errors
end

function Xaou_ConfirmOpenAllTaiyiBoxes(npc)
    local boxes, scan_error = xtb_scan()
    if boxes == nil then xtb_show(scan_error); return false end
    if #boxes == 0 then
        xtb_show(xtb_t("ไม่พบกล่องไท่อี้บนแผนที่", "No Taiyi boxes were found on the map"))
        return false
    end

    local helper = nil
    pcall(function() helper = CS.WorldLuaHelper() end)
    if helper == nil then
        xtb_show(xtb_t("เปิดหน้าต่างยืนยันไม่ได้", "Could not open the confirmation window"))
        return false
    end

    local prompt = xtb_t(
        "Xaou 009\nพบกล่องไท่อี้ " .. #boxes .. " กล่อง\nต้องการเปิดทั้งหมดใช่ไหม?",
        "Xaou 009\nFound " .. #boxes .. " Taiyi boxes.\nOpen all of them?"
    )
    helper:ShowSelectBox(prompt, { xtb_t("ยืนยัน", "Confirm") }, 1, 1, function(result)
        if xtb_select_index(result) ~= 0 then return end
        local ok, success, summary = pcall(function()
            return Xaou_OpenAllTaiyiBoxes(npc)
        end)
        if not ok then
            xtb_show(xtb_t("เปิดกล่องไม่สำเร็จ\n", "Failed to open boxes\n") .. tostring(success))
        else
            xtb_show(summary or (success and xtb_t("เปิดกล่องสำเร็จแล้ว", "Boxes opened successfully") or xtb_t("เปิดกล่องไม่สำเร็จ", "Failed to open boxes")))
        end
    end)
    return true
end
