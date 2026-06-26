local tbThing = GameMain:GetMod("ThingHelper"):GetThing("KongTiao_Building");

function tbThing:OnInit()
if self.Time == nil then
self.Time = 0;
end
if self.WenDu == nil then
self.WenDu = 20;
end
end

function tbThing:OnStep(dt)
    local it = self.it
    if it == nil then return end
    if it.BuildingState ~= g_emBuildingState.Working then return end
    if it.AtRoom == nil then return end

    self.Time = (self.Time or 0) + dt
    if self.Time < 2 then return end
    self.Time = 0

    xlua.private_accessible(CS.XiaWorld.AreaRoom)

    local target = tonumber(self.WenDu) or 20
    local roomTemp = it.AtRoom.m_fTemperatureWall or 0
    local gridCount = it.AtRoom.m_lisGrids.Count or 25

    local diff = target - roomTemp

    local power = diff * gridCount / 25

    if power > 500 then power = 500 end
    if power < -500 then power = -500 end

    it.def.Heat.RoomValue = power
end

function tbThing:OnPutDown()
self.it:RemoveBtnData("Set", nil, "bind.luaclass:GetTable():UseKongTiao()", "Adjust the temperature of the Incense Burner", nil);
self.it:AddBtnData("ตั้งค่า", nil, "bind.luaclass:GetTable():UseKongTiao()", "ตั้งค่าอุณหภูมิกระถางธูป", nil);
end

function tbThing:UseKongTiao()
    -- เปิด UI ใหม่ของ Xaou โดยตรงก่อน
    if Xaou_OpenKongTiaoWindow ~= nil then
        Xaou_OpenKongTiaoWindow(self)
        return
    end

    -- fallback ระบบ Window เดิม
    local xWindow = GameMain:GetMod("Windows"):GetWindow("KongTiaoWindow");
    xWindow:Hide();
    xWindow:SetUpData(self);
    xWindow:Show();
end
-- Xaou_009 Save Temperature System

function tbThing:setWenDu(WenDu)
    self.WenDu = tonumber(WenDu) or 20;
end



function tbThing:OnGetSaveData()
    return {
        WenDu = tonumber(self.WenDu) or 20,
        Time = tonumber(self.Time) or 0,
    };
end

function tbThing:OnLoadData(tbData)
    if tbData ~= nil then
        self.WenDu = tonumber(tbData.WenDu) or 20;
        self.Time = tonumber(tbData.Time) or 0;
    end
end