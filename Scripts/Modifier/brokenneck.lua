local modifierScript = GameMain:GetMod("_ModifierScript")
local modifierClass = modifierScript:GetModifier("modifier_brokenneck")

function modifierClass:Enter(modifier, npc)
    local practice = npc.PropertyMgr.Practice

    if practice and practice.GodPracticeData then
        practice.GodPracticeData:MindStateLevelLevelUp()
    end

    if practice and practice.CurNeck then
        local neck = practice.CurNeck
        if neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.Gold
            and neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.Thunder
            and neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.God then
            practice:AddResource(CS.XiaWorld.g_emPracticeResourceType.Understand, 500)
            npc.LuaHelper:NeckBroken()
        end
    end
end

function modifierClass:Step(modifier, npc, dt)
end

function modifierClass:UpdateStack(modifier, npc, add)
end

function modifierClass:Leave(modifier, npc)
end

function modifierClass:OnGetSaveData()
    return nil
end

function modifierClass:OnLoadData(modifier, npc, data)
end
