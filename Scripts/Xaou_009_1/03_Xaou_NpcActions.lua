-- ============================================================
-- XAOU NPC ACTIONSห
-- ============================================================

function Xaou_ApplyNpcActions(npc, actions)
    if npc == nil then
        Xaou_Show("ยังไม่ได้เลือก NPC\nให้กดปุ่มจากตัวละคร/NPC ก่อน", "NPC")
        return false
    end

    if type(actions) ~= "table" then return false end

    local ok, err = pcall(function()
        for _, a in ipairs(actions) do
            local kind = tostring(a.kind or "")

            if kind == "modifier" then
                local ok2, err2 = Xaou_TryModifierProperty(npc, a.prop, a.value)
                if not ok2 then error(err2) end

            elseif kind == "addmodifier" then
                local ok2, err2 = Xaou_TryAddModifier(npc, a.id or a.modifier)
                if not ok2 then error(err2) end

            elseif kind == "story" then
                local realNpc = Xaou_GetRealNpcObject(npc)
                local ok2, err2 = pcall(function()
                    if realNpc == nil or realNpc.TriggerStory == nil then error("TriggerStory not found") end
                    realNpc:TriggerStory(tostring(a.story or a.name or ""))
                end)
                if not ok2 then error(err2) end

            elseif kind == "raw" or kind == "lua" then
                local ok2, err2 = Xaou_RunRawCodeForNpc(npc, a.code)
                if not ok2 then error(err2) end

            elseif kind == "message" then
                Xaou_ActionMessage(a.text, a.title)

            elseif kind == "url" then
                local ok2, err2 = Xaou_OpenUrl(a.url)
                if not ok2 then error(err2) end

            elseif kind == "unlockgong" then
                local ok2, err2 = pcall(function()
                    local realNpc = Xaou_GetRealNpcObject(npc)
                    if realNpc ~= nil and realNpc.UnLockGong ~= nil then
                        realNpc:UnLockGong(tostring(a.gong or a.id))
                    else
                        world:UnLockGong(tostring(a.gong or a.id))
                    end
                end)
                if not ok2 then error(err2) end


            elseif kind == "randomgong" then                                                                                        -- เพิ่มฟังชั่น --
                local level = tonumber(a.level or 4) or 4
                local times = tonumber(a.times or 1) or 1
                local ok2, err2 = pcall(function()
                    for i = 1, times do
                        world:UnlockRandomGong(level)
                    end
                end)
                if not ok2 then error(err2) end

            elseif kind == "changetime" then
                local h = tonumber(a.hour or a.value or 11) or 11
                local ok2, err2 = pcall(function()
                    World:SetDay(World.YearDayCount, h, World.DayCount)
                end)
                if not ok2 then error(err2) end

            elseif kind == "enter_qiankun" then
                local realNpc = Xaou_GetRealNpcObject(npc)
                local ok2, err2 = pcall(function()
                    RPGMapMgr:EnterRPGWorld({realNpc.npcObj or realNpc}, "RpgQianKun")
                end)
                if not ok2 then error(err2) end

            elseif kind == "modfunc" then
                local ok2, err2 = pcall(function()
                    local mod = GameMain:GetMod(tostring(a.mod or "Xiu_Gai_Qi_761152306"))
                    if mod == nil then error("ไม่พบ Mod: " .. tostring(a.mod)) end
                    local fn = mod[tostring(a.func or "")]
                    if fn == nil then error("ไม่พบฟังก์ชัน: " .. tostring(a.func)) end
                    fn(mod)
                end)
                if not ok2 then error(err2) end

            else
                error("ไม่รู้จัก action kind: " .. tostring(kind))
            end
        end
    end)

    if not ok then
        Xaou_Show("ERROR ตอนใช้คำสั่ง:\n" .. tostring(err), "NPC Error")
        return false
    end
    return true
end



-- ปลดล็อกวิชาหลักทั้งหมด (ย้ายมาจากไฟล์หลัก)
function Xaou_UnlockAllMainGong(npc)
    local me = npc or Xaou_CurrentNpcTarget
    if me == nil then return false end

    local gongs = {
        "Gong_1_Shui","Gong_2_Mu","Gong_3_Jin","Gong_4_None",
        "Gong_5_Tu","Gong_6_Huo","Gong_7_Huo","Gong_8_Jin",
        "Gong_9_Mu","Gong_10_Huo","Gong_11_Tu","Gong_12_None",
        "Gong_13_None","Gong_DaNeng","Gong_LingShou","Gong_LOST",
        "Gong_YaoShou","God_Gong_1","God_Gong_2","God_Gong_3",
        "Body_Gong_1","Body_Gong_2","Body_Gong_3","Body_Gong_5"
    }
    

    for _, id in ipairs(gongs) do
        pcall(function()
            me:UnLockGong(id)
        end)
    end

    Xaou_Show("ปลดล็อกวิชาสายหลักทั้งหมดแล้ว", "NPC")
    return true
end
