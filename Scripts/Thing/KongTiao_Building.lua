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

    local room = it.AtRoom
    if room == nil then return end

    -- ตรวจและรักษาอุณหภูมิอย่างต่อเนื่อง
    -- ต้องเขียนซ้ำถี่ ๆ เพราะเกมจะค่อย ๆ คืนค่าอุณหภูมิผนังกลับหา 0
    self.Time = (self.Time or 0) + (dt or 0)
    if self.Time < 0.1 then return end
    self.Time = 0

    if Xaou_KongTiao_PrivateReady ~= true then
        pcall(function()
            xlua.private_accessible(CS.XiaWorld.AreaRoom)
        end)
        Xaou_KongTiao_PrivateReady = true
    end

    local target = tonumber(self.WenDu) or 20
    local roomTemp = tonumber(room.m_fTemperatureWall) or target
    local diff = target - roomTemp

    -- ห้ามหยุดทำงานเมื่อถึงเป้าหมาย เพราะเกมจะค่อย ๆ ดึงค่ากลับไปหา 0
    -- เมื่อใกล้เป้าหมาย ให้เขียนค่าเป้าหมายซ้ำเพื่อรักษาอุณหภูมิไว้
    if math.abs(diff) < 0.5 then
        pcall(function()
            room.m_fTemperatureWall = target
        end)
        return
    end

    -- คุมเฉพาะห้องของอาคารหลังนี้โดยตรง ไม่แตะ it.def.Heat ซึ่งเป็นค่ากลางร่วมกัน
    -- ใช้แรงปรับตามระยะห่าง และมีแรงขั้นต่ำเพื่อสู้กับการสูญเสียความร้อนของห้องใหญ่
    local change = diff * 0.75
    if math.abs(change) < 2 then
        change = diff > 0 and 2 or -2
    end
    if change > 50 then change = 50 end
    if change < -50 then change = -50 end
    if math.abs(change) > math.abs(diff) then change = diff end

    pcall(function()
        room.m_fTemperatureWall = roomTemp + change
    end)
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