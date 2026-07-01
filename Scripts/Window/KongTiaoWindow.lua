-- Xaou KongTiao Direct Window v3


local function Xaou_KT_ShowMsg(msg)
    pcall(function()
        if world ~= nil then world:ShowMsgBox(tostring(msg)) end
    end)
    pcall(function()
        if CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.UI ~= nil then
            CS.XiaWorld.UI.InGameUI.Instance:ShowMsg(tostring(msg))
        end
    end)
end

local function Xaou_KT_UIPackage()
    if UIPackage ~= nil then return UIPackage end
    if CS ~= nil and CS.FairyGUI ~= nil then return CS.FairyGUI.UIPackage end
    return nil
end

local function Xaou_KT_GRoot()
    if GRoot ~= nil then return GRoot.inst end
    if CS ~= nil and CS.FairyGUI ~= nil and CS.FairyGUI.GRoot ~= nil then
        return CS.FairyGUI.GRoot.inst
    end
    return nil
end

local function Xaou_KT_SetText(obj, text)
    if obj == nil then return end
    pcall(function() obj.text = tostring(text) end)
    pcall(function() obj.title = tostring(text) end)
end

local function Xaou_KT_SetTouchable(obj, flag)
    if obj == nil then return end
    pcall(function() obj.touchable = flag end)
    pcall(function() obj.enabled = true end)
    pcall(function() obj.grayed = false end)
end

local function Xaou_KT_CloseCurrent()
    if Xaou_KongTiao_View ~= nil then
        pcall(function() Xaou_KongTiao_View:RemoveFromParent() end)
        pcall(function() Xaou_KongTiao_View:Dispose() end)
        Xaou_KongTiao_View = nil
    end
end

function Xaou_OpenKongTiaoWindow(kongTiao)
    Xaou_KT_CloseCurrent()

    local pkg = Xaou_KT_UIPackage()
    local root = Xaou_KT_GRoot()

    if pkg == nil or root == nil then
        Xaou_KT_ShowMsg("ไม่พบ FairyGUI / GRoot")
        return
    end

    pcall(function() pkg.AddPackage("UI/XaouUI") end)

    local view = nil
    pcall(function()
        view = pkg.CreateObject("XaouUI", "KongTiaoWindow")
    end)

    if view == nil then
        Xaou_KT_ShowMsg("เปิด XaouUI/KongTiaoWindow ไม่ได้")
        return
    end

    Xaou_KongTiao_View = view
    Xaou_KongTiao_Target = kongTiao
    Xaou_KongTiao_Temp = 20

    if kongTiao ~= nil then
        Xaou_KongTiao_Temp = tonumber(kongTiao.WenDu) or 20
    end

    root:AddChild(view)

    pcall(function()
        view.x = (root.width - view.width) / 2
        view.y = (root.height - view.height) / 2
    end)

    local txtTitle = view:GetChild("txtTitle")
    local txtTemp = view:GetChild("txtTemp")
    local btnMinus = view:GetChild("btnMinus")
    local btnPlus = view:GetChild("btnPlus")
    local btnConfirm = view:GetChild("btnConfirm")
    local txtMinus = view:GetChild("txtMinus")
    local txtPlus = view:GetChild("txtPlus")
    local txtConfirm = view:GetChild("txtConfirm")

    local function refresh()
        Xaou_KT_SetText(txtTitle, "เตาควบคุมอุณหภูมิ")
        Xaou_KT_SetText(txtTemp, tostring(tonumber(Xaou_KongTiao_Temp) or 20) .. "°C")
        Xaou_KT_SetText(txtMinus, "[-]")
        Xaou_KT_SetText(txtPlus, "[+]")
        Xaou_KT_SetText(txtConfirm, "บันทึกค่า")
    end

    -- Graph ที่ใช้เป็นปุ่มต้องเปิด touch ส่วน Text ที่วางทับต้องปิด touch ไม่ให้บังคลิก
    Xaou_KT_SetTouchable(btnMinus, true)
    Xaou_KT_SetTouchable(btnPlus, true)
    Xaou_KT_SetTouchable(btnConfirm, true)
    Xaou_KT_SetTouchable(txtMinus, false)
    Xaou_KT_SetTouchable(txtPlus, false)
    Xaou_KT_SetTouchable(txtConfirm, false)

    if btnMinus ~= nil then
        btnMinus.onClick:Add(function()
            Xaou_KongTiao_Temp = (tonumber(Xaou_KongTiao_Temp) or 20) - 1
            refresh()
        end)
    end

    if btnPlus ~= nil then
        btnPlus.onClick:Add(function()
            Xaou_KongTiao_Temp = (tonumber(Xaou_KongTiao_Temp) or 20) + 1
            refresh()
        end)
    end

    if btnConfirm ~= nil then
        btnConfirm.onClick:Add(function()
            local temp = tonumber(Xaou_KongTiao_Temp) or 20

            if Xaou_KongTiao_Target ~= nil then
                if Xaou_KongTiao_Target.setWenDu ~= nil then
                    Xaou_KongTiao_Target:setWenDu(temp)
                else
                    Xaou_KongTiao_Target.WenDu = temp
                end
            end

            Xaou_KT_ShowMsg("ตั้งอุณหภูมิเป็น " .. tostring(temp) .. "°C แล้ว")
            Xaou_KT_CloseCurrent()
        end)
    end

    refresh()
    Xaou_KT_ShowMsg("เปิดหน้าต่าง XaouUI สำเร็จ")
end


-- ยังสร้าง Window ชื่อเดิมไว้ เพื่อไม่ให้ระบบเก่าที่เรียก GetWindow พัง
local Windows = GameMain:GetMod("Windows")
local tbWindow = Windows:CreateWindow("KongTiaoWindow")

function tbWindow:OnInit()
end

function tbWindow:SetUpData(KongTiao)
    self.KongTiao = KongTiao
end

function tbWindow:OnShowUpdate()
    Xaou_OpenKongTiaoWindow(self.KongTiao)
    self:Hide()
end

function tbWindow:OnShown()
end

function tbWindow:OnUpdate(dt)
end

function tbWindow:OnHide()
end
