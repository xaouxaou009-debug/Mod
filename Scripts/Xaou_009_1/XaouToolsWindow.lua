-- Xaou Tools Window - Quick Build / Free Build for FairyGUI
-- FGUI Component: XaouUI / Utility
-- Object names from current FairyGUI:
--   title
--   01_QuickBuild1, 01_txt_QuickBuild1, 01_ON/OFF1
--   02_FreeBuild2,  02_txt_FreeBuild2,  02_ON/OFF2
-- Optional close:
--   btnClose / Close / close

local Xaou_Tools_View = Xaou_Tools_View

local function Xaou_Tools_ShowMsg(msg)
    pcall(function()
        if world ~= nil then world:ShowMsgBox(tostring(msg)) end
    end)
    pcall(function()
        if CS ~= nil and CS.XiaWorld ~= nil and CS.XiaWorld.UI ~= nil then
            CS.XiaWorld.UI.InGameUI.Instance:ShowMsg(tostring(msg))
        end
    end)
end

local function Xaou_Tools_UIPackage()
    if UIPackage ~= nil then return UIPackage end
    if CS ~= nil and CS.FairyGUI ~= nil then return CS.FairyGUI.UIPackage end
    return nil
end

local function Xaou_Tools_GRoot()
    if GRoot ~= nil then return GRoot.inst end
    if CS ~= nil and CS.FairyGUI ~= nil and CS.FairyGUI.GRoot ~= nil then
        return CS.FairyGUI.GRoot.inst
    end
    return nil
end

local function Xaou_Tools_GetChild(view, names)
    if view == nil or names == nil then return nil end
    for _, name in ipairs(names) do
        local ok, obj = pcall(function() return view:GetChild(name) end)
        if ok and obj ~= nil then return obj end
    end
    return nil
end

local function Xaou_Tools_SetText(obj, text)
    if obj == nil then return end
    pcall(function() obj.text = tostring(text) end)
    pcall(function() obj.title = tostring(text) end)
end

local function Xaou_Tools_SetTouchable(obj, flag)
    if obj == nil then return end
    pcall(function() obj.touchable = flag end)
    pcall(function() obj.enabled = true end)
    pcall(function() obj.grayed = false end)
end

local function Xaou_Tools_AddClick(obj, func)
    if obj == nil or func == nil then return false end
    Xaou_Tools_SetTouchable(obj, true)
    local ok = pcall(function()
        obj.onClick:Add(func)
    end)
    return ok
end

local function Xaou_Tools_GetBuildMod()
    return GameMain:GetMod("Xaou009_ACS_Mod")
end

function Xaou_CloseToolsWindow()
    if Xaou_Tools_View ~= nil then
        pcall(function() Xaou_Tools_View:RemoveFromParent() end)
        pcall(function() Xaou_Tools_View:Dispose() end)
        Xaou_Tools_View = nil
    end
end

local function Xaou_Tools_Refresh(view)
    if view == nil then return end

    local mod = Xaou_Tools_GetBuildMod()
    local quickOn = false
    local freeOn = false

    if mod ~= nil then
        quickOn = (mod.QuickBuildEnable == true)
        freeOn = (mod.FreeBuildEnable == true)
    end

    Xaou_Tools_SetText(Xaou_Tools_GetChild(view, {"title", "txtTitle"}), "")

    Xaou_Tools_SetText(Xaou_Tools_GetChild(view, {"01_txt_QuickBuild1", "01_txt"}), "สร้างด่วน")
    Xaou_Tools_SetText(Xaou_Tools_GetChild(view, {"01_ON/OFF1", "01_btn"}), quickOn and "เปิด" or "ปิด")

    Xaou_Tools_SetText(Xaou_Tools_GetChild(view, {"02_txt_FreeBuild2", "02_txt"}), "สร้างฟรี")
    Xaou_Tools_SetText(Xaou_Tools_GetChild(view, {"02_ON/OFF2", "02_btn"}), freeOn and "เปิด" or "ปิด")
end

local function Xaou_Tools_ToggleQuick(view)
    local mod = Xaou_Tools_GetBuildMod()
    if mod ~= nil and mod.ToggleQuickBuild ~= nil then
        mod:ToggleQuickBuild()
        Xaou_Tools_Refresh(view)
        Xaou_Tools_ShowMsg("Quick Build: " .. ((mod.QuickBuildEnable == true) and "ON" or "OFF"))
    else
        Xaou_Tools_ShowMsg("ไม่พบ ToggleQuickBuild")
    end
end

local function Xaou_Tools_ToggleFree(view)
    local mod = Xaou_Tools_GetBuildMod()
    if mod ~= nil and mod.ToggleFreeBuild ~= nil then
        mod:ToggleFreeBuild()
        Xaou_Tools_Refresh(view)
        Xaou_Tools_ShowMsg("Free Build: " .. ((mod.FreeBuildEnable == true) and "ON" or "OFF"))
    else
        Xaou_Tools_ShowMsg("ไม่พบ ToggleFreeBuild")
    end
end

function Xaou_OpenToolsWindow()
    Xaou_CloseToolsWindow()

    local pkg = Xaou_Tools_UIPackage()
    local root = Xaou_Tools_GRoot()

    if pkg == nil or root == nil then
        Xaou_Tools_ShowMsg("ไม่พบ FairyGUI / GRoot")
        return
    end

    pcall(function() pkg.AddPackage("UI/XaouUI") end)

    local view = nil
    pcall(function()
        view = pkg.CreateObject("XaouUI", "Utility")
    end)

    if view == nil then
        Xaou_Tools_ShowMsg("เปิด XaouUI/Utility ไม่ได้")
        return
    end

    Xaou_Tools_View = view
    root:AddChild(view)

    pcall(function()
        view.x = (root.width - view.width) / 2
        view.y = (root.height - view.height) / 2
    end)

    -- Current FairyGUI names:
    local quickArea  = Xaou_Tools_GetChild(view, {"01_QuickBuild1", "01_btn"})
    local quickState = Xaou_Tools_GetChild(view, {"01_ON/OFF1", "01_btn"})
    local freeArea   = Xaou_Tools_GetChild(view, {"02_FreeBuild2", "02_btn"})
    local freeState  = Xaou_Tools_GetChild(view, {"02_ON/OFF2", "02_btn"})
    local btnClose   = Xaou_Tools_GetChild(view, {"btnClose", "Close", "close"})

    -- ให้กดได้ทั้งช่องพื้นหลังและข้อความ ON/OFF
    Xaou_Tools_AddClick(quickArea, function() Xaou_Tools_ToggleQuick(view) end)
    Xaou_Tools_AddClick(quickState, function() Xaou_Tools_ToggleQuick(view) end)

    Xaou_Tools_AddClick(freeArea, function() Xaou_Tools_ToggleFree(view) end)
    Xaou_Tools_AddClick(freeState, function() Xaou_Tools_ToggleFree(view) end)

    Xaou_Tools_AddClick(btnClose, function()
        Xaou_CloseToolsWindow()
    end)

    Xaou_Tools_Refresh(view)
end
