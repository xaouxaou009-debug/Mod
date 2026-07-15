local modifierScript = GameMain:GetMod("_ModifierScript")
local modifierClass = modifierScript:GetModifier("modifier_yinyangshuangyu")

function modifierClass:Enter(modifier, npc)
    local info = {
        KC = "Npc",
        Line = {StartObj = npc},
        HeadMsg = "กรุณาเลือก NPC หนึ่งตัวที่ต้องการชุบชีวิต",
        Apply = function(_, map, key, mode)
            xlua.private_accessible(CS.XiaWorld.Npc)
            xlua.private_accessible(CS.XiaWorld.NpcBodyData)
            local target = mode:GetThing(g_emThingType.Npc, key, map)
            target.HealthState = CS.XiaWorld.g_emNpcHealthState.Normal
            target.IsCorpse = false
            target.PropertyMgr.BodyData:RemoveAllDamange()
            target.PropertyMgr.BodyData:BuildBody()
            target.PropertyMgr.BodyData.HealthValue = 300
            target.PropertyMgr.BodyData.Dead = false
            target.PropertyMgr.BodyData.Dying = false
        end,
        Check = function(_, map, key, mode)
            local target = mode:GetThing(g_emThingType.Npc, key, map)
            return target ~= nil and target.ThingType == g_emThingType.Npc
        end,
    }

    world:EnterUILuaMode("TableCtrl", info)
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
