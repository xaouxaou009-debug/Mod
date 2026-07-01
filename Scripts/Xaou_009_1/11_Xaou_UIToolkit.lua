-- ============================================================
-- XAOU FAIRYGUI TOOLKIT V6
-- ใช้ฐานข้อมูลจาก UI Explorer เพื่อสร้าง UI ของเกมโดยไม่ต้องเดา URL
-- โหลดหลัง 01-10
-- ============================================================

if XaouItemWindow == nil and _G ~= nil then
    XaouItemWindow = _G.XaouItemWindow
end

Xaou_UI = Xaou_UI or {}

Xaou_UI.URL = Xaou_UI.URL or {
    ListItem       = "ui://0xrxw6g7hdhl0",
    ScrollArrow    = "ui://0xrxw6g7hdhl3",
    ScrollGrip     = "ui://0xrxw6g7hdhl6",
    ComboPopup     = "ui://0xrxw6g7hdhl7",
    CloseButton    = "ui://0xrxw6g7hdhl9",
    Button         = "ui://0xrxw6g7hdhl18",
    Checkbox       = "ui://0xrxw6g7hdhl1a",
    RadioButton    = "ui://0xrxw6g7hdhl1b",
    Input          = "ui://0xrxw6g7hdhl1c",
    TextArea       = "ui://0xrxw6g7hdhl1d",
    SliderH        = "ui://0xrxw6g7hdhl1e",
    IconButton     = "ui://0xrxw6g7hdhl1f",
    SliderV        = "ui://0xrxw6g7hdhl1g",
    ProgressBar    = "ui://0xrxw6g7hdhl1h",
    ComboBox       = "ui://0xrxw6g7hdhl1i",
    WindowFrame    = "ui://0xrxw6g7hdhl1j",
    IconTextButton = "ui://0xrxw6g7hdhl1k",
    TabButton      = "ui://0xrxw6g7hdhl1l",
    ScrollBarH     = "ui://0xrxw6g7hdhl1m",
    ScrollBarV     = "ui://0xrxw6g7hdhl1n",
    ProduceWindow  = "ui://0xrxw6g7hdhl1o",
    ProduceItem    = "ui://0xrxw6g7hdhl1q",
    Tip            = "ui://0xrxw6g7hdhl1t",
}

Xaou_UI.KeyToType = Xaou_UI.KeyToType or {
    hdhl0="ListItem", hdhl3="ScrollArrow", hdhl6="ScrollGrip", hdhl7="ComboPopup", hdhl9="CloseButton",
    hdhl18="Button", hdhl1a="Checkbox", hdhl1b="RadioButton", hdhl1c="Input", hdhl1d="TextArea",
    hdhl1e="SliderH", hdhl1f="IconButton", hdhl1g="SliderV", hdhl1h="ProgressBar", hdhl1i="ComboBox",
    hdhl1j="WindowFrame", hdhl1k="IconTextButton", hdhl1l="TabButton", hdhl1m="ScrollBarH", hdhl1n="ScrollBarV",
    hdhl1o="ProduceWindow", hdhl1q="ProduceItem", hdhl1t="Tip",
}

function Xaou_UI.Resolve(keyOrType)
    local k = tostring(keyOrType or "")
    if k == "" then return nil end
    if string.sub(k, 1, 5) == "ui://" then return k end
    if Xaou_UI.URL[k] ~= nil then return Xaou_UI.URL[k] end
    if Xaou_UI.KeyToType[k] ~= nil then return Xaou_UI.URL[Xaou_UI.KeyToType[k]] end
    return nil
end

local function Xaou_UI_SetText(obj, text)
    if obj == nil then return end
    pcall(function() obj.text = tostring(text or "") end)
    pcall(function() if obj.m_title ~= nil then obj.m_title.text = tostring(text or "") end end)
    pcall(function() if obj:GetChild("title") ~= nil then obj:GetChild("title").text = tostring(text or "") end end)
end

local function Xaou_UI_SetIcon(obj, icon)
    if obj == nil or icon == nil or tostring(icon) == "" then return end
    pcall(function() obj.icon = tostring(icon) end)
    pcall(function() if obj.m_icon ~= nil then obj.m_icon.icon = tostring(icon) end end)
    pcall(function() if obj:GetChild("icon") ~= nil then obj:GetChild("icon").icon = tostring(icon) end end)
end

local function Xaou_UI_SetValue(obj, value, max)
    if obj == nil then return end
    if max ~= nil then pcall(function() obj.max = tonumber(max) or obj.max end) end
    if value ~= nil then pcall(function() obj.value = tonumber(value) or obj.value end) end
end

function XaouItemWindow:AddUIObject(name, keyOrType, x, y, w, h, opt)
    local url = Xaou_UI.Resolve(keyOrType)
    if url == nil then
        Xaou_Show("ไม่พบ UI key/type: " .. tostring(keyOrType), "UI Toolkit")
        return nil
    end
    local obj = self:AddObjectFromUrl(url, x or 0, y or 0)
    if obj == nil then return nil end
    obj.name = tostring(name or keyOrType)
    if w ~= nil or h ~= nil then pcall(function() obj:SetSize(w or obj.width or 100, h or obj.height or 30, false) end) end
    opt = opt or {}
    if opt.text ~= nil then Xaou_UI_SetText(obj, opt.text) end
    if opt.icon ~= nil then Xaou_UI_SetIcon(obj, opt.icon) end
    if opt.value ~= nil or opt.max ~= nil then Xaou_UI_SetValue(obj, opt.value, opt.max) end
    if opt.touchable ~= nil then pcall(function() obj.touchable = opt.touchable end) end
    if opt.tooltip ~= nil then pcall(function() obj.tooltips = tostring(opt.tooltip) end) end
    return obj
end

function XaouItemWindow:AddGameButton(name, text, x, y, w, h, icon, opt)
    opt = opt or {}; opt.text = text; opt.icon = icon
    return self:AddUIObject(name, "Button", x, y, w or 120, h or 34, opt)
end

function XaouItemWindow:AddGameIconButton(name, icon, x, y, w, h, opt)
    opt = opt or {}; opt.icon = icon
    return self:AddUIObject(name, "IconButton", x, y, w or 40, h or 40, opt)
end

function XaouItemWindow:AddGameIconTextButton(name, text, icon, x, y, w, h, opt)
    opt = opt or {}; opt.text = text; opt.icon = icon
    return self:AddUIObject(name, "IconTextButton", x, y, w or 120, h or 34, opt)
end

function XaouItemWindow:AddGameInput(name, text, x, y, w, h, opt)
    opt = opt or {}; opt.text = text or ""
    return self:AddUIObject(name, "Input", x, y, w or 220, h or 30, opt)
end

function XaouItemWindow:AddGameTextArea(name, text, x, y, w, h, opt)
    opt = opt or {}; opt.text = text or ""
    return self:AddUIObject(name, "TextArea", x, y, w or 260, h or 80, opt)
end

function XaouItemWindow:AddGameProgress(name, value, max, x, y, w, h, opt)
    opt = opt or {}; opt.value = value or 0; opt.max = max or 100
    return self:AddUIObject(name, "ProgressBar", x, y, w or 180, h or 24, opt)
end

function XaouItemWindow:AddGameSliderH(name, value, max, x, y, w, h, opt)
    opt = opt or {}; opt.value = value or 0; opt.max = max or 100
    return self:AddUIObject(name, "SliderH", x, y, w or 180, h or 28, opt)
end

function XaouItemWindow:AddGameCombo(name, text, x, y, w, h, opt)
    opt = opt or {}; opt.text = text or "เลือก"
    return self:AddUIObject(name, "ComboBox", x, y, w or 150, h or 30, opt)
end

function XaouItemWindow:AddGameTip(name, text, x, y, w, h, opt)
    opt = opt or {}; opt.text = text or ""
    local obj = self:AddUIObject(name, "Tip", x, y, w or 220, h or 40, opt)
    pcall(function() if obj:GetChild("title") ~= nil then obj:GetChild("title").text = tostring(text or "") end end)
    return obj
end

function XaouItemWindow:AddGameWindowFrame(name, title, x, y, w, h, opt)
    opt = opt or {}; opt.text = title or ""; opt.touchable = opt.touchable
    local obj = self:AddUIObject(name, "WindowFrame", x, y, w or 420, h or 300, opt)
    pcall(function() if obj:GetChild("title") ~= nil then obj:GetChild("title").text = tostring(title or "") end end)
    return obj
end

