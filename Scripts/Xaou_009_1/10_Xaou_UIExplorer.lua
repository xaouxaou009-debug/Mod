-- ============================================================
-- XAOU UI EXPLORER V5
-- สำรวจ ui://0xrxw6g7hdhl... + สร้างฐานข้อมูล FairyGUI
-- โหลดหลัง 01-09
-- ============================================================

if XaouItemWindow == nil and _G ~= nil then
    XaouItemWindow = _G.XaouItemWindow
end

Xaou_UIExplorerEntries = Xaou_UIExplorerEntries or {
    {key="hdhl0",  url="ui://0xrxw6g7hdhl0",  note="UI_ListItem"},
    {key="hdhl3",  url="ui://0xrxw6g7hdhl3",  note="UI_ScrollBar_arrow"},
    {key="hdhl6",  url="ui://0xrxw6g7hdhl6",  note="UI_ScrollBar_grip"},
    {key="hdhl7",  url="ui://0xrxw6g7hdhl7",  note="UI_ComboBox_popup"},
    {key="hdhl9",  url="ui://0xrxw6g7hdhl9",  note="UI_WindowCloseButton"},
    {key="hdhl18", url="ui://0xrxw6g7hdhl18", note="UI_Button"},
    {key="hdhl1a", url="ui://0xrxw6g7hdhl1a", note="UI_Checkbox"},
    {key="hdhl1b", url="ui://0xrxw6g7hdhl1b", note="UI_RadioButton"},
    {key="hdhl1c", url="ui://0xrxw6g7hdhl1c", note="UI_InputTextField"},
    {key="hdhl1d", url="ui://0xrxw6g7hdhl1d", note="UI_InputTextArea"},
    {key="hdhl1e", url="ui://0xrxw6g7hdhl1e", note="UI_SliderH"},
    {key="hdhl1f", url="ui://0xrxw6g7hdhl1f", note="UI_Button_icon"},
    {key="hdhl1g", url="ui://0xrxw6g7hdhl1g", note="UI_SliderV"},
    {key="hdhl1h", url="ui://0xrxw6g7hdhl1h", note="UI_ProgressBar"},
    {key="hdhl1i", url="ui://0xrxw6g7hdhl1i", note="UI_ComboBox"},
    {key="hdhl1j", url="ui://0xrxw6g7hdhl1j", note="UI_WindowFrame"},
    {key="hdhl1k", url="ui://0xrxw6g7hdhl1k", note="UI_Button_icon_text"},
    {key="hdhl1l", url="ui://0xrxw6g7hdhl1l", note="UI_TabButton"},
    {key="hdhl1m", url="ui://0xrxw6g7hdhl1m", note="UI_ScrollBarH"},
    {key="hdhl1n", url="ui://0xrxw6g7hdhl1n", note="UI_ScrollBarV"},
    {key="hdhl1o", url="ui://0xrxw6g7hdhl1o", note="UI_WindowBuildingProduce"},
    {key="hdhl1q", url="ui://0xrxw6g7hdhl1q", note="UI_Bnt_ProduceItem"},
    {key="hdhl1t", url="ui://0xrxw6g7hdhl1t", note="UI_Tip"},
}

local function Xaou_UI_LuaQuote(v)
    v = tostring(v or "")
    v = string.gsub(v, "\\", "\\\\")
    v = string.gsub(v, "\r", "\\r")
    v = string.gsub(v, "\n", "\\n")
    v = string.gsub(v, '"', '\\"')
    return '"' .. v .. '"'
end

local function Xaou_UI_GetTypeName(obj)
    local ok, v = pcall(function()
        if obj ~= nil and obj.GetType ~= nil then return obj:GetType().Name end
        return nil
    end)
    if ok and v ~= nil then return tostring(v) end
    return tostring(obj)
end

local function Xaou_UI_TryGet(obj, label, fn, lines)
    local ok, v = pcall(fn)
    if ok and v ~= nil then table.insert(lines, label .. "=" .. tostring(v)) end
end

