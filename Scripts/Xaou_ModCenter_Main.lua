-- NPC data and action services must load before the standalone UI reads them.
pcall(require, 'Scripts/Xaou_NpcHelper.lua')
pcall(require, 'Scripts/Xaou_NpcActions.lua')
pcall(require, 'Scripts/Xaou_NpcCommands.lua')
pcall(require, 'Scripts/Xaou_LearnFullGong_Core.lua')
pcall(require, 'Scripts/Xaou_LibraryLearn_Core.lua')
pcall(require, 'Scripts/Xaou_LearnWindow.lua')
pcall(require, 'Scripts/Xaou_BulkEsoterica_Core.lua')
pcall(require, 'Scripts/Xaou_BulkEsoterica_Window.lua')
pcall(require, 'Scripts/Xaou_BookMenu_Core.lua')
pcall(require, 'Scripts/Xaou_BookMenu_Window.lua')
pcall(require, 'Scripts/Xaou_WorldTools_Core.lua')
pcall(require, 'Scripts/Xaou_WorldTools_Window.lua')
pcall(require, 'Scripts/Xaou_Temperature_Window.lua')
pcall(require, 'Scripts/XaouBossSummonWindow.lua')
pcall(require, 'Scripts/Xaou_ModCenter_Window.lua')
pcall(require, 'Scripts/Xaou_NpcManager_Window.lua')
pcall(require, 'Scripts/Xaou_JianghuRelations_Ready.lua')

local XaouModCenterStandalone = GameMain:NewMod("XaouModCenterStandalone")

function XaouModCenterStandalone:OnEnter()
    local event = GameMain:GetMod("_Event")
    event:RegisterEvent(g_emEvent.SelectNpc, function(evt, npc, objs)
        if npc ~= nil and npc.ThingType == g_emThingType.Npc then
            npc:RemoveBtnData("Xaou")
            npc:AddBtnData(
                "Xaou",
                "res/Sprs/ui/icon_hand",
                "GameMain:GetMod('XaouModCenterStandalone'):Open(bind)",
                "เปิดศูนย์รวมเครื่องมือของ Xaou",
                nil
            )
        end
    end, "XaouModCenterStandalone_SelectNpc")
end

function XaouModCenterStandalone:Open(npc)
    if Xaou_OpenStandaloneModCenter ~= nil then
        local ok, value = pcall(function() return Xaou_OpenStandaloneModCenter(npc) end)
        if ok and value ~= false then return end
        pcall(function() world:ShowMsgBox("เปิด Xaou Mod Center ไม่สำเร็จ\n" .. tostring(value)) end)
    end
end