function XaouItemWindow:XaouUIToolkitDemo()
    self:ClearItemButtons()
    self.itemButtons = {}
    if self.statusLine1 ~= nil then self.statusLine1.m_title.text = "โหมด : UI Toolkit Demo" end
    if self.statusLine2 ~= nil then self.statusLine2.m_title.text = "ทดสอบ Component จากฐานข้อมูล FairyGUI" end

    local function add(o)
        if o ~= nil then table.insert(self.itemButtons, o) end
        return o
    end

    add(self:AddGameWindowFrame("tkFrame", "Xaou FairyGUI Toolkit", 180, 155, 430, 315, {touchable=false}))
    add(self:AddGameButton("tkBtn", "Button", 220, 210, 130, 36, "Sprs/xaou105.png"))
    add(self:AddGameIconButton("tkIcon", "Sprs/xaou106.png", 380, 205, 48, 48))
    add(self:AddGameIconTextButton("tkIconText", "Icon+Text", "Sprs/xaou107.png", 455, 210, 130, 36))
    add(self:AddGameInput("tkInput", "ช่องกรอก", 220, 265, 180, 32))
    add(self:AddGameCombo("tkCombo", "อ๊ากกก!", 420, 265, 150, 32))
    add(self:AddGameProgress("tkProgress", 66, 100, 220, 320, 220, 24))
    add(self:AddGameSliderH("tkSlider", 35, 100, 220, 365, 220, 28))
    add(self:AddGameTextArea("tkArea", "TextArea\nหลายบรรทัด", 470, 320, 180, 80))
    add(self:AddGameTip("tkTip", "Tip / RichText", 220, 420, 220, 36, {touchable=false}))
    add(self:AddButton("btnUIToolkitBack", "◀ กลับ UI", 720, 565, 120, 34, nil))

    if self.pageText ~= nil then
        self.pageText.visible = true
        self.pageText.m_title.text = "UI Toolkit"
    end
end

-- Hook UI Explorer เพื่อเพิ่มปุ่ม Demo โดยไม่แตะไฟล์ 10 โดยตรง
local Xaou_OldRefreshUIExplorerPage_Toolkit = XaouItemWindow.RefreshUIExplorerPage
if Xaou_OldRefreshUIExplorerPage_Toolkit ~= nil then
    function XaouItemWindow:RefreshUIExplorerPage()
        Xaou_OldRefreshUIExplorerPage_Toolkit(self)
        if tostring(self.mainMode or "") == "ui" then
            self.uiButtonData = self.uiButtonData or {}
            local btn = self:AddButton("btnUIToolkitDemo", "Toolkit", 850, 430, 90, 34, nil)
            table.insert(self.itemButtons, btn)
        end
    end
end

local Xaou_OldRefreshList_Toolkit = XaouItemWindow.RefreshList
function XaouItemWindow:RefreshList()
    if self.mainMode == "ui_toolkit" then
        self:XaouUIToolkitDemo()
        return
    end
    return Xaou_OldRefreshList_Toolkit(self)
end

local Xaou_OldOnObjectEvent_Toolkit = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil then
        if obj.name == "btnUIToolkitDemo" then
            self.mainMode = "ui_toolkit"
            self.page = 1
            pcall(function() self:SetTitle("UI Toolkit Demo") end)
            self:RefreshList()
            pcall(function() self:UpdateBottomLayout() end)
            return true
        elseif obj.name == "btnUIToolkitBack" then
            self:SetMainMode("ui")
            return true
        end
    end
    return Xaou_OldOnObjectEvent_Toolkit(self, t, obj, context)
end

local Xaou_OldUpdateBottomLayout_Toolkit = XaouItemWindow.UpdateBottomLayout
if Xaou_OldUpdateBottomLayout_Toolkit ~= nil then
    function XaouItemWindow:UpdateBottomLayout()
        pcall(function() Xaou_OldUpdateBottomLayout_Toolkit(self) end)
        if tostring(self.mainMode or "") == "ui_toolkit" then
            local function show(obj, v) if obj ~= nil then pcall(function() obj.visible = v end) end end
            local function move(obj, x, y)
                if obj ~= nil then pcall(function() if obj.SetXY ~= nil then obj:SetXY(x,y) else obj.x=x; obj.y=y end end) end
            end
            show(self.btnPrev, false)
            show(self.btnNext, false)
            show(self.btnRefresh, false)
            show(self.btnViewMode, false)
            show(self.btnClose, true)
            move(self.btnClose, 1000, 500)
        end
    end
end

-- ============================================================
-- XAOU FAIRYGUI TOOLKIT V7 - MINI UI BUILDER
-- เพิ่มโหมด Builder: เพิ่ม/เลือก/ย้าย/ย่อขยาย/ลบ/Export Lua
-- ============================================================

local function Xaou_BuilderClamp(v, minv, maxv)
    v = tonumber(v) or 0
    if minv ~= nil and v < minv then v = minv end
    if maxv ~= nil and v > maxv then v = maxv end
    return v
end

local function Xaou_BuilderCopyOpt(item)
    if item == nil then return {} end
    return {
        text = item.text or "",
        icon = item.icon or "",
        value = item.value,
        max = item.max,
        touchable = true,
    }
end

function XaouItemWindow:UIBuilderEnsure()
    self.uiBuilderItems = self.uiBuilderItems or {}
    self.uiBuilderSeq = self.uiBuilderSeq or 0
    self.uiBuilderSelected = self.uiBuilderSelected or nil
end

function XaouItemWindow:UIBuilderClearCanvasObjects()
    if self.uiBuilderCanvasObjects ~= nil then
        for _, o in ipairs(self.uiBuilderCanvasObjects) do
            pcall(function() o.visible = false end)
            pcall(function() o:SetSize(0, 0, false) end)
            pcall(function() if o.parent ~= nil then o.parent:RemoveChild(o, true) end end)
        end
    end
    self.uiBuilderCanvasObjects = {}
end

function XaouItemWindow:UIBuilderRenderCanvas()
    self:UIBuilderEnsure()
    self:UIBuilderClearCanvasObjects()

    local function addCanvas(o)
        if o ~= nil then
            table.insert(self.uiBuilderCanvasObjects, o)
            table.insert(self.itemButtons, o)
        end
        return o
    end

    -- กรอบพื้นที่วาง UI
    addCanvas(self:AddGameWindowFrame("builderCanvasFrame", "Canvas", 190, 165, 505, 330, {touchable=false}))
    addCanvas(self:AddLabel("builderCanvasTip", "พื้นที่ทดลองวาง Component", 350, 188, 260, 24))

    for i, item in ipairs(self.uiBuilderItems or {}) do
        local obj = self:AddUIObject(item.name, item.type, item.x, item.y, item.w, item.h, Xaou_BuilderCopyOpt(item))
        if obj ~= nil then
            item.obj = obj
            obj.tooltips = "เลือก: " .. tostring(item.name) .. "\nType: " .. tostring(item.type)
            addCanvas(obj)

            -- กรอบเลือกแบบง่าย ใช้ปุ่มเล็กวางมุมขวาบน
            if self.uiBuilderSelected == item.name then
                local mark = self:AddButton("builderSelectedMark", "★", (item.x or 0) + (item.w or 80) - 22, (item.y or 0) - 6, 26, 24, nil)
                mark.tooltips = "กำลังเลือก " .. tostring(item.name)
                addCanvas(mark)
            end
        end
    end
end

function XaouItemWindow:UIBuilderAdd(kind)
    self:UIBuilderEnsure()
    self.uiBuilderSeq = (self.uiBuilderSeq or 0) + 1
    local n = self.uiBuilderSeq
    local item = {
        name = "uiBuild_" .. tostring(n),
        type = kind,
        x = 245 + ((n - 1) % 4) * 90,
        y = 225 + math.floor(((n - 1) % 12) / 4) * 55,
        w = 120,
        h = 34,
        text = kind .. tostring(n),
        icon = "",
        value = 50,
        max = 100,
    }

    if kind == "Button" then
        item.w = 125; item.h = 36; item.text = "Button " .. tostring(n); item.icon = "Sprs/xaou105.png"
    elseif kind == "Input" then
        item.w = 170; item.h = 32; item.text = "Input"
    elseif kind == "TextArea" then
        item.w = 180; item.h = 78; item.text = "TextArea\nหลายบรรทัด"
    elseif kind == "ComboBox" then
        item.w = 145; item.h = 32; item.text = "เลือก"
    elseif kind == "ProgressBar" then
        item.w = 190; item.h = 24; item.text = ""; item.value = 65; item.max = 100
    elseif kind == "SliderH" then
        item.w = 190; item.h = 28; item.text = ""; item.value = 35; item.max = 100
    elseif kind == "IconButton" then
        item.w = 48; item.h = 48; item.text = ""; item.icon = "Sprs/xaou106.png"
    elseif kind == "IconTextButton" then
        item.w = 145; item.h = 36; item.text = "Icon+Text"; item.icon = "Sprs/xaou107.png"
    elseif kind == "Tip" then
        item.w = 210; item.h = 36; item.text = "Tip / RichText"
    elseif kind == "WindowFrame" then
        item.w = 260; item.h = 160; item.text = "Window"
    end

    table.insert(self.uiBuilderItems, item)
    self.uiBuilderSelected = item.name
    self:RefreshList()
end

