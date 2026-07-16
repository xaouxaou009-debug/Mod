-- Xaou 009 instant pet growth. Uses the game's persisted age/growth APIs.

local function xpg_t(thai, english)
    if Xaou_IsEnglish and Xaou_IsEnglish() then return english end
    return thai
end

local function xpg_message(thai, english)
    local message = xpg_t(thai, english)
    if world and world.ShowMsgBox then
        pcall(function() world:ShowMsgBox(message) end)
        return
    end
    pcall(function() CS.Wnd_Message.Show(message) end)
end

local function xpg_real_npc(target)
    if target == nil then return nil end
    if Xaou_GetRealNpcObject then
        local ok, value = pcall(function() return Xaou_GetRealNpcObject(target) end)
        if ok and value ~= nil then return value end
    end
    local real = target
    pcall(function()
        if target.npcObj ~= nil then real = target.npcObj end
    end)
    return real
end

local function xpg_is_animal(npc)
    if npc == nil then return false end
    local isLingShou = false
    pcall(function() isLingShou = npc.IsLingShou == true end)
    if isLingShou then return true end

    local raceType = nil
    pcall(function() raceType = npc.Race.RaceType end)
    if raceType == nil then return false end

    local animalEnum = nil
    pcall(function() animalEnum = g_emNpcRaceType.Animal end)
    if animalEnum == nil then
        pcall(function() animalEnum = CS.XiaWorld.g_emNpcRaceType.Animal end)
    end
    if animalEnum ~= nil and raceType == animalEnum then return true end

    local text = string.lower(tostring(raceType or ""))
    return text == "animal" or string.find(text, "animal", 1, true) ~= nil
end

function Xaou_InstantGrowPet(target)
    local npc = xpg_real_npc(target)
    if npc == nil then
        xpg_message("กรุณาเลือกสัตว์เลี้ยงก่อน", "Please select a pet first")
        return false, "no target"
    end
    if not xpg_is_animal(npc) then
        xpg_message("เป้าหมายนี้ไม่ใช่สัตว์เลี้ยง", "The selected target is not a pet")
        return false, "not an animal"
    end

    local isLingShou = false
    pcall(function() isLingShou = npc.IsLingShou == true end)

    if isLingShou then
        local before = nil
        local okRead, readError = pcall(function()
            before = tonumber(npc.LsInfo.GrowPercent)
        end)
        if not okRead or before == nil then
            xpg_message("อ่านค่าการเติบโตของสัตว์วิญญาณไม่ได้", "Could not read spirit pet growth")
            return false, readError
        end
        if before >= 100 then
            xpg_message("สัตว์เลี้ยงโตเต็มวัยอยู่แล้ว", "This pet is already fully grown")
            return true, "already adult"
        end

        local okGrow, growError = pcall(function()
            npc.LsInfo:AddP(npc, "GrowPercent", 100 - before)
        end)
        if not okGrow then
            xpg_message("ทำให้สัตว์วิญญาณโตไม่สำเร็จ", "Failed to grow the spirit pet")
            return false, growError
        end

        pcall(function() npc:RefreshLsPExtra("GrowPercent", 100, true) end)
        pcall(function()
            if npc.view ~= nil then npc.view.needUpdateMod = true end
        end)
        pcall(function() EventMgr.Instance:EventTrigger(g_emEvent.ThingUpdate, npc) end)
        xpg_message("สัตว์เลี้ยงโตเต็มวัยแล้ว", "Pet growth completed")
        return true, "spirit pet", before, 100
    end

    local age, adultAge = nil, nil
    local okRead, readError = pcall(function()
        age = tonumber(npc.PropertyMgr.Age)
        adultAge = tonumber(npc.Race.AdultAge)
    end)
    if not okRead or age == nil or adultAge == nil or adultAge <= 0 then
        xpg_message("อ่านข้อมูลอายุของสัตว์เลี้ยงไม่ได้", "Could not read the pet age")
        return false, readError
    end
    if age >= adultAge then
        xpg_message("สัตว์เลี้ยงโตเต็มวัยอยู่แล้ว", "This pet is already fully grown")
        return true, "already adult"
    end

    local okGrow, growError = pcall(function()
        npc.PropertyMgr:AddAge(adultAge - age, false)
    end)
    if not okGrow then
        xpg_message("ทำให้สัตว์เลี้ยงโตไม่สำเร็จ", "Failed to grow the pet")
        return false, growError
    end

    pcall(function()
        if npc.view ~= nil then npc.view.needUpdateMod = true end
    end)
    pcall(function() EventMgr.Instance:EventTrigger(g_emEvent.ThingUpdate, npc) end)
    xpg_message("สัตว์เลี้ยงโตเต็มวัยแล้ว", "Pet growth completed")
    return true, "animal", age, adultAge
end