local function Xaou_UI_Inspect(obj, title)
    local lines = {}
    table.insert(lines, tostring(title or "UI Object"))
    if obj == nil then
        table.insert(lines, "object=nil")
        return lines
    end
    table.insert(lines, "type=" .. Xaou_UI_GetTypeName(obj))
    Xaou_UI_TryGet(obj, "name", function() return obj.name end, lines)
    Xaou_UI_TryGet(obj, "resourceURL", function() return obj.resourceURL end, lines)
    Xaou_UI_TryGet(obj, "x", function() return obj.x end, lines)
    Xaou_UI_TryGet(obj, "y", function() return obj.y end, lines)
    Xaou_UI_TryGet(obj, "width", function() return obj.width end, lines)
    Xaou_UI_TryGet(obj, "height", function() return obj.height end, lines)
    Xaou_UI_TryGet(obj, "numChildren", function() return obj.numChildren end, lines)
    Xaou_UI_TryGet(obj, "text", function() return obj.text end, lines)
    Xaou_UI_TryGet(obj, "title", function() return obj.m_title and obj.m_title.text end, lines)
    Xaou_UI_TryGet(obj, "icon", function() return obj.icon end, lines)
    Xaou_UI_TryGet(obj, "m_icon", function() return obj.m_icon and obj.m_icon.icon end, lines)
    Xaou_UI_TryGet(obj, "value", function() return obj.value end, lines)
    Xaou_UI_TryGet(obj, "max", function() return obj.max end, lines)
    return lines
end

local function Xaou_UI_DumpChildren(obj)
    local lines = {}
    if obj == nil then
        table.insert(lines, "object=nil")
        return lines
    end
    local n = 0
    pcall(function() n = tonumber(obj.numChildren) or 0 end)
    table.insert(lines, "children=" .. tostring(n))
    for i = 0, n - 1 do
        local ok, c = pcall(function() return obj:GetChildAt(i) end)
        if ok and c ~= nil then
            local s = tostring(i) .. ": " .. Xaou_UI_GetTypeName(c)
            pcall(function() s = s .. " | name=" .. tostring(c.name) end)
            pcall(function() s = s .. " | size=" .. tostring(c.width) .. "x" .. tostring(c.height) end)
            pcall(function() if c.text ~= nil then s = s .. " | text=" .. tostring(c.text) end end)
            pcall(function() if c.icon ~= nil then s = s .. " | icon=" .. tostring(c.icon) end end)
            table.insert(lines, s)
        else
            table.insert(lines, tostring(i) .. ": nil")
        end
    end
    return lines
end

local function Xaou_UI_UpdateInfoLabel(self)
    if self.uiInfoLabel ~= nil then
        pcall(function()
            self.uiInfoLabel.m_title.text = string.sub(tostring(self.uiExplorerInfoText or ""), 1, 900)
        end)
    end
end

function XaouItemWindow:UIExplorerClearPreview()
    if self.uiPreviewObjects ~= nil then
        for _, o in ipairs(self.uiPreviewObjects) do
            pcall(function() o.visible = false end)
            pcall(function() o:SetSize(0, 0, false) end)
            pcall(function() if o.parent ~= nil then o.parent:RemoveChild(o, true) end end)
        end
    end
    self.uiPreviewObjects = {}
    self.uiPreviewObj = nil
end

function XaouItemWindow:UIExplorerCreatePreview(entry)
    self:UIExplorerClearPreview()
    self.uiExplorerSelected = entry
    if entry == nil then return end

    local ok, obj = pcall(function()
        return self:AddObjectFromUrl(entry.url, 720, 165)
    end)
    if not ok or obj == nil then
        self.uiExplorerInfoText = "สร้างไม่ได้: " .. tostring(entry.url)
        Xaou_UI_UpdateInfoLabel(self)
        return
    end

    obj.name = "uiPreview_" .. tostring(entry.key)
    pcall(function() obj:SetSize(220, 95, false) end)
    pcall(function() obj.touchable = false end)
    self.uiPreviewObj = obj
    table.insert(self.uiPreviewObjects, obj)

    local lines = Xaou_UI_Inspect(obj, tostring(entry.key) .. "\n" .. tostring(entry.url))
    local childLines = Xaou_UI_DumpChildren(obj)
    for i = 1, #childLines do table.insert(lines, childLines[i]) end
    self.uiExplorerInfoText = table.concat(lines, "\n")
    Xaou_UI_UpdateInfoLabel(self)