function XaouItemWindow:UIBuilderGetSelected()
    self:UIBuilderEnsure()
    local name = tostring(self.uiBuilderSelected or "")
    for _, item in ipairs(self.uiBuilderItems or {}) do
        if tostring(item.name) == name then return item end
    end
    return nil
end

function XaouItemWindow:UIBuilderSelectByObjectName(objName)
    objName = tostring(objName or "")
    for _, item in ipairs(self.uiBuilderItems or {}) do
        if tostring(item.name) == objName then
            self.uiBuilderSelected = objName
            self:RefreshList()
            return true
        end
    end
    return false
end

function XaouItemWindow:UIBuilderMove(dx, dy)
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    item.x = Xaou_BuilderClamp((item.x or 0) + (dx or 0), 0, 920)
    item.y = Xaou_BuilderClamp((item.y or 0) + (dy or 0), 0, 570)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderResize(dw, dh)
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    item.w = Xaou_BuilderClamp((item.w or 80) + (dw or 0), 20, 600)
    item.h = Xaou_BuilderClamp((item.h or 30) + (dh or 0), 20, 400)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderDelete()
    local name = tostring(self.uiBuilderSelected or "")
    if name == "" then return end
    for i = #self.uiBuilderItems, 1, -1 do
        if tostring(self.uiBuilderItems[i].name) == name then
            table.remove(self.uiBuilderItems, i)
            self.uiBuilderSelected = nil
            self:RefreshList()
            return
        end
    end
end

function XaouItemWindow:UIBuilderClearAll()
    self.uiBuilderItems = {}
    self.uiBuilderSelected = nil
    self.uiBuilderSeq = 0
    self:RefreshList()
end

local function Xaou_BuilderQuote(s)
    s = tostring(s or "")
    s = string.gsub(s, "\\", "\\\\")
    s = string.gsub(s, "\r", "\\r")
    s = string.gsub(s, "\n", "\\n")
    s = string.gsub(s, '"', '\\"')
    return '"' .. s .. '"'
end

