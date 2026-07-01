Xaou_xaou009 = GameMain:NewMod("Xaou009_ACS_Mod")

function Xaou_xaou009:OnInit()
end

function Xaou_xaou009:OnEnter()
self.nTotalTime = 0
self.nRemoteStorageID = nil
self.nRemoteStorageKey = nil
self.bSwitch = false
self.tbThing = nil
self.bBtnAdded = false
self:FindRemoteStorage()
end

function Xaou_xaou009:OnStep(nDeltaTime)
self.nTotalTime = self.nTotalTime + nDeltaTime

if self.nTotalTime >= 1 then  
    self.nTotalTime = 0  
    self:FindRemoteStorage()  
    self:DoAutoSleeve()  
end

end

function Xaou_xaou009:DoAutoSleeve()
if not self.bSwitch then
return
end

if self.nRemoteStorageKey == nil then  
    self:FindRemoteStorage()  
    return  
end  

local tbBuildingThing = ThingMgr:FindThingByID(self.nRemoteStorageID)  

if tbBuildingThing ~= nil and  
   tbBuildingThing.BuildingState == g_emBuildingState.Working then  
    Map:CollectToRemoteStorage(self.nRemoteStorageKey)  
end

end

function Xaou_xaou009:FindRemoteStorage()
local tbThingList = ThingMgr:GetThingList(g_emThingType.Building)

for _, tbThing in pairs(tbThingList) do  
    if tbThing.def ~= nil and  
       tbThing.def.Name == "Building_SleeveSpace" then  

        self.nRemoteStorageID = tbThing.ID  
        self.nRemoteStorageKey = tbThing.Key  
        self.tbThing = tbThing  

        if not self.bBtnAdded then  
            tbThing:RemoveBtnData("เปิด")  
            tbThing:RemoveBtnData("ปิด")  
            tbThing:AddBtnData(  
                "เปิด",  
                "res/Sprs/ui/icon_hand",  
                "Xaou_xaou009:Switch()",  
                "ระบบเก็บอัตโนมัติปิดอยู่ คลิกเพื่อเปิด"  
            )  
            self.bBtnAdded = true  
        end  

        return  
    end  
end

end

function Xaou_xaou009:Switch()
if self.tbThing == nil then
return
end

if self.bSwitch then  
    self.tbThing:RemoveBtnData("ปิด")  
    self.tbThing:AddBtnData(  
        "เปิด",  
        "res/Sprs/ui/icon_hand",  
        "Xaou_xaou009:Switch()",  
        "ระบบเก็บอัตโนมัติปิดอยู่ คลิกเพื่อเปิด"  
    )  
    self.bSwitch = false  
else  
    self.tbThing:RemoveBtnData("เปิด")  
    self.tbThing:AddBtnData(  
        "ปิด",  
        "res/Sprs/ui/icon_hand",  
        "Xaou_xaou009:Switch()",  
        "ระบบเก็บอัตโนมัติเปิดอยู่ คลิกเพื่อหยุด"  
    )  
    self.bSwitch = true  
    self:DoAutoSleeve()  
end

end