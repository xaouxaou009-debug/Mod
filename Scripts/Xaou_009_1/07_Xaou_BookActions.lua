-- ============================================================
-- XAOU BOOK ACTIONS
-- ============================================================

function Xaou_BookGetActor()
    local target = nil
    if XaouItemWindow ~= nil then
        target = XaouItemWindow.npcTarget or target
    end
    if Xaou_CurrentNpcTarget ~= nil then
        target = target or Xaou_CurrentNpcTarget
    end
    if Xaou_GetRealNpcObject ~= nil then
        target = Xaou_GetRealNpcObject(target)
    end
    return target
end

function Xaou_BookTriggerStory(storyName)
    storyName = tostring(storyName or "")
    if storyName == "" then
        Xaou_BookShow("ไม่มี Story สำหรับคัมภีร์นี้", "คัมภีร์")
        return false
    end

    local actor = Xaou_BookGetActor()
    if actor == nil then
        Xaou_BookShow("ยังไม่ได้เลือก NPC\nให้เปิดจากปุ่ม NPC หรือเลือกตัวละครก่อน แล้วค่อยกดรับคัมภีร์", "คัมภีร์")
        return false
    end

    local ok, err = pcall(function()
        if actor.TriggerStory ~= nil then
            actor:TriggerStory(storyName)
            return
        end
        if CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.NpcLuaHelper ~= nil then
            local helper = CS.XiaWorld.NpcLuaHelper(actor)
            if helper ~= nil and helper.TriggerStory ~= nil then
                helper:TriggerStory(storyName)
                return
            end
        end
        error("TriggerStory not found")
    end)

    if not ok then
        Xaou_BookShow("เปิด Story ไม่สำเร็จ:\n" .. tostring(err), "คัมภีร์ Error")
        return false
    end
    return true
end

function Xaou_BookReceive(book)
    if book == nil then return false end
    return Xaou_BookTriggerStory(book.story)
end