function XaouItemWindow:UIBuilderMakeLua()
    self:UIBuilderEnsure()
    local out = {}
    table.insert(out, "-- Auto generated by Xaou UI Builder V7")
    table.insert(out, "-- นำไปวางใน Refresh/OnInit ของหน้าต่างได้")
    table.insert(out, "")
    for _, item in ipairs(self.uiBuilderItems or {}) do
        local name = Xaou_BuilderQuote(item.name)
        local x, y, w, h = tonumber(item.x) or 0, tonumber(item.y) or 0, tonumber(item.w) or 100, tonumber(item.h) or 30
        if item.type == "Button" then
            table.insert(out, "self:AddGameButton(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ", " .. Xaou_BuilderQuote(item.icon) .. ")")
        elseif item.type == "Input" then
            table.insert(out, "self:AddGameInput(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "TextArea" then
            table.insert(out, "self:AddGameTextArea(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "ComboBox" then
            table.insert(out, "self:AddGameCombo(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "ProgressBar" then
            table.insert(out, "self:AddGameProgress(" .. name .. ", " .. tostring(item.value or 50) .. ", " .. tostring(item.max or 100) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "SliderH" then
            table.insert(out, "self:AddGameSliderH(" .. name .. ", " .. tostring(item.value or 50) .. ", " .. tostring(item.max or 100) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "IconButton" then
            table.insert(out, "self:AddGameIconButton(" .. name .. ", " .. Xaou_BuilderQuote(item.icon) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "IconTextButton" then
            table.insert(out, "self:AddGameIconTextButton(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. Xaou_BuilderQuote(item.icon) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "Tip" then
            table.insert(out, "self:AddGameTip(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "WindowFrame" then
            table.insert(out, "self:AddGameWindowFrame(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        else
            table.insert(out, "self:AddUIObject(" .. name .. ", " .. Xaou_BuilderQuote(item.type) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ", { text=" .. Xaou_BuilderQuote(item.text) .. ", icon=" .. Xaou_BuilderQuote(item.icon) .. " })")
        end
    end
    self.uiBuilderLastLua = table.concat(out, "\n")
    self.uiExplorerLastDump = self.uiBuilderLastLua
    Xaou_Show("สร้าง Lua แล้ว\nกด Export เพื่อบันทึกไฟล์\n\n" .. string.sub(self.uiBuilderLastLua, 1, 700), "UI Builder")
end

function XaouItemWindow:RefreshUIBuilderPage()
    self:UIBuilderEnsure()
    self:ClearItemButtons()
    self:UIExplorerClearPreview()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}
    self.uiButtonData = {}

    if self.statusLine1 ~= nil then self.statusLine1.m_title.text = "โหมด : UI Builder | สร้าง Layout ทดลอง" end
    if self.statusLine2 ~= nil then self.statusLine2.m_title.text = "เพิ่ม Component / เลือก / ย้าย / Resize / Export Lua" end
    pcall(function() self:SetTitle("UI Builder") end)

    local function add(o) if o ~= nil then table.insert(self.itemButtons, o) end return o end

    -- Palette ด้านซ้าย
    add(self:AddButton("btnBuildAddButton", "Button", -60, 155, 130, 34))
    add(self:AddButton("btnBuildAddInput", "Input", -60, 195, 130, 34))
    add(self:AddButton("btnBuildAddCombo", "Combo", -60, 235, 130, 34))
    add(self:AddButton("btnBuildAddProgress", "Progress", -60, 275, 130, 34))
    add(self:AddButton("btnBuildAddSlider", "Slider", -60, 315, 130, 34))
    add(self:AddButton("btnBuildAddTextArea", "TextArea", -60, 355, 130, 34))
    add(self:AddButton("btnBuildAddIcon", "IconBtn", -60, 395, 130, 34))
    add(self:AddButton("btnBuildAddIconText", "IconText", -60, 435, 130, 34))
    add(self:AddButton("btnBuildAddTip", "Tip", -60, 475, 130, 34))

    -- Tools ด้านขวา
    add(self:AddButton("btnBuildUp", "▲", 730, 185, 55, 34))
    add(self:AddButton("btnBuildDown", "▼", 730, 265, 55, 34))
    add(self:AddButton("btnBuildLeft", "◀", 670, 225, 55, 34))
    add(self:AddButton("btnBuildRight", "▶", 790, 225, 55, 34))
    add(self:AddButton("btnBuildBigger", "+Size", 670, 325, 80, 34))
    add(self:AddButton("btnBuildSmaller", "-Size", 760, 325, 80, 34))
    add(self:AddButton("btnBuildDelete", "Delete", 670, 370, 80, 34))
    add(self:AddButton("btnBuildClear", "Clear", 760, 370, 80, 34))
    add(self:AddButton("btnBuildLua", "Make Lua", 670, 430, 100, 34))
    add(self:AddButton("btnBuildExport", "Export", 780, 430, 90, 34))
    add(self:AddButton("btnBuildBack", "◀ UI", 720, 565, 120, 34))

    local sel = self:UIBuilderGetSelected()
    local info = "เลือก: -"
    if sel ~= nil then
        info = "เลือก: " .. tostring(sel.name) .. "\n" .. tostring(sel.type) .. " x=" .. tostring(sel.x) .. " y=" .. tostring(sel.y) .. "\nw=" .. tostring(sel.w) .. " h=" .. tostring(sel.h)
    end
    local infoObj = self:AddLabel("txtBuilderInfo", info, 670, 475, 240, 80)
    pcall(function() infoObj.touchable = false end)
    add(infoObj)

    self:UIBuilderRenderCanvas()

    if self.pageText ~= nil then
        self.pageText.visible = true
        self.pageText.m_title.text = "UI Builder: " .. tostring(#(self.uiBuilderItems or {})) .. " objects"
    end
end

-- เพิ่มปุ่ม Builder ในหน้า UI Explorer และ Toolkit
local Xaou_OldRefreshUIExplorerPage_Builder = XaouItemWindow.RefreshUIExplorerPage
if Xaou_OldRefreshUIExplorerPage_Builder ~= nil then
    function XaouItemWindow:RefreshUIExplorerPage()
        Xaou_OldRefreshUIExplorerPage_Builder(self)
        if tostring(self.mainMode or "") == "ui" then
            local btn = self:AddButton("btnUIBuilder", "Builder", 850, 525, 90, 34, nil)
            table.insert(self.itemButtons, btn)
        end
    end
end

local Xaou_OldRefreshList_Builder = XaouItemWindow.RefreshList
function XaouItemWindow:RefreshList()
    if self.mainMode == "ui_builder" then
        self:RefreshUIBuilderPage()
        return
    end
    return Xaou_OldRefreshList_Builder(self)
end

local Xaou_OldOnObjectEvent_Builder = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil then
        if obj.name == "btnUIBuilder" then
            self.mainMode = "ui_builder"
            self.page = 1
            self:RefreshList()
            pcall(function() self:UpdateBottomLayout() end)
            return true
        end
        if self.mainMode == "ui_builder" then
            if self:UIBuilderSelectByObjectName(obj.name) then return true end
            if obj.name == "btnBuildAddButton" then self:UIBuilderAdd("Button"); return true end
            if obj.name == "btnBuildAddInput" then self:UIBuilderAdd("Input"); return true end
            if obj.name == "btnBuildAddCombo" then self:UIBuilderAdd("ComboBox"); return true end
            if obj.name == "btnBuildAddProgress" then self:UIBuilderAdd("ProgressBar"); return true end
            if obj.name == "btnBuildAddSlider" then self:UIBuilderAdd("SliderH"); return true end
            if obj.name == "btnBuildAddTextArea" then self:UIBuilderAdd("TextArea"); return true end
            if obj.name == "btnBuildAddIcon" then self:UIBuilderAdd("IconButton"); return true end
            if obj.name == "btnBuildAddIconText" then self:UIBuilderAdd("IconTextButton"); return true end
            if obj.name == "btnBuildAddTip" then self:UIBuilderAdd("Tip"); return true end
            if obj.name == "btnBuildUp" then self:UIBuilderMove(0, -10); return true end
            if obj.name == "btnBuildDown" then self:UIBuilderMove(0, 10); return true end
            if obj.name == "btnBuildLeft" then self:UIBuilderMove(-10, 0); return true end
            if obj.name == "btnBuildRight" then self:UIBuilderMove(10, 0); return true end
            if obj.name == "btnBuildBigger" then self:UIBuilderResize(10, 10); return true end
            if obj.name == "btnBuildSmaller" then self:UIBuilderResize(-10, -10); return true end
            if obj.name == "btnBuildDelete" then self:UIBuilderDelete(); return true end
            if obj.name == "btnBuildClear" then self:UIBuilderClearAll(); return true end
            if obj.name == "btnBuildLua" then self:UIBuilderMakeLua(); return true end
            if obj.name == "btnBuildExport" then self:UIBuilderMakeLua(); self:UIExplorerExport(); return true end
            if obj.name == "btnBuildBack" then self:SetMainMode("ui"); return true end
        end
    end
    return Xaou_OldOnObjectEvent_Builder(self, t, obj, context)
end

local Xaou_OldUpdateBottomLayout_Builder = XaouItemWindow.UpdateBottomLayout
if Xaou_OldUpdateBottomLayout_Builder ~= nil then
    function XaouItemWindow:UpdateBottomLayout()
        pcall(function() Xaou_OldUpdateBottomLayout_Builder(self) end)
        if tostring(self.mainMode or "") == "ui_builder" then
            local function show(obj, v) if obj ~= nil then pcall(function() obj.visible = v end) end end
            local function move(obj, x, y) if obj ~= nil then pcall(function() if obj.SetXY ~= nil then obj:SetXY(x,y) else obj.x=x; obj.y=y end end) end end
            show(self.btnPrev, false)
            show(self.btnNext, false)
            show(self.btnRefresh, false)
            show(self.btnViewMode, false)
            show(self.btnClose, true)
            move(self.btnClose, 1000, 500)
        end
    end
end

-- ============================================================
-- XAOU FAIRYGUI BUILDER V8 PATCH
-- เพิ่ม Snap Grid / Step / Duplicate / Text/Icon cycle / Component เพิ่มเติม
-- ============================================================

function XaouItemWindow:UIBuilderSnapValue(v)
    v = tonumber(v) or 0
    if self.uiBuilderSnap == false then return v end
    local g = tonumber(self.uiBuilderGrid or 10) or 10
    if g <= 0 then return v end
    return math.floor((v + g / 2) / g) * g
end

local Xaou_V8_OldBuilderAdd = XaouItemWindow.UIBuilderAdd
function XaouItemWindow:UIBuilderAdd(kind)
    -- ใช้ของเดิมก่อนสำหรับชนิดที่มีอยู่แล้ว
    local known = { Button=true, Input=true, ComboBox=true, ProgressBar=true, SliderH=true, TextArea=true, IconButton=true, IconTextButton=true, Tip=true, WindowFrame=true }
    if known[tostring(kind or "")] then
        Xaou_V8_OldBuilderAdd(self, kind)
        local item = self:UIBuilderGetSelected()
        if item ~= nil then
            item.x = self:UIBuilderSnapValue(item.x)
            item.y = self:UIBuilderSnapValue(item.y)
        end
        return
    end

    self:UIBuilderEnsure()
    self.uiBuilderSeq = (self.uiBuilderSeq or 0) + 1
    local n = self.uiBuilderSeq
    local item = {
        name = "uiBuild_" .. tostring(n),
        type = tostring(kind or "Button"),
        x = self:UIBuilderSnapValue(245 + ((n - 1) % 4) * 90),
        y = self:UIBuilderSnapValue(225 + math.floor(((n - 1) % 12) / 4) * 55),
        w = 120,
        h = 34,
        text = tostring(kind or "UI") .. " " .. tostring(n),
        icon = "",
        value = 50,
        max = 100,
    }

    if kind == "Checkbox" then
        item.w = 140; item.h = 28; item.text = "Check " .. tostring(n)
    elseif kind == "RadioButton" then
        item.w = 140; item.h = 28; item.text = "Radio " .. tostring(n)
    elseif kind == "TabButton" then
        item.w = 120; item.h = 36; item.text = "Tab " .. tostring(n)
    elseif kind == "ListItem" then
        item.w = 180; item.h = 32; item.text = "ListItem " .. tostring(n)
    elseif kind == "ProduceItem" then
        item.w = 90; item.h = 90; item.text = "Produce"; item.icon = "Sprs/xaou105.png"
    elseif kind == "WindowFrame" then
        item.w = 260; item.h = 160; item.text = "Window"
    end

    table.insert(self.uiBuilderItems, item)
    self.uiBuilderSelected = item.name
    self:RefreshList()
end

function XaouItemWindow:UIBuilderDuplicate()
    local src = self:UIBuilderGetSelected()
    if src == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    self:UIBuilderEnsure()
    self.uiBuilderSeq = (self.uiBuilderSeq or 0) + 1
    local item = {}
    for k, v in pairs(src) do
        if k ~= "obj" then item[k] = v end
    end
    item.name = "uiBuild_" .. tostring(self.uiBuilderSeq)
    item.x = self:UIBuilderSnapValue((tonumber(src.x) or 0) + 20)
    item.y = self:UIBuilderSnapValue((tonumber(src.y) or 0) + 20)
    table.insert(self.uiBuilderItems, item)
    self.uiBuilderSelected = item.name
    self:RefreshList()
end

function XaouItemWindow:UIBuilderMove(dx, dy)
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local step = tonumber(self.uiBuilderStep or 10) or 10
    local sx = 0
    local sy = 0
    if tonumber(dx or 0) > 0 then sx = step elseif tonumber(dx or 0) < 0 then sx = -step end
    if tonumber(dy or 0) > 0 then sy = step elseif tonumber(dy or 0) < 0 then sy = -step end
    item.x = Xaou_BuilderClamp((tonumber(item.x) or 0) + sx, 0, 920)
    item.y = Xaou_BuilderClamp((tonumber(item.y) or 0) + sy, 0, 570)
    item.x = self:UIBuilderSnapValue(item.x)
    item.y = self:UIBuilderSnapValue(item.y)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderResize(dw, dh)
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local step = tonumber(self.uiBuilderStep or 10) or 10
    local sw = 0
    local sh = 0
    if tonumber(dw or 0) > 0 then sw = step elseif tonumber(dw or 0) < 0 then sw = -step end
    if tonumber(dh or 0) > 0 then sh = step elseif tonumber(dh or 0) < 0 then sh = -step end
    item.w = Xaou_BuilderClamp((tonumber(item.w) or 80) + sw, 20, 600)
    item.h = Xaou_BuilderClamp((tonumber(item.h) or 30) + sh, 20, 400)
    item.w = self:UIBuilderSnapValue(item.w)
    item.h = self:UIBuilderSnapValue(item.h)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderToggleSnap()
    self.uiBuilderSnap = not (self.uiBuilderSnap == true)
    if self.uiBuilderSnap then
        for _, item in ipairs(self.uiBuilderItems or {}) do
            item.x = self:UIBuilderSnapValue(item.x)
            item.y = self:UIBuilderSnapValue(item.y)
            item.w = self:UIBuilderSnapValue(item.w)
            item.h = self:UIBuilderSnapValue(item.h)
        end
    end
    self:RefreshList()
end

function XaouItemWindow:UIBuilderCycleStep()
    local steps = {1, 5, 10, 20, 40}
    local cur = tonumber(self.uiBuilderStep or 10) or 10
    local nextv = 10
    for i, v in ipairs(steps) do
        if v == cur then nextv = steps[i + 1] or steps[1]; break end
    end
    self.uiBuilderStep = nextv
    self:RefreshList()
end

function XaouItemWindow:UIBuilderCycleText()
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local list = {"ไอเทม", "คัมภีร์", "NPC", "ค้นหา", "ตกลง", "ยกเลิก", "Button", "TextArea\nหลายบรรทัด"}
    self.uiBuilderTextIndex = (tonumber(self.uiBuilderTextIndex or 0) or 0) + 1
    item.text = list[((self.uiBuilderTextIndex - 1) % #list) + 1]
    self:RefreshList()
end

function XaouItemWindow:UIBuilderCycleIcon()
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local list = {"Sprs/xaou105.png", "Sprs/xaou106.png", "Sprs/xaou107.png", "Sprs/xaou108.png", "Sprs/xaou104.png", ""}
    self.uiBuilderIconIndex = (tonumber(self.uiBuilderIconIndex or 0) or 0) + 1
    item.icon = list[((self.uiBuilderIconIndex - 1) % #list) + 1]
    self:RefreshList()
end

-- Make Lua V8: รองรับ Component เพิ่มเติมผ่าน AddUIObject
function XaouItemWindow:UIBuilderMakeLua()
    self:UIBuilderEnsure()
    local out = {}
    table.insert(out, "-- Auto generated by Xaou UI Builder V8")
    table.insert(out, "-- นำไปวางใน Refresh/OnInit ของหน้าต่างได้")
    table.insert(out, "")
    for _, item in ipairs(self.uiBuilderItems or {}) do
        local name = Xaou_BuilderQuote(item.name)
        local x, y, w, h = tonumber(item.x) or 0, tonumber(item.y) or 0, tonumber(item.w) or 100, tonumber(item.h) or 30
        if item.type == "Button" then
            table.insert(out, "self:AddGameButton(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ", " .. Xaou_BuilderQuote(item.icon) .. ")")
        elseif item.type == "Input" then
            table.insert(out, "self:AddGameInput(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "TextArea" then
            table.insert(out, "self:AddGameTextArea(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "ComboBox" then
            table.insert(out, "self:AddGameCombo(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "ProgressBar" then
            table.insert(out, "self:AddGameProgress(" .. name .. ", " .. tostring(item.value or 50) .. ", " .. tostring(item.max or 100) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "SliderH" then
            table.insert(out, "self:AddGameSliderH(" .. name .. ", " .. tostring(item.value or 50) .. ", " .. tostring(item.max or 100) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "IconButton" then
            table.insert(out, "self:AddGameIconButton(" .. name .. ", " .. Xaou_BuilderQuote(item.icon) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "IconTextButton" then
            table.insert(out, "self:AddGameIconTextButton(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. Xaou_BuilderQuote(item.icon) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "Tip" then
            table.insert(out, "self:AddGameTip(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "WindowFrame" then
            table.insert(out, "self:AddGameWindowFrame(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        else
            table.insert(out, "self:AddUIObject(" .. name .. ", " .. Xaou_BuilderQuote(item.type) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ", { text=" .. Xaou_BuilderQuote(item.text) .. ", icon=" .. Xaou_BuilderQuote(item.icon) .. ", value=" .. tostring(item.value or 50) .. ", max=" .. tostring(item.max or 100) .. " })")
        end
    end
    self.uiBuilderLastLua = table.concat(out, "\n")
    self.uiExplorerLastDump = self.uiBuilderLastLua
    Xaou_Show("สร้าง Lua แล้ว\nกด Export เพื่อบันทึกไฟล์\n\n" .. string.sub(self.uiBuilderLastLua, 1, 700), "UI Builder V8")
end

local Xaou_V8_OldRefreshUIBuilderPage = XaouItemWindow.RefreshUIBuilderPage
function XaouItemWindow:RefreshUIBuilderPage()
    Xaou_V8_OldRefreshUIBuilderPage(self)
    if tostring(self.mainMode or "") ~= "ui_builder" then return end
    self.itemButtons = self.itemButtons or {}
    local function add(o) if o ~= nil then table.insert(self.itemButtons, o) end return o end

    -- Component เพิ่มเติม ด้านซ้ายล่าง
    add(self:AddButton("btnBuildAddWindow", "Window", -60, 515, 130, 34))
    add(self:AddButton("btnBuildAddCheck", "Check", 80, 155, 90, 34))
    add(self:AddButton("btnBuildAddRadio", "Radio", 80, 195, 90, 34))
    add(self:AddButton("btnBuildAddTab", "Tab", 80, 235, 90, 34))
    add(self:AddButton("btnBuildAddListItem", "ListItem", 80, 275, 90, 34))

    -- Tools เพิ่มเติม
    add(self:AddButton("btnBuildDuplicate", "Copy", 760, 475, 80, 34))
    add(self:AddButton("btnBuildText", "Text+", 670, 520, 80, 34))
    add(self:AddButton("btnBuildIcon", "Icon+", 760, 520, 80, 34))
    add(self:AddButton("btnBuildSnap", (self.uiBuilderSnap == true and "Snap ON" or "Snap OFF"), 850, 325, 90, 34))
    add(self:AddButton("btnBuildStep", "Step " .. tostring(self.uiBuilderStep or 10), 850, 370, 90, 34))

    local extra = self:AddLabel("txtBuilderV8Info", "V8: Snap / Step / Copy / Text+ / Icon+", 670, 600, 280, 24)
    pcall(function() extra.touchable = false end)
    add(extra)
end

local Xaou_V8_OldOnObjectEvent = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil and tostring(self.mainMode or "") == "ui_builder" then
        if obj.name == "btnBuildAddWindow" then self:UIBuilderAdd("WindowFrame"); return true end
        if obj.name == "btnBuildAddCheck" then self:UIBuilderAdd("Checkbox"); return true end
        if obj.name == "btnBuildAddRadio" then self:UIBuilderAdd("RadioButton"); return true end
        if obj.name == "btnBuildAddTab" then self:UIBuilderAdd("TabButton"); return true end
        if obj.name == "btnBuildAddListItem" then self:UIBuilderAdd("ListItem"); return true end
        if obj.name == "btnBuildDuplicate" then self:UIBuilderDuplicate(); return true end
        if obj.name == "btnBuildText" then self:UIBuilderCycleText(); return true end
        if obj.name == "btnBuildIcon" then self:UIBuilderCycleIcon(); return true end
        if obj.name == "btnBuildSnap" then self:UIBuilderToggleSnap(); return true end
        if obj.name == "btnBuildStep" then self:UIBuilderCycleStep(); return true end
    end
    return Xaou_V8_OldOnObjectEvent(self, t, obj, context)
end

-- ============================================================
-- XAOU FAIRYGUI BUILDER V9 PATCH
-- เพิ่ม Layer / Align / Value / Project Export / Inspector เพิ่มเติม
-- หมายเหตุ: ระบบลากด้วยเมาส์ใน FairyGUI runtime ยังไม่เสถียรบนมือถือ จึงทำเป็นปุ่มควบคุมละเอียดก่อน
-- ============================================================

function XaouItemWindow:UIBuilderIndexOfSelected()
    local name = tostring(self.uiBuilderSelected or "")
    if name == "" then return nil end
    for i, item in ipairs(self.uiBuilderItems or {}) do
        if tostring(item.name) == name then return i end
    end
    return nil
end

function XaouItemWindow:UIBuilderBringFront()
    local idx = self:UIBuilderIndexOfSelected()
    if idx == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local item = table.remove(self.uiBuilderItems, idx)
    table.insert(self.uiBuilderItems, item)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderSendBack()
    local idx = self:UIBuilderIndexOfSelected()
    if idx == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local item = table.remove(self.uiBuilderItems, idx)
    table.insert(self.uiBuilderItems, 1, item)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderMoveLayer(delta)
    local idx = self:UIBuilderIndexOfSelected()
    if idx == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local newIndex = idx + (tonumber(delta) or 0)
    if newIndex < 1 then newIndex = 1 end
    if newIndex > #(self.uiBuilderItems or {}) then newIndex = #(self.uiBuilderItems or {}) end
    if newIndex == idx then return end
    local item = table.remove(self.uiBuilderItems, idx)
    table.insert(self.uiBuilderItems, newIndex, item)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderAlign(which)
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    local canvasX, canvasY, canvasW, canvasH = 190, 165, 505, 330
    local w = tonumber(item.w or 80) or 80
    local h = tonumber(item.h or 30) or 30
    which = tostring(which or "")

    if which == "left" then
        item.x = canvasX + 15
    elseif which == "center" then
        item.x = canvasX + math.floor((canvasW - w) / 2)
    elseif which == "right" then
        item.x = canvasX + canvasW - w - 15
    elseif which == "top" then
        item.y = canvasY + 35
    elseif which == "middle" then
        item.y = canvasY + math.floor((canvasH - h) / 2)
    elseif which == "bottom" then
        item.y = canvasY + canvasH - h - 20
    end

    item.x = self:UIBuilderSnapValue(item.x)
    item.y = self:UIBuilderSnapValue(item.y)
    self:RefreshList()
end

function XaouItemWindow:UIBuilderAdjustValue(delta)
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    item.value = tonumber(item.value or 0) or 0
    item.max = tonumber(item.max or 100) or 100
    item.value = item.value + (tonumber(delta) or 0)
    if item.value < 0 then item.value = 0 end
    if item.value > item.max then item.value = item.max end
    self:RefreshList()
end

function XaouItemWindow:UIBuilderCycleName()
    local item = self:UIBuilderGetSelected()
    if item == nil then Xaou_Show("ยังไม่ได้เลือก Component", "UI Builder"); return end
    self.uiBuilderNameIndex = (tonumber(self.uiBuilderNameIndex or 0) or 0) + 1
    local names = {"btnOK", "btnCancel", "btnSearch", "txtTitle", "inputSearch", "panelMain", "iconMain"}
    item.name = names[((self.uiBuilderNameIndex - 1) % #names) + 1] .. "_" .. tostring(self.uiBuilderNameIndex)
    self.uiBuilderSelected = item.name
    self:RefreshList()
end

local function Xaou_BuilderProjectQuote(s)
    s = tostring(s or "")
    s = string.gsub(s, "\\", "\\\\")
    s = string.gsub(s, "\r", "\\r")
    s = string.gsub(s, "\n", "\\n")
    s = string.gsub(s, '"', '\\"')
    return '"' .. s .. '"'
end

function XaouItemWindow:UIBuilderMakeProject()
    self:UIBuilderEnsure()
    local out = {}
    table.insert(out, "-- Auto generated by Xaou UI Builder V9")
    table.insert(out, "-- Project data: เก็บ Layout ไว้เปิด/แก้ต่อในอนาคต")
    table.insert(out, "return {")
    table.insert(out, "    version = \"V9\",")
    table.insert(out, "    items = {")
    for _, item in ipairs(self.uiBuilderItems or {}) do
        table.insert(out, "        {")
        table.insert(out, "            name = " .. Xaou_BuilderProjectQuote(item.name) .. ",")
        table.insert(out, "            type = " .. Xaou_BuilderProjectQuote(item.type) .. ",")
        table.insert(out, "            x = " .. tostring(tonumber(item.x) or 0) .. ", y = " .. tostring(tonumber(item.y) or 0) .. ",")
        table.insert(out, "            w = " .. tostring(tonumber(item.w) or 100) .. ", h = " .. tostring(tonumber(item.h) or 30) .. ",")
        table.insert(out, "            text = " .. Xaou_BuilderProjectQuote(item.text or "") .. ",")
        table.insert(out, "            icon = " .. Xaou_BuilderProjectQuote(item.icon or "") .. ",")
        table.insert(out, "            value = " .. tostring(tonumber(item.value) or 0) .. ", max = " .. tostring(tonumber(item.max) or 100) .. ",")
        table.insert(out, "        },")
    end
    table.insert(out, "    },")
    table.insert(out, "}")
    self.uiBuilderProjectLua = table.concat(out, "\n")
    self.uiExplorerLastDump = self.uiBuilderProjectLua
    Xaou_Show("สร้าง Project Lua แล้ว\nกด Export เพื่อบันทึกไฟล์\n\n" .. string.sub(self.uiBuilderProjectLua, 1, 700), "UI Builder V9")
end

function XaouItemWindow:UIBuilderInspectorTextV9()
    local item = self:UIBuilderGetSelected()
    if item == nil then return "Inspector V9\nเลือก: -" end
    local idx = self:UIBuilderIndexOfSelected() or 0
    return "Inspector V9"
        .. "\nname: " .. tostring(item.name)
        .. "\ntype: " .. tostring(item.type)
        .. "\nx,y: " .. tostring(item.x) .. ", " .. tostring(item.y)
        .. "\nw,h: " .. tostring(item.w) .. ", " .. tostring(item.h)
        .. "\ntext: " .. tostring(item.text or "")
        .. "\nicon: " .. tostring(item.icon or "")
        .. "\nvalue: " .. tostring(item.value or "") .. "/" .. tostring(item.max or "")
        .. "\nlayer: " .. tostring(idx) .. "/" .. tostring(#(self.uiBuilderItems or {}))
end

local Xaou_V9_OldRefreshUIBuilderPage = XaouItemWindow.RefreshUIBuilderPage
function XaouItemWindow:RefreshUIBuilderPage()
    Xaou_V9_OldRefreshUIBuilderPage(self)
    if tostring(self.mainMode or "") ~= "ui_builder" then return end
    self.itemButtons = self.itemButtons or {}
    local function add(o) if o ~= nil then table.insert(self.itemButtons, o) end return o end

    -- Layer controls
    add(self:AddButton("btnBuildFront", "Front", 850, 415, 90, 30))
    add(self:AddButton("btnBuildBackLayer", "Back", 850, 450, 90, 30))

    -- Align controls
    add(self:AddButton("btnBuildAlignL", "L", 670, 280, 45, 30))
    add(self:AddButton("btnBuildAlignC", "C", 720, 280, 45, 30))
    add(self:AddButton("btnBuildAlignR", "R", 770, 280, 45, 30))
    add(self:AddButton("btnBuildAlignT", "T", 820, 280, 45, 30))
    add(self:AddButton("btnBuildAlignM", "M", 870, 280, 45, 30))
    add(self:AddButton("btnBuildAlignB", "B", 920, 280, 45, 30))

    -- Value / Name / Project
    add(self:AddButton("btnBuildValueDown", "Val-", 850, 485, 90, 30))
    add(self:AddButton("btnBuildValueUp", "Val+", 850, 520, 90, 30))
    add(self:AddButton("btnBuildName", "Name+", 570, 520, 90, 34))
    add(self:AddButton("btnBuildProject", "Project", 570, 565, 90, 34))

    local detail = self:AddLabel("txtBuilderV9Inspector", self:UIBuilderInspectorTextV9(), 570, 330, 95, 170)
    pcall(function() detail.touchable = false end)
    add(detail)
end

local Xaou_V9_OldOnObjectEvent = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil and tostring(self.mainMode or "") == "ui_builder" then
        if obj.name == "btnBuildFront" then self:UIBuilderBringFront(); return true end
        if obj.name == "btnBuildBackLayer" then self:UIBuilderSendBack(); return true end
        if obj.name == "btnBuildAlignL" then self:UIBuilderAlign("left"); return true end
        if obj.name == "btnBuildAlignC" then self:UIBuilderAlign("center"); return true end
        if obj.name == "btnBuildAlignR" then self:UIBuilderAlign("right"); return true end
        if obj.name == "btnBuildAlignT" then self:UIBuilderAlign("top"); return true end
        if obj.name == "btnBuildAlignM" then self:UIBuilderAlign("middle"); return true end
        if obj.name == "btnBuildAlignB" then self:UIBuilderAlign("bottom"); return true end
        if obj.name == "btnBuildValueDown" then self:UIBuilderAdjustValue(-10); return true end
        if obj.name == "btnBuildValueUp" then self:UIBuilderAdjustValue(10); return true end
        if obj.name == "btnBuildName" then self:UIBuilderCycleName(); return true end
        if obj.name == "btnBuildProject" then self:UIBuilderMakeProject(); return true end
    end
    return Xaou_V9_OldOnObjectEvent(self, t, obj, context)
end

-- Make Lua V9: ใส่ Layer ตามลำดับในตาราง และรองรับชื่อที่แก้ใน Inspector
local Xaou_V9_OldMakeLua = XaouItemWindow.UIBuilderMakeLua
function XaouItemWindow:UIBuilderMakeLua()
    self:UIBuilderEnsure()
    local out = {}
    table.insert(out, "-- Auto generated by Xaou UI Builder V9")
    table.insert(out, "-- นำไปวางใน Refresh/OnInit ของหน้าต่างได้")
    table.insert(out, "-- Layer เรียงตามลำดับใน Builder: ตัวท้ายอยู่บนสุด")
    table.insert(out, "")
    for _, item in ipairs(self.uiBuilderItems or {}) do
        local name = Xaou_BuilderQuote(item.name)
        local x, y, w, h = tonumber(item.x) or 0, tonumber(item.y) or 0, tonumber(item.w) or 100, tonumber(item.h) or 30
        if item.type == "Button" then
            table.insert(out, "self:AddGameButton(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ", " .. Xaou_BuilderQuote(item.icon) .. ")")
        elseif item.type == "Input" then
            table.insert(out, "self:AddGameInput(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "TextArea" then
            table.insert(out, "self:AddGameTextArea(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "ComboBox" then
            table.insert(out, "self:AddGameCombo(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "ProgressBar" then
            table.insert(out, "self:AddGameProgress(" .. name .. ", " .. tostring(item.value or 50) .. ", " .. tostring(item.max or 100) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "SliderH" then
            table.insert(out, "self:AddGameSliderH(" .. name .. ", " .. tostring(item.value or 50) .. ", " .. tostring(item.max or 100) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "IconButton" then
            table.insert(out, "self:AddGameIconButton(" .. name .. ", " .. Xaou_BuilderQuote(item.icon) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "IconTextButton" then
            table.insert(out, "self:AddGameIconTextButton(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. Xaou_BuilderQuote(item.icon) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "Tip" then
            table.insert(out, "self:AddGameTip(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        elseif item.type == "WindowFrame" then
            table.insert(out, "self:AddGameWindowFrame(" .. name .. ", " .. Xaou_BuilderQuote(item.text) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ")")
        else
            table.insert(out, "self:AddUIObject(" .. name .. ", " .. Xaou_BuilderQuote(item.type) .. ", " .. x .. ", " .. y .. ", " .. w .. ", " .. h .. ", { text=" .. Xaou_BuilderQuote(item.text) .. ", icon=" .. Xaou_BuilderQuote(item.icon) .. ", value=" .. tostring(item.value or 50) .. ", max=" .. tostring(item.max or 100) .. " })")
        end
    end
    self.uiBuilderLastLua = table.concat(out, "\n")
    self.uiExplorerLastDump = self.uiBuilderLastLua
    Xaou_Show("สร้าง Lua แล้ว\nกด Export เพื่อบันทึกไฟล์\n\n" .. string.sub(self.uiBuilderLastLua, 1, 700), "UI Builder V9")
end

-- ============================================================
-- XAOU LAYOUT EDITOR V10 (REAL UI EDIT MODE)
-- แก้ตำแหน่ง/ขนาด Object จริงบน XaouItemWindow ไม่ใช่ Canvas ทดลอง
-- ============================================================

function XaouItemWindow:UILayoutEnsure()
    self.uiLayoutSelected = self.uiLayoutSelected or "btnModeItem"
    self.uiLayoutStep = tonumber(self.uiLayoutStep or 10) or 10
    self.uiLayoutObjects = self.uiLayoutObjects or {
        { name="btnModeItem", label="ไอเทม" },
        { name="btnModeBook", label="คัมภีร์" },
        { name="btnModeNpc", label="NPC" },
        { name="btnModeUi", label="UI" },
        { name="btnClose", label="ปิด" },
        { name="inputSearch", label="ช่องค้นหา" },
        { name="btnSearch", label="ปุ่มค้นหา" },
        { name="btnAll", label="ทั้งหมด" },
        { name="btnPrev", label="ก่อนหน้า" },
        { name="btnNext", label="ถัดไป" },
        { name="btnRefresh", label="รีเฟรช" },
        { name="btnViewMode", label="ตาราง/รายการ" },
    }
end

function XaouItemWindow:UIGetObjectByName(name)
    name = tostring(name or "")
    if name == "" then return nil end

    -- fields ที่สร้างไว้ใน OnInit
    local direct = self[name]
    if direct ~= nil then return direct end

    -- object หลักบางตัวไม่ได้เก็บเป็น field ให้ลองหาใน window children
    local ok, n = pcall(function() return tonumber(self.numChildren) or 0 end)
    if ok and n ~= nil then
        for i = 0, n - 1 do
            local ok2, c = pcall(function() return self:GetChildAt(i) end)
            if ok2 and c ~= nil and tostring(c.name or "") == name then return c end
        end
    end

    -- ลองผ่าน window object
    ok, n = pcall(function() return self.window ~= nil and (tonumber(self.window.numChildren) or 0) or 0 end)
    if ok and n ~= nil then
        for i = 0, n - 1 do
            local ok2, c = pcall(function() return self.window:GetChildAt(i) end)
            if ok2 and c ~= nil and tostring(c.name or "") == name then return c end
        end
    end

    return nil
end

function XaouItemWindow:UIGetSelectedLayoutObject()
    self:UILayoutEnsure()
    return self:UIGetObjectByName(self.uiLayoutSelected)
end

local function Xaou_UI_ObjNum(obj, key, fallback)
    local ok, v = pcall(function() return obj[key] end)
    if ok and v ~= nil then return tonumber(v) or fallback end
    return fallback
end

function XaouItemWindow:UILayoutGetInfo()
    self:UILayoutEnsure()
    local obj = self:UIGetSelectedLayoutObject()
    if obj == nil then
        return "Layout Editor\nเลือก: " .. tostring(self.uiLayoutSelected or "-") .. "\nไม่พบ object"
    end
    local x = Xaou_UI_ObjNum(obj, "x", 0)
    local y = Xaou_UI_ObjNum(obj, "y", 0)
    local w = Xaou_UI_ObjNum(obj, "width", 0)
    local h = Xaou_UI_ObjNum(obj, "height", 0)
    local text = ""
    pcall(function() text = tostring(obj.text or "") end)
    pcall(function() if text == "" and obj.m_title ~= nil then text = tostring(obj.m_title.text or "") end end)
    local typ = ""
    pcall(function() if obj.GetType ~= nil then typ = tostring(obj:GetType().Name or "") end end)
    return "Layout Editor V10"
        .. "\nเลือก: " .. tostring(self.uiLayoutSelected or "-")
        .. "\ntype: " .. tostring(typ)
        .. "\nx,y: " .. tostring(math.floor(x)) .. ", " .. tostring(math.floor(y))
        .. "\nw,h: " .. tostring(math.floor(w)) .. ", " .. tostring(math.floor(h))
        .. "\nstep: " .. tostring(self.uiLayoutStep or 10)
        .. "\ntext: " .. tostring(text)
end

function XaouItemWindow:UILayoutSetObjectRect(obj, x, y, w, h)
    if obj == nil then return end
    pcall(function()
        if obj.SetXY ~= nil then obj:SetXY(x, y) else obj.x = x; obj.y = y end
    end)
    pcall(function()
        if obj.SetSize ~= nil then obj:SetSize(w, h, false) else obj.width = w; obj.height = h end
    end)
end

function XaouItemWindow:UILayoutMove(dx, dy)
    local obj = self:UIGetSelectedLayoutObject()
    if obj == nil then Xaou_Show("ไม่พบ object ที่เลือก", "Layout Editor"); return end
    local step = tonumber(self.uiLayoutStep or 10) or 10
    local sx, sy = 0, 0
    if tonumber(dx or 0) > 0 then sx = step elseif tonumber(dx or 0) < 0 then sx = -step end
    if tonumber(dy or 0) > 0 then sy = step elseif tonumber(dy or 0) < 0 then sy = -step end
    local x = Xaou_UI_ObjNum(obj, "x", 0) + sx
    local y = Xaou_UI_ObjNum(obj, "y", 0) + sy
    local w = Xaou_UI_ObjNum(obj, "width", 100)
    local h = Xaou_UI_ObjNum(obj, "height", 30)
    self:UILayoutSetObjectRect(obj, x, y, w, h)
    self:RefreshList()
end

function XaouItemWindow:UILayoutResize(dw, dh)
    local obj = self:UIGetSelectedLayoutObject()
    if obj == nil then Xaou_Show("ไม่พบ object ที่เลือก", "Layout Editor"); return end
    local step = tonumber(self.uiLayoutStep or 10) or 10
    local sw, sh = 0, 0
    if tonumber(dw or 0) > 0 then sw = step elseif tonumber(dw or 0) < 0 then sw = -step end
    if tonumber(dh or 0) > 0 then sh = step elseif tonumber(dh or 0) < 0 then sh = -step end
    local x = Xaou_UI_ObjNum(obj, "x", 0)
    local y = Xaou_UI_ObjNum(obj, "y", 0)
    local w = Xaou_BuilderClamp(Xaou_UI_ObjNum(obj, "width", 100) + sw, 10, 1200)
    local h = Xaou_BuilderClamp(Xaou_UI_ObjNum(obj, "height", 30) + sh, 10, 800)
    self:UILayoutSetObjectRect(obj, x, y, w, h)
    self:RefreshList()
end

function XaouItemWindow:UILayoutCycleStep()
    local steps = {1, 5, 10, 20, 40}
    local cur = tonumber(self.uiLayoutStep or 10) or 10
    local nextv = 10
    for i, v in ipairs(steps) do
        if v == cur then nextv = steps[i + 1] or steps[1]; break end
    end
    self.uiLayoutStep = nextv
    self:RefreshList()
end

function XaouItemWindow:UILayoutMakeLua()
    self:UILayoutEnsure()
    local out = {}
    table.insert(out, "-- Auto generated by Xaou Layout Editor V10")
    table.insert(out, "-- วางหลังสร้าง object แล้ว เช่น ท้าย OnInit หรือหลังสร้างปุ่ม")
    table.insert(out, "")
    for _, data in ipairs(self.uiLayoutObjects or {}) do
        local name = tostring(data.name or "")
        local obj = self:UIGetObjectByName(name)
        if obj ~= nil then
            local x = math.floor(Xaou_UI_ObjNum(obj, "x", 0))
            local y = math.floor(Xaou_UI_ObjNum(obj, "y", 0))
            local w = math.floor(Xaou_UI_ObjNum(obj, "width", 100))
            local h = math.floor(Xaou_UI_ObjNum(obj, "height", 30))
            table.insert(out, "pcall(function()")
            table.insert(out, "    local obj = self:" .. "UIGetObjectByName(" .. Xaou_BuilderQuote(name) .. ")")
            table.insert(out, "    if obj ~= nil then")
            table.insert(out, "        if obj.SetXY ~= nil then obj:SetXY(" .. x .. ", " .. y .. ") else obj.x = " .. x .. "; obj.y = " .. y .. " end")
            table.insert(out, "        if obj.SetSize ~= nil then obj:SetSize(" .. w .. ", " .. h .. ", false) else obj.width = " .. w .. "; obj.height = " .. h .. " end")
            table.insert(out, "    end")
            table.insert(out, "end)")
            table.insert(out, "")
        end
    end
    self.uiLayoutLastLua = table.concat(out, "\n")
    self.uiExplorerLastDump = self.uiLayoutLastLua
    Xaou_Show("สร้าง Layout Lua แล้ว\nกด Export เพื่อบันทึกไฟล์\n\n" .. string.sub(self.uiLayoutLastLua, 1, 700), "Layout Editor")
end

function XaouItemWindow:RefreshUILayoutEditorPage()
    self:UILayoutEnsure()
    self:ClearItemButtons()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}
    self.uiButtonData = {}

    pcall(function() self:SetTitle("Layout Editor") end)
    if self.statusLine1 ~= nil then self.statusLine1.m_title.text = "โหมด : Layout Editor | แก้ตำแหน่ง Object จริง" end
    if self.statusLine2 ~= nil then self.statusLine2.m_title.text = "เลือก object ด้านซ้าย แล้วขยับ/Resize ได้ทันที" end

    local function add(o) if o ~= nil then table.insert(self.itemButtons, o) end return o end

    add(self:AddLabel("txtLayoutHelp", "เลือก Object จริง", 60, 150, 180, 26))
    local startX, startY = 45, 180
    for i, data in ipairs(self.uiLayoutObjects or {}) do
        local y = startY + (i - 1) * 34
        local text = tostring(data.label or data.name)
        if tostring(data.name) == tostring(self.uiLayoutSelected) then text = "▶ " .. text end
        local btn = add(self:AddButton("btnLayoutPick_" .. tostring(data.name), text, startX, y, 155, 30, nil))
        if btn ~= nil then btn.tooltips = tostring(data.name) end
    end

    -- กรอบ/ดาวชี้ตัวที่เลือกบน UI จริง
    local obj = self:UIGetSelectedLayoutObject()
    if obj ~= nil then
        local x = Xaou_UI_ObjNum(obj, "x", 0)
        local y = Xaou_UI_ObjNum(obj, "y", 0)
        local w = Xaou_UI_ObjNum(obj, "width", 80)
        local mark = add(self:AddButton("btnLayoutMark", "★", x + w - 26, y - 8, 28, 24, nil))
        if mark ~= nil then mark.tooltips = "กำลังเลือก: " .. tostring(self.uiLayoutSelected) end
    end

    -- ปุ่มควบคุม
    add(self:AddButton("btnLayoutUp", "▲", 735, 195, 60, 34, nil))
    add(self:AddButton("btnLayoutLeft", "◀", 670, 235, 60, 34, nil))
    add(self:AddButton("btnLayoutRight", "▶", 800, 235, 60, 34, nil))
    add(self:AddButton("btnLayoutDown", "▼", 735, 275, 60, 34, nil))
    add(self:AddButton("btnLayoutBigger", "+Size", 670, 335, 90, 34, nil))
    add(self:AddButton("btnLayoutSmaller", "-Size", 770, 335, 90, 34, nil))
    add(self:AddButton("btnLayoutStep", "Step " .. tostring(self.uiLayoutStep or 10), 670, 380, 90, 34, nil))
    add(self:AddButton("btnLayoutLua", "Make Lua", 670, 430, 90, 34, nil))
    add(self:AddButton("btnLayoutExport", "Export", 770, 430, 90, 34, nil))
    add(self:AddButton("btnLayoutBack", "◀ UI", 670, 515, 120, 34, nil))

    local info = add(self:AddLabel("txtLayoutInfo", self:UILayoutGetInfo(), 670, 470, 250, 95))
    pcall(function() if info ~= nil then info.touchable = false end end)

    if self.pageText ~= nil then
        self.pageText.visible = true
        self.pageText.m_title.text = "Layout Editor: Real Objects"
    end
end

-- เพิ่มปุ่ม Layout ในหน้า UI Explorer
local Xaou_V10_OldRefreshUIExplorerPage = XaouItemWindow.RefreshUIExplorerPage
if Xaou_V10_OldRefreshUIExplorerPage ~= nil then
    function XaouItemWindow:RefreshUIExplorerPage()
        Xaou_V10_OldRefreshUIExplorerPage(self)
        if tostring(self.mainMode or "") == "ui" then
            self.itemButtons = self.itemButtons or {}
            local btn = self:AddButton("btnUILayoutEditor", "Layout", 720, 430, 120, 34, nil)
            table.insert(self.itemButtons, btn)
        end
    end
end

local Xaou_V10_OldRefreshList = XaouItemWindow.RefreshList
function XaouItemWindow:RefreshList()
    if tostring(self.mainMode or "") == "ui_layout" then
        self:RefreshUILayoutEditorPage()
        return
    end
    return Xaou_V10_OldRefreshList(self)
end

local Xaou_V10_OldSetMainMode = XaouItemWindow.SetMainMode
function XaouItemWindow:SetMainMode(mode)
    mode = tostring(mode or "item")
    if mode == "ui_layout" then
        self.mainMode = "ui_layout"
        self.page = 1
        pcall(function() self:SetTopCategoryVisible(false) end)
        pcall(function() self:SetTitle("Layout Editor") end)
        pcall(function() self:ForceMainPosition() end)
        self:RefreshList()
        pcall(function() self:UpdateBottomLayout() end)
        return
    end
    return Xaou_V10_OldSetMainMode(self, mode)
end

local Xaou_V10_OldOnObjectEvent = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil then
        if obj.name == "btnUILayoutEditor" then self:SetMainMode("ui_layout"); return true end
        if tostring(self.mainMode or "") == "ui_layout" then
            local nm = tostring(obj.name or "")
            local pickPrefix = "btnLayoutPick_"
            if string.sub(nm, 1, string.len(pickPrefix)) == pickPrefix then
                self.uiLayoutSelected = string.sub(nm, string.len(pickPrefix) + 1)
                self:RefreshList(); return true
            end
            -- กันไม่ให้กด object จริงแล้วไปเปลี่ยนหน้า ระหว่างอยู่ Layout Editor
            for _, data in ipairs(self.uiLayoutObjects or {}) do
                if nm == tostring(data.name or "") then
                    self.uiLayoutSelected = nm
                    self:RefreshList(); return true
                end
            end
            if nm == "btnLayoutUp" then self:UILayoutMove(0, -1); return true end
            if nm == "btnLayoutDown" then self:UILayoutMove(0, 1); return true end
            if nm == "btnLayoutLeft" then self:UILayoutMove(-1, 0); return true end
            if nm == "btnLayoutRight" then self:UILayoutMove(1, 0); return true end
            if nm == "btnLayoutBigger" then self:UILayoutResize(1, 1); return true end
            if nm == "btnLayoutSmaller" then self:UILayoutResize(-1, -1); return true end
            if nm == "btnLayoutStep" then self:UILayoutCycleStep(); return true end
            if nm == "btnLayoutLua" then self:UILayoutMakeLua(); return true end
            if nm == "btnLayoutExport" then self:UILayoutMakeLua(); self:UIExplorerExport(); return true end
            if nm == "btnLayoutBack" then self:SetMainMode("ui"); return true end
        end
    end
    return Xaou_V10_OldOnObjectEvent(self, t, obj, context)
end

local Xaou_V10_OldUpdateBottomLayout = XaouItemWindow.UpdateBottomLayout
if Xaou_V10_OldUpdateBottomLayout ~= nil then
    function XaouItemWindow:UpdateBottomLayout()
        pcall(function() Xaou_V10_OldUpdateBottomLayout(self) end)
        if tostring(self.mainMode or "") == "ui_layout" then
            local function show(obj, v) if obj ~= nil then pcall(function() obj.visible = v end) end end
            show(self.btnPrev, false)
            show(self.btnNext, false)
            show(self.btnRefresh, false)
            show(self.btnViewMode, false)
            show(self.btnClose, true)
            show(self.btnModeItem, true)
            show(self.btnModeBook, true)
            show(self.btnModeNpc, true)
            show(self.btnModeUi, true)
        end
    end
end