end

function XaouItemWindow:UIExplorerScanAll()
    local out = {}
    table.insert(out, "XAOU UI EXPLORER SCAN")
    table.insert(out, "count=" .. tostring(#(Xaou_UIExplorerEntries or {})))

    for _, e in ipairs(Xaou_UIExplorerEntries or {}) do
        local ok, obj = pcall(function() return self:AddObjectFromUrl(e.url, -9999, -9999) end)
        if ok and obj ~= nil then
            pcall(function() obj.visible = false end)
            pcall(function() obj:SetSize(0, 0, false) end)
            table.insert(out, "")
            table.insert(out, "[OK] " .. tostring(e.key) .. "  " .. tostring(e.url))
            local lines = Xaou_UI_Inspect(obj, "")
            for _, l in ipairs(lines) do if l ~= "" then table.insert(out, l) end end
            local childLines = Xaou_UI_DumpChildren(obj)
            for _, l in ipairs(childLines) do table.insert(out, l) end
            pcall(function() if obj.parent ~= nil then obj.parent:RemoveChild(obj, true) end end)
        else
            table.insert(out, "")
            table.insert(out, "[FAIL] " .. tostring(e.key) .. "  " .. tostring(e.url))
        end
    end

    self.uiExplorerLastDump = table.concat(out, "\n")
    self.uiExplorerInfoText = "Scan All สำเร็จ\nกด Export เพื่อบันทึกไฟล์\nหรือกด Make DB เพื่อสร้าง Lua DB"
    Xaou_UI_UpdateInfoLabel(self)
    Xaou_Show("Scan All สำเร็จ\nเก็บผลไว้ใน memory แล้ว", "UI Explorer")
end

function XaouItemWindow:UIExplorerBuildLuaDatabase()
    local out = {}
    table.insert(out, "-- Auto generated by Xaou UI Explorer V5")
    table.insert(out, "-- Package: ui://0xrxw6g7hdhl...")
    table.insert(out, "Xaou_UI_DB = {")

    for _, e in ipairs(Xaou_UIExplorerEntries or {}) do
        local ok, obj = pcall(function() return self:AddObjectFromUrl(e.url, -9999, -9999) end)
        if ok and obj ~= nil then
            local typeName = Xaou_UI_GetTypeName(obj)
            local n = 0
            local text, title, icon, value, maxv = "", "", "", "", ""
            pcall(function() n = tonumber(obj.numChildren) or 0 end)
            pcall(function() text = tostring(obj.text or "") end)
            pcall(function() title = tostring(obj.m_title and obj.m_title.text or "") end)
            pcall(function() icon = tostring(obj.icon or "") end)
            pcall(function() if obj.m_icon ~= nil and obj.m_icon.icon ~= nil then icon = tostring(obj.m_icon.icon) end end)
            pcall(function() value = tostring(obj.value or "") end)
            pcall(function() maxv = tostring(obj.max or "") end)

            table.insert(out, "")
            table.insert(out, "    [" .. Xaou_UI_LuaQuote(e.key) .. "] = {")
            table.insert(out, "        url = " .. Xaou_UI_LuaQuote(e.url) .. ",")
            table.insert(out, "        type = " .. Xaou_UI_LuaQuote(typeName) .. ",")
            table.insert(out, "        note = " .. Xaou_UI_LuaQuote(e.note or "") .. ",")
            table.insert(out, "        text = " .. Xaou_UI_LuaQuote(text) .. ",")
            table.insert(out, "        title = " .. Xaou_UI_LuaQuote(title) .. ",")
            table.insert(out, "        icon = " .. Xaou_UI_LuaQuote(icon) .. ",")
            table.insert(out, "        value = " .. Xaou_UI_LuaQuote(value) .. ",")
            table.insert(out, "        max = " .. Xaou_UI_LuaQuote(maxv) .. ",")
            table.insert(out, "        children = {")
            for i = 0, n - 1 do
                local ok2, c = pcall(function() return obj:GetChildAt(i) end)
                if ok2 and c ~= nil then
                    local cname, ctype, ctext, cicon, cw, ch = "", Xaou_UI_GetTypeName(c), "", "", "", ""
                    pcall(function() cname = tostring(c.name or "") end)
                    pcall(function() ctext = tostring(c.text or "") end)
                    pcall(function() cicon = tostring(c.icon or "") end)
                    pcall(function() cw = tostring(c.width or "") end)
                    pcall(function() ch = tostring(c.height or "") end)
                    table.insert(out, "            { index = " .. tostring(i)
                        .. ", name = " .. Xaou_UI_LuaQuote(cname)
                        .. ", type = " .. Xaou_UI_LuaQuote(ctype)
                        .. ", size = " .. Xaou_UI_LuaQuote(cw .. "x" .. ch)
                        .. ", text = " .. Xaou_UI_LuaQuote(ctext)
                        .. ", icon = " .. Xaou_UI_LuaQuote(cicon)
                        .. " },")
                end
            end
            table.insert(out, "        },")
            table.insert(out, "    },")

            pcall(function() obj.visible = false end)
            pcall(function() obj:SetSize(0,0,false) end)
            pcall(function() if obj.parent ~= nil then obj.parent:RemoveChild(obj, true) end end)
        end
    end
    table.insert(out, "}")
    table.insert(out, "return Xaou_UI_DB")

    self.uiExplorerLastDump = table.concat(out, "\n")
    self.uiExplorerInfoText = "Make DB สำเร็จ\nกด Export เพื่อบันทึกเป็น Xaou_UI_Database.lua"
    Xaou_UI_UpdateInfoLabel(self)
    Xaou_Show("สร้าง Lua Database ใน memory แล้ว\nกด Export เพื่อบันทึกไฟล์", "UI Explorer")
end

function XaouItemWindow:UIExplorerExport()
    local text = tostring(self.uiExplorerLastDump or self.uiExplorerInfoText or "ไม่มีข้อมูล")
    local paths = {}
    local isDb = string.find(text, "Xaou_UI_DB", 1, true) ~= nil

    pcall(function()
        if CS ~= nil and CS.UnityEngine ~= nil and CS.UnityEngine.Application ~= nil then
            local base = tostring(CS.UnityEngine.Application.persistentDataPath or "")
            if base ~= "" then
                table.insert(paths, base .. "/" .. (isDb and "Xaou_UI_Database.lua" or "Xaou_UIExplorer_Dump.txt"))
            end
        end
    end)
    table.insert(paths, isDb and "Xaou_UI_Database.lua" or "Xaou_UIExplorer_Dump.txt")

    local lastErr = nil
    for _, path in ipairs(paths) do
        local ok, err = pcall(function()
            if CS ~= nil and CS.System ~= nil and CS.System.IO ~= nil and CS.System.IO.File ~= nil then
                CS.System.IO.File.WriteAllText(path, text)
            else
                error("CS.System.IO.File not found")
            end
        end)
        if ok then
            Xaou_Show("Export สำเร็จ\n" .. tostring(path), "UI Explorer")
            return true
        end
        lastErr = err
    end

    Xaou_Show("Export ไม่สำเร็จ\n" .. tostring(lastErr) .. "\n\nข้อมูลล่าสุด:\n" .. string.sub(text, 1, 900), "UI Explorer")
    return false
end

function XaouItemWindow:RefreshUIExplorerPage()
    self:ClearItemButtons()
    self:UIExplorerClearPreview()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}
    self.uiButtonData = {}

    if self.statusLine1 ~= nil then
        self.statusLine1.m_title.text = "โหมด : UI Explorer | Package: ui://0xrxw6g7hdhl..."
    end
    if self.statusLine2 ~= nil then
        self.statusLine2.m_title.text = "กด URL เพื่อ Preview | Scan All / Dump / Make DB / Export"
    end
    if self.btnViewMode ~= nil then self.btnViewMode.m_title.text = "Dump" end
    if self.btnRefresh ~= nil then self.btnRefresh.m_title.text = "Scan" end

    local entries = Xaou_UIExplorerEntries or {}
    local keyword = tostring(self.searchKeyword or "")
    local filtered = {}
    for _, e in ipairs(entries) do
        local s = tostring(e.key) .. " " .. tostring(e.url) .. " " .. tostring(e.note or "")
        if keyword == "" or string.find(string.lower(s), string.lower(keyword), 1, true) then
            table.insert(filtered, e)
        end
    end

    local pageSize = 24
    local maxPage = math.ceil(#filtered / pageSize)
    if maxPage < 1 then maxPage = 1 end
    if self.page == nil or self.page < 1 then self.page = 1 end
    if self.page > maxPage then self.page = maxPage end

    local startIndex = (self.page - 1) * pageSize + 1
    local endIndex = startIndex + pageSize - 1
    local startX, startY = 200, 185
    local cellW, cellH = 155, 36
    local gapX, gapY = 12, 8
    local cols = 3

    for i = startIndex, endIndex do
        local e = filtered[i]
        if e ~= nil then
            local idx = i - startIndex
            local col = idx % cols
            local row = math.floor(idx / cols)
            local name = "btnUIUrl" .. tostring(i)
            local btn = self:AddButton(name, tostring(e.key), startX + col * (cellW + gapX), startY + row * (cellH + gapY), cellW, cellH, nil)
            btn.tooltips = tostring(e.url) .. "\n" .. tostring(e.note or "")
            self.uiButtonData[name] = e
            table.insert(self.itemButtons, btn)
        end
    end

    local btnDB     = self:AddButton("btnUIDatabase", "Make DB", 720, 430, 120, 34, nil)
    local btnScan   = self:AddButton("btnUIScanAll",  "Scan All", 720, 470, 120, 34, nil)
    local btnDump   = self:AddButton("btnUIDump",     "Dump",     850, 470, 90,  34, nil)
    local btnExport = self:AddButton("btnUIExport",   "Export",   720, 510, 120, 34, nil)
    local btnClear  = self:AddButton("btnUIClear",    "Clear",    850, 510, 90,  34, nil)
    table.insert(self.itemButtons, btnDB)
    table.insert(self.itemButtons, btnScan)
    table.insert(self.itemButtons, btnDump)
    table.insert(self.itemButtons, btnExport)
    table.insert(self.itemButtons, btnClear)

    local title = self:AddLabel("txtUIPreviewTitle", "Preview / Inspector", 720, 145, 260, 28)
    pcall(function() title.touchable = false end)
    table.insert(self.itemButtons, title)

    local info = self:AddLabel("txtUIInfo", "เลือก URL ทางซ้าย\nถ้าสร้างได้จะแสดง Preview ตรงนี้", 720, 270, 260, 150)
    pcall(function() info.touchable = false end)
    self.uiInfoLabel = info
    table.insert(self.itemButtons, info)

    if self.uiExplorerSelected ~= nil then
        self:UIExplorerCreatePreview(self.uiExplorerSelected)
    end

    if self.pageText ~= nil then
        self.pageText.visible = true
        self.pageText.m_title.text = "UI URL " .. tostring(self.page) .. "/" .. tostring(maxPage) .. " (" .. tostring(#filtered) .. "/" .. tostring(#entries) .. ")"
    end
end

-- Hook RefreshList
local Xaou_OldRefreshList_UIExplorer = XaouItemWindow.RefreshList
function XaouItemWindow:RefreshList()
    if self.mainMode == "ui" then
        self:RefreshUIExplorerPage()
        return
    end
    return Xaou_OldRefreshList_UIExplorer(self)
end

-- Hook SetMainMode
local Xaou_OldSetMainMode_UIExplorer = XaouItemWindow.SetMainMode
function XaouItemWindow:SetMainMode(mode)
    mode = tostring(mode or "item")
    if mode == "ui" then
        self.mainMode = "ui"
        self.page = 1
        pcall(function() self:SetTitle("ทดสอบ UI URL") end)
        pcall(function() self:SetTopCategoryVisible(false) end)
        pcall(function() self:SetSize(self.sx or 980, self.sy or 620) end)
        pcall(function() self:ForceMainPosition() end)
        self:RefreshList()
        pcall(function() self:UpdateBottomLayout() end)
        return
    end
    return Xaou_OldSetMainMode_UIExplorer(self, mode)
end

-- Hook UpdateBottomLayout
local Xaou_OldUpdateBottomLayout_UIExplorer = XaouItemWindow.UpdateBottomLayout
function XaouItemWindow:UpdateBottomLayout()
    pcall(function() Xaou_OldUpdateBottomLayout_UIExplorer(self) end)
    local function show(obj, v) if obj ~= nil then pcall(function() obj.visible = v end) end end
    local function move(obj, x, y)
        if obj ~= nil then pcall(function() if obj.SetXY ~= nil then obj:SetXY(x,y) else obj.x=x; obj.y=y end end) end
    end
    show(self.btnModeUi, true)
    move(self.btnModeUi, 1000, 350)
    if tostring(self.mainMode or "") == "ui" then
        show(self.btnPrev, true)
        show(self.btnNext, true)
        show(self.pageText, true)
        show(self.btnRefresh, true)
        show(self.btnViewMode, true)
        show(self.btnClose, true)
        move(self.btnPrev, 830, 450)
        move(self.pageText, 830, 400)
        move(self.btnNext, 830, 520)
        move(self.btnRefresh, 720, 565)
        move(self.btnViewMode, 840, 565)
        move(self.btnClose, 1000, 500)
    end
end

-- Hook OnObjectEvent
local Xaou_OldOnObjectEvent_UIExplorer = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil then
        if obj.name == "btnModeUi" then
            self:SetMainMode("ui")
            return true
        end
        if self.mainMode == "ui" then
            if obj.name == "btnRefresh" or obj.name == "btnUIScanAll" then
                self:UIExplorerScanAll()
                return true
            elseif obj.name == "btnViewMode" or obj.name == "btnUIDump" then
                if self.uiPreviewObj ~= nil then
                    local lines = Xaou_UI_Inspect(self.uiPreviewObj, "Preview Object")
                    local childLines = Xaou_UI_DumpChildren(self.uiPreviewObj)
                    for _, l in ipairs(childLines) do table.insert(lines, l) end
                    self.uiExplorerLastDump = table.concat(lines, "\n")
                    self.uiExplorerInfoText = self.uiExplorerLastDump
                    Xaou_UI_UpdateInfoLabel(self)
                    Xaou_Show(string.sub(self.uiExplorerLastDump, 1, 1000), "Dump")
                else
                    Xaou_Show("ยังไม่ได้เลือก URL", "UI Explorer")
                end
                return true
            elseif obj.name == "btnUIDatabase" then
                self:UIExplorerBuildLuaDatabase()
                return true
            elseif obj.name == "btnUIExport" then
                self:UIExplorerExport()
                return true
            elseif obj.name == "btnUIClear" then
                self.uiExplorerSelected = nil
                self.uiExplorerInfoText = ""
                self:UIExplorerClearPreview()
                Xaou_UI_UpdateInfoLabel(self)
                return true
            end
            local e = nil
            if self.uiButtonData ~= nil then e = self.uiButtonData[tostring(obj.name)] end
            if e ~= nil then
                self:UIExplorerCreatePreview(e)
                return true
            end
        end
    end
    return Xaou_OldOnObjectEvent_UIExplorer(self, t, obj, context)
end
