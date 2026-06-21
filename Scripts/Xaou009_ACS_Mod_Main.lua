require('Scripts/lib.lua')

-- Xaou_xaou009 / Xaou009_ACS_Mod_Main
local Xaou009_ACS_Mod_Main = GameMain:NewMod("Xaou009_ACS_Mod_Main")


local STORY_MODIFIER = "asstasst2"
local STORY_BOOK = "BookShop_Auto_Main"
local STORY_ITEM_SHOP = "ItemShop_Auto_Main"
local STORY_MONSTER = "asstasst5"
local STORY_ITEM_BROWSER = "ItemShop_Auto_Main"

function Xaou009_ACS_Mod_Main:OnEnter()
    print("Xaou009_ACS_Mod_Main OnEnter")
    self.mod_enable = true
    self.last_npc = nil

    local Event = GameMain:GetMod("_Event")

    Event:RegisterEvent(g_emEvent.SelectItem,
        function(evt, item, objs)
            self:AddBtn2Item(evt, item, objs)
        end,
        "Xaou009_ACS_Mod_Main_Item"
    )

    Event:RegisterEvent(g_emEvent.SelectNpc,
        function(evt, npc, objs)
            if npc ~= self.last_npc then
                self.last_npc = npc
                self:AddBtn2Npc(evt, npc, objs)
            end
        end,
        "Xaou009_ACS_Mod_Main_Npc"
    )

    if World ~= nil and World.GameMode == CS.XiaWorld.g_emGameMode.Fight then
        self.mod_enable = false
    end
end

-- =========================
-- ปุ่มบนไอเทม
-- =========================
function Xaou009_ACS_Mod_Main:AddBtn2Item(evt, thing, objs)
    if not self.mod_enable then
        return
    end

    if thing ~= nil and thing.ThingType == g_emThingType.Item then
        thing:RemoveBtnData("翻倍")
        thing:RemoveBtnData("คูน×2")
        thing:AddBtnData(
            "คูน×2",
            "res/Sprs/ui/icon_hand",
            "GameMain:GetMod('Xaou009_ACS_Mod_Main'):MultiItems(bind)",
            "เพิ่มจำนวนไอเทมเป็น 2 เท่า",
            nil
        )

        thing:RemoveBtnData("幽淬")
        thing:RemoveBtnData("หลอมอสูร")
        thing:AddBtnData(
            "หลอมอสูร",
            "res/Sprs/ui/icon_hand",
            "GameMain:GetMod('Xaou009_ACS_Mod_Main'):YouCuiItems(bind)",
            "ยกระดับคุณภาพไอเทมขึ้น 1 ขั้น โดยสำเร็จแน่นอน",
            nil
        )

        thing:RemoveBtnData("灵淬")
        thing:RemoveBtnData("หลอมจิต")
        thing:AddBtnData(
            "หลอมจิต",
            "res/Sprs/ui/icon_hand",
            "GameMain:GetMod('Xaou009_ACS_Mod_Main'):LingCuiItems(bind)",
            "หลอมจิตไอเทม 1 ครั้ง โดยสำเร็จแน่นอน",
            nil
        )

        if thing.IsFaBao == true then
            thing:RemoveBtnData("天劫")
            thing:RemoveBtnData("ทัณฑ์สวรรค์36")
            thing:AddBtnData(
                "ทัณฑ์สวรรค์36",
                "res/Sprs/ui/icon_hand",
                "GameMain:GetMod('Xaou009_ACS_Mod_Main'):TianJie(bind)",
                "ทำให้อาวุธวิเศษผ่านการชำระล้างด้วยทัณฑ์สวรรค์ 36 ชั้น",
                nil
            )
        end
    end
end

-- =========================
-- ฟังก์ชันเปิด Story เมนู
-- =========================
local function TriggerNpcStory(item, storyName)
    if item == nil then
        return
    end
    local helper = CS.XiaWorld.NpcLuaHelper(item)
    if helper ~= nil then
        helper:TriggerStory(storyName)
    end
end

function Xaou009_ACS_Mod_Main:asstasst2(item)
    
    TriggerNpcStory(item, STORY_MODIFIER)
end

function Xaou009_ACS_Mod_Main:OpenBook(item)
    TriggerNpcStory(item, STORY_BOOK)
end

function Xaou009_ACS_Mod_Main:OpenItemShop(item)
    TriggerNpcStory(item, STORY_ITEM_SHOP)
end

function Xaou009_ACS_Mod_Main:OpenMonster(item)
    TriggerNpcStory(item, STORY_MONSTER)
end

-- ถ้าอยากเข้าเมนู Item Browser ใหม่ ให้สร้าง Story ชื่อนี้ใน XML แล้วค่อยเปิดใช้ปุ่มนี้
function Xaou009_ACS_Mod_Main:OpenItemBrowser(item)
    if Xaou_OpenIconItemSpawner ~= nil then
        Xaou_OpenIconItemSpawner()
    end
end

-- เปิดหน้า NPC Control ของ UI ใหม่ พร้อมส่ง NPC ที่กดเลือกเข้าไป
function Xaou009_ACS_Mod_Main:OpenNpcControl(item)
    if Xaou_OpenNpcControl ~= nil then
        Xaou_OpenNpcControl(item)
    else
        TriggerNpcStory(item, STORY_MODIFIER)
    end
end

-- =========================
-- ปุ่มบน NPC
-- =========================
function Xaou009_ACS_Mod_Main:AddBtn2Npc(evt, thing, objs)
    if not self.mod_enable then
        return
    end

    if thing ~= nil and thing.ThingType == g_emThingType.Npc then
        thing:RemoveBtnData("Mod")
        thing:AddBtnData(
            "Mod",
            "Sprs/xaou03.png",
            "GameMain:GetMod('Xaou009_ACS_Mod_Main'):OpenNpcControl(bind)",
            "เปิดเมนูแก้ไข NPC แบบ UI ใหม่",
            nil
        )
        -- thing:RemoveBtnData("เมนูเก่า")
        -- thing:AddBtnData(
            -- "เมนูเก่า",
            -- "Sprs/xaou03.png",
            -- "GameMain:GetMod('Xaou009_ACS_Mod_Main'):asstasst2(bind)",
            -- "เปิดเมนูปรับค่าตัวละครแบบ Story เดิม",
            -- nil
        -- )

          -- thing:RemoveBtnData("เสกของ")
          -- thing:AddBtnData(
              -- "เสกของ",
              -- "Sprs/xaou01.png",
              -- "Xaou_OpenIconItemSpawner();",
              -- "เปิดเมนู Item Browser",
              -- nil
          --  )
        -- thing:RemoveBtnData("เพิ่มเติม")
        -- thing:AddBtnData(
           -- "เพิ่มเติม",
            -- "Sprs/xaou06.png",
            -- "GameMain:GetMod('Xaou009_ACS_Mod_Main'):OpenMonster(bind)",
            -- "เปิดเมนูเรียกฟังก์ชันเสริม",
            -- nil
        -- )
        -- thing:RemoveBtnData("เมนู")
        -- thing:AddBtnData(
            -- "เมนู",
            -- "Sprs/xaou06.png",
            -- "GameMain:GetMod('Xaou009_ACS_Mod_Main'):OpenBook(bind)",
            -- "เปิดเมนูเพื่อเลือกฟังก์ชั",
           -- nil
        -- )
    end
end

-- =========================
-- ฟังก์ชันแก้ไอเทม
-- =========================
function Xaou009_ACS_Mod_Main:MultiItems(item)
    if item ~= nil and item.Count ~= nil then
        local count = item.Count
        print("Count =", count)
        item:ChangeCount(count * 2)
    end
end

function Xaou009_ACS_Mod_Main:YouCuiItems(item)
    if item ~= nil and item.Rate ~= nil and item.Rate < 12 then
        item:SoulCrystalYouPowerUp(100)
    end
end

function Xaou009_ACS_Mod_Main:LingCuiItems(item)
    if item ~= nil then
        item:SoulCrystalLingPowerUp(100)
    end
end

function Xaou009_ACS_Mod_Main:FullLing(item)
    if item ~= nil and item.MaxLing ~= nil and item.LingV ~= nil then
        local iLing = item.MaxLing - item.LingV
        item:AddLing(iLing)
    end
end

function Xaou009_ACS_Mod_Main:TianJie(item)
    if item ~= nil and item.Fabao ~= nil then
        for i = 1, 36 do
            item.Fabao:AddGodCount(1)
        end
    end
end

