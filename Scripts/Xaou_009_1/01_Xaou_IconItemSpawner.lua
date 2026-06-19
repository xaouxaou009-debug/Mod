-- v.10.4

local XaouItemWindow = CS.Wnd_Simple.CreateWindow("XaouItemWindow")
local XaouAmountWindow = CS.Wnd_Simple.CreateWindow("XaouAmountWindow")

-- Expose windows so split NPC files can attach methods.
_G.XaouItemWindow = XaouItemWindow
_G.XaouAmountWindow = XaouAmountWindow

-- เพิ่ม/แก้รายการตรงนี้ได้เลย
local XaouBaseItemList = {


}


local XaouItemList = nil
local XaouItemMap = nil
local XaouDatabaseSignature = ""
local XaouPackStats = { packs = 0, extra = 0, total = 0, duplicate = 0 }

-- V10.555: ใช้ช่องไอเทมแบบเกมแท้ (UI_Bnt_ProduceItem / hdhl1q) สำหรับ Grid View
-- ถ้าบนมือถือมีปัญหา ให้เปลี่ยนเป็น false เพื่อกลับไปใช้ปุ่มเดิมทันที
local Xaou_UseProduceItemSlot = true

local function Xaou_NormalizeItemData(data)
    if data == nil then return nil end
    local id = data.id or data.ID or data.Name or data.name
    if id == nil or tostring(id) == "" then return nil end
    return {
        id = tostring(id),
        count = tonumber(data.count or data.Count or data.num or data.Num or 1) or 1,
        cat = tostring(data.cat or data.category or data.Category or "special"),
        pack = tostring(data.pack or data.Pack or data.packName or data.PackName or ""),
        element = tostring(data.element or data.Element or data.ElementKind or "None"),
    }
end

local function Xaou_SafeLen(t)
    if type(t) ~= "table" then return 0 end
    local n = 0
    for _, _ in pairs(t) do n = n + 1 end
    return n
end

local function Xaou_GetPackListFromGlobal(v)
    if type(v) ~= "table" then return nil end
    -- รองรับทั้ง {items={...}} และเป็น list ตรง ๆ
    if type(v.items) == "table" then return v.items, tostring(v.name or v.packName or "Pack") end
    return v, tostring(v.name or "Pack")
end

local function Xaou_BuildDatabaseSignature()
    local parts = {}
    table.insert(parts, "base:" .. tostring(#XaouBaseItemList))
    if type(Xaou_ExtraItemList) == "table" then
        table.insert(parts, "extra:" .. tostring(#Xaou_ExtraItemList))
    end
    if type(Xaou_ItemPacks) == "table" then
        table.insert(parts, "packs:" .. tostring(#Xaou_ItemPacks))
        for i, pack in ipairs(Xaou_ItemPacks) do
            local list = nil
            if type(pack) == "table" then
                list = pack.items or pack
            end
            table.insert(parts, "p" .. tostring(i) .. ":" .. tostring(Xaou_SafeLen(list)))
        end
    end
    
    if _G ~= nil then
        local keys = {}
        for k, v in pairs(_G) do
            if type(k) == "string" and string.sub(k, 1, 14) == "Xaou_ItemPack" and k ~= "Xaou_ItemPacks" then
                table.insert(keys, k .. ":" .. tostring(Xaou_SafeLen(v.items or v)))
            end
        end
        table.sort(keys)
        for _, s in ipairs(keys) do table.insert(parts, s) end
    end
    return table.concat(parts, "|")
end

local function Xaou_RebuildItemDatabase(force)
    local sig = Xaou_BuildDatabaseSignature()
    if not force and XaouItemList ~= nil and sig == XaouDatabaseSignature then
        return XaouItemList
    end

    XaouDatabaseSignature = sig
    XaouItemList = {}
    XaouItemMap = {}
    XaouPackStats = { packs = 0, extra = 0, total = 0, duplicate = 0 }

    local function addOne(data, packName)
        local item = Xaou_NormalizeItemData(data)
        if item == nil then return end
        if packName ~= nil and packName ~= "" and item.pack == "" then item.pack = packName end
        if XaouItemMap[item.id] == nil then
            XaouItemMap[item.id] = item
            table.insert(XaouItemList, item)
            XaouPackStats.total = XaouPackStats.total + 1
        else
            
            XaouItemMap[item.id].count = item.count
            XaouItemMap[item.id].cat = item.cat
            if item.pack ~= "" then XaouItemMap[item.id].pack = item.pack end
            XaouPackStats.duplicate = XaouPackStats.duplicate + 1
        end
    end

    for _, data in ipairs(XaouBaseItemList) do
        addOne(data, "Base")
    end

    if type(Xaou_ExtraItemList) == "table" then
        for _, data in ipairs(Xaou_ExtraItemList) do
            addOne(data, "Extra")
            XaouPackStats.extra = XaouPackStats.extra + 1
        end
    end

    if type(Xaou_ItemPacks) == "table" then
        for _, pack in ipairs(Xaou_ItemPacks) do
            local list, packName = Xaou_GetPackListFromGlobal(pack)
            if type(list) == "table" then
                XaouPackStats.packs = XaouPackStats.packs + 1
                for _, data in ipairs(list) do
                    addOne(data, packName)
                end
            end
        end
    end

  
    if _G ~= nil then
        local keys = {}
        for k, v in pairs(_G) do
            if type(k) == "string" and string.sub(k, 1, 14) == "Xaou_ItemPack" and k ~= "Xaou_ItemPacks" then
                table.insert(keys, k)
            end
        end
        table.sort(keys)
        for _, key in ipairs(keys) do
            local list, packName = Xaou_GetPackListFromGlobal(_G[key])
            if type(list) == "table" then
                XaouPackStats.packs = XaouPackStats.packs + 1
                for _, data in ipairs(list) do
                    addOne(data, packName ~= "Pack" and packName or key)
                end
            end
        end
    end

    return XaouItemList
end

function Xaou_AddSpawnerItem(id, count, cat)
    if Xaou_ExtraItemList == nil then Xaou_ExtraItemList = {} end
    table.insert(Xaou_ExtraItemList, { id = id, count = count or 1, cat = cat or "special" })
    Xaou_RebuildItemDatabase(true)
end

function Xaou_RegisterItemPack(packName, itemList)
    Xaou_ItemPacks = Xaou_ItemPacks or {}
    table.insert(Xaou_ItemPacks, { name = tostring(packName or "Pack"), items = itemList or {} })
    Xaou_RebuildItemDatabase(true)
end

function Xaou_GetItemDatabaseStats()
    Xaou_RebuildItemDatabase(false)
    return XaouPackStats
end


local function Xaou_GetCategoryName(cat)
    cat = tostring(cat or "all")
    if cat == "all" then return "ทั้งหมด" end
    if cat == "อาวุธ" then return "อาวุธ" end
    if cat == "material" then return "วัสดุ" end
    if cat == "magic" then return "อาวุธ/คัมภีร์" end
    if cat == "special" then return "พิเศษ" end
    if cat == "fav" then return "โปรด" end
    if cat == "recent" then return "ล่าสุด" end
    if cat == "vkski" then return "ล่าสุด" end
    
    return cat
end


local XaouFavoriteMap = {}
local XaouRecentList = {}
local XaouRecentMax = 24

local function Xaou_IsFavorite(id)
    return XaouFavoriteMap[tostring(id or "")] == true
end

local function Xaou_ToggleFavorite(id)
    id = tostring(id or "")
    if id == "" then return false end
    XaouFavoriteMap[id] = not XaouFavoriteMap[id]
    return XaouFavoriteMap[id] == true
end

local function Xaou_GetFavText(id)
    if Xaou_IsFavorite(id) then
        return "★"
    end
    return "☆"
end

local function Xaou_AddRecent(data)
    if data == nil or data.id == nil then return end
    local id = tostring(data.id)
    for i = #XaouRecentList, 1, -1 do
        if tostring(XaouRecentList[i].id) == id then
            table.remove(XaouRecentList, i)
        end
    end
    table.insert(XaouRecentList, 1, data)
    while #XaouRecentList > XaouRecentMax do
        table.remove(XaouRecentList)
    end
end

local function Xaou_Show(msg, title)
    if world ~= nil and world.ShowMsgBox ~= nil then
        world:ShowMsgBox(tostring(msg), title or "Xaou")
    else
        print("[Xaou] " .. tostring(msg))
    end
end

local function Xaou_GetItemDef(id)
    local ok, def = pcall(function()
        if ThingMgr ~= nil and g_emThingType ~= nil then
            return ThingMgr:GetDef(g_emThingType.Item, id)
        end
        if ThingMgr ~= nil and CS ~= nil and CS.XiaWorld ~= nil then
            return ThingMgr:GetDef(CS.XiaWorld.g_emThingType.Item, id)
        end
        return nil
    end)
    if ok then return def end
    return nil
end

local function Xaou_DropItem(id, count)
    local ok, err = pcall(function()
        local def = Xaou_GetItemDef(id)
        if def == nil then
            Xaou_Show("ไม่พบไอเทม ID:\n" .. tostring(id), "เสกของล้มเหลว")
            return false
        end

        count = tonumber(count) or 1
        if count <= 0 then count = 1 end

        local maxStack = tonumber(def.MaxStack) or count
        if maxStack <= 0 then maxStack = count end

        local dropkey = nil
        if Map ~= nil and Map.GetRandomInLifeArea ~= nil then
            dropkey = Map:GetRandomInLifeArea(4)
        end

        if dropkey == nil then
            Xaou_Show("หาตำแหน่งวางของไม่เจอ", "เสกของล้มเหลว")
            return false
        end

        local remain = count
        while remain > 0 do
            local oneCount = remain
            if oneCount > maxStack then oneCount = maxStack end

            local thing = ItemRandomMachine.RandomItem(id, nil, 1, 12, 1, oneCount)
            Map:DropItem(thing, dropkey, true, true, false, true, 0, false)
            remain = remain - oneCount
        end

        Xaou_Show((def.ThingName or id) .. "\nเสกสำเร็จ จำนวน " .. tostring(count), "เสกของสำเร็จ")
        return true
    end)

    if not ok then
        Xaou_Show("ERROR ตอนเสกของ:\n" .. tostring(err), "Xaou Error")
        return false
    end
    return true
end


local function Xaou_CleanLabelObject(obj)
    if obj == nil then return end

    
    pcall(function()
        local n = tonumber(obj.numChildren) or 0
        for i = 0, n - 1 do
            local child = obj:GetChildAt(i)
            if child ~= nil and child ~= obj.m_title then
                child.visible = false
            end
        end
    end)

  
    pcall(function() if obj.m_button ~= nil then obj.m_button.visible = false end end)
    pcall(function() if obj.m_icon ~= nil then obj.m_icon.visible = false end end)
    pcall(function() if obj.m_check ~= nil then obj.m_check.visible = false end end)
    pcall(function() if obj.m_checkmark ~= nil then obj.m_checkmark.visible = false end end)
end

function XaouItemWindow:AddLabel(name, text, x, y, w, h)
    local obj = self:AddObjectFromUrl("ui://0xrxw6g7hdhl1b", x, y)
    obj.name = name
    obj.m_title.text = tostring(text)
    obj:SetSize(w or 200, h or 28, false)
    Xaou_CleanLabelObject(obj)
    return obj
end

function XaouItemWindow:AddButton(name, text, x, y, w, h, icon)
    local obj = self:AddObjectFromUrl("ui://0xrxw6g7hdhl18", x, y)
    obj.name = name
    obj.m_title.text = tostring(text)
    pcall(function()
        obj.m_title.textFormat.size = 24
        obj.m_title:ApplyFormat()
    end)
    pcall(function()
        obj.m_title.textFormat.color = Color.yellow
        obj.m_title:ApplyFormat()
    end)
    obj:SetSize(w or 100, h or 34, false)
    if icon ~= nil and icon ~= "" then
        pcall(function()
            if obj.m_icon ~= nil then
                obj.m_icon.icon = icon
            if name == "btnModeItem"
            or name == "btnModeBook"
            or name == "btnModeBuilding"
            or name == "btnModeNpc"
            or name == "btnModeDev"
            or name == "btnClose" then

                pcall(function()
                    obj.m_icon.x = 30
                    obj.m_icon.y = 5

                    obj.m_title.x = 0
                    obj.m_title.y = 30
                end)

            end
            end
        end)
    end
    return obj
end

function XaouItemWindow:AddItemSlot(name, title, icon, count, x, y, w, h, data)
    -- ช่องไอเทมแบบเกมแท้: UI_Bnt_ProduceItem
    local ok, obj = pcall(function()
        return self:AddObjectFromUrl("ui://0xrxw6g7hdhl1q", x, y)
    end)

    if not ok or obj == nil then
        -- fallback กลับปุ่มเดิม ถ้า component ใช้ไม่ได้ในบางเครื่อง
        return self:AddButton(name, tostring(title or ""), x, y, w or 100, h or 80, icon)
    end

    obj.name = name
    pcall(function() obj:SetSize(w or 96, h or 96, false) end)

    pcall(function()
        local c = obj:GetChild("title")
        if c ~= nil then
            c.text = tostring(title or "")
        elseif obj.m_title ~= nil then
            obj.m_title.text = tostring(title or "")
        end
    end)

    pcall(function()
        local c = obj:GetChild("count")
        if c ~= nil then c.text = "x" .. tostring(count or 1) end
    end)

    pcall(function()
        local c = obj:GetChild("icon")
        if c ~= nil and icon ~= nil and icon ~= "" then
            c.icon = tostring(icon)
            c:SetSize((w or 96) - 28, (h or 96) - 44, false)
            c.x = 14
            c.y = 8
        end
    end)

    -- ซ่อนส่วนที่เป็นระบบผลิตของ ไม่ใช้ในหน้าเสกไอเทม
    pcall(function() local c=obj:GetChild("Stuff"); if c~=nil then c.visible=false end end)
    pcall(function() local c=obj:GetChild("Up"); if c~=nil then c.visible=false end end)
    pcall(function() local c=obj:GetChild("Loop"); if c~=nil then c.visible=false end end)
    pcall(function() local c=obj:GetChild("loading"); if c~=nil then c.visible=false end end)
    pcall(function() local c=obj:GetChild("n16"); if c~=nil then c.visible=false end end)
    pcall(function() local c=obj:GetChild("n15"); if c~=nil then c.visible=false end end)
    pcall(function() local c=obj:GetChild("n17"); if c~=nil then c.visible=false end end)
    pcall(function() local c=obj:GetChild("n18"); if c~=nil then c.visible=false end end)

    pcall(function()
        local e = obj:GetChild("Element")
        if e ~= nil then
            e.visible = true
            e.x = 3
            e.y = 3
        end
    end)

    return obj
end

function XaouItemWindow:AddInput(name, text, x, y, w, h)
    local obj = self:AddObjectFromUrl("ui://0xrxw6g7hdhl1c", x, y)
    obj.name = name
    obj.m_title.text = tostring(text or "")
    obj:SetSize(w or 200, h or 28, false)
    return obj
end

local function Xaou_GetInputText(inputObj)
    if inputObj == nil then return "" end
    local ok, val = pcall(function() return inputObj.m_title.text end)
    if ok and val ~= nil then return tostring(val) end
    ok, val = pcall(function() return inputObj.text end)
    if ok and val ~= nil then return tostring(val) end
    return ""
end

local function Xaou_MatchItem(data, keyword)
    if keyword == nil or keyword == "" then return true end
    keyword = string.lower(tostring(keyword))
    local id = tostring(data.id or "")
    if string.find(string.lower(id), keyword, 1, true) then return true end
    local def = Xaou_GetItemDef(data.id)
    if def ~= nil then
        local name = tostring(def.ThingName or "")
        if string.find(string.lower(name), keyword, 1, true) then return true end
    end
    return false
end

function XaouItemWindow:GetCurrentList()
    local result = {}
    local category = self.category or "all"
    local keyword = self.searchKeyword or ""

    if category == "recent" then
        for _, data in ipairs(XaouRecentList) do
            if Xaou_MatchItem(data, keyword) then
                table.insert(result, data)
            end
        end
        return result
    end

    for _, data in ipairs(Xaou_RebuildItemDatabase(false)) do
        local okCat = false
        if category == "all" then
            okCat = true
        elseif category == "fav" then
            okCat = Xaou_IsFavorite(data.id)
        else
            okCat = (data.cat == category)
        end

        local okSearch = Xaou_MatchItem(data, keyword)
        if okCat and okSearch then
            table.insert(result, data)
        end
    end

    return result
end

function XaouItemWindow:GetPageSize()
    if self.viewMode == "grid" then
        return 12
    end
    return self.pageSize or 8
end

function XaouItemWindow:GetMaxPage()
    local total = #self:GetCurrentList()
    local maxPage = math.ceil(total / self:GetPageSize())
    if maxPage < 1 then maxPage = 1 end
    return maxPage
end

function XaouItemWindow:FixPage()
    local maxPage = self:GetMaxPage()
    if self.page == nil then self.page = 1 end
    if self.page < 1 then self.page = 1 end
    if self.page > maxPage then self.page = maxPage end
end

function XaouItemWindow:ClearItemButtons()
    if self.itemButtons == nil then return end
    for _, btn in ipairs(self.itemButtons) do
        pcall(function()
            btn.visible = false
            btn:SetSize(0, 0, false)
        end)
    end
    self.itemButtons = {}
end

function XaouItemWindow:UpdateStatus(currentCount)
    local ok = pcall(function()
        local stats = Xaou_GetItemDatabaseStats()
        local dbTotal = #Xaou_RebuildItemDatabase(false)
        local shown = tonumber(currentCount)
        if shown == nil then shown = #self:GetCurrentList() end
        local catName = Xaou_GetCategoryName(self.category)
        local keyword = tostring(self.searchKeyword or "")
        local packCount = tonumber(stats.packs or 0) or 0
        local extraCount = tonumber(stats.extra or 0) or 0
        local dupCount = tonumber(stats.duplicate or 0) or 0

        if self.statusLine1 ~= nil then
            self.statusLine1.m_title.text = "ไอเทม : " .. tostring(dbTotal) .. " | ค้นพบ : " .. tostring(shown) .. " | หมวด : " .. tostring(catName)
        end
        if self.statusLine2 ~= nil then
            local text = "แพ็ก : " .. tostring(packCount) .. " | เพิ่ม : +" .. tostring(extraCount) .. " | ซ้ำ : " .. tostring(dupCount)
            if keyword ~= "" then
                text = text .. " | คำค้น : " .. keyword
            end
            self.statusLine2.m_title.text = text
        end
    end)
    if not ok then
        
    end
end

function XaouItemWindow:RefreshPageText()
    self:FixPage()
    local maxPage = self:GetMaxPage()
    local total = #self:GetCurrentList()
    local dbTotal = #Xaou_RebuildItemDatabase(false)
    if self.pageText ~= nil then
        self.pageText.m_title.text = "หน้า " .. tostring(self.page) .. " / " .. tostring(maxPage) .. " (" .. tostring(total) .. "/" .. tostring(dbTotal) .. ")"
    end
end

function XaouItemWindow:ShortName(name)
    name = tostring(name or "")
    
    if self.viewMode == "grid" and string.len(name) > 28 then
        return string.sub(name, 1, 28) .. "..."
    end
    return name
end


function XaouItemWindow:GetModeName(mode)
    mode = tostring(mode or "item")
    if mode == "item" then return "ไอเทม" end
    if mode == "book" then return "คัมภีร์" end
    if mode == "building" then return "อาคาร" end
    if mode == "npc" then return "NPC" end
    if mode == "developer" then return "ผู้พัฒนา" end
    return mode
end

function XaouItemWindow:SetTopCategoryVisible(show)
    -- ซ่อน/แสดงปุ่มหมวดด้านบน ใช้เฉพาะหน้าไอเทม
    if self.categoryButtons ~= nil then
        for _, btn in ipairs(self.categoryButtons) do
            pcall(function()
                if btn ~= nil then btn.visible = show end
            end)
        end
    end
end

function XaouItemWindow:SetMainMode(mode)
    self.mainMode = tostring(mode or "item")
    self.page = 1

    -- หน้าอื่นไม่ต้องมีปุ่มหมวดด้านบน ให้เหลือช่องค้นหา + รายละเอียด
    if self.mainMode == "item" then
        self:SetTopCategoryVisible(true)
    else
        self:SetTopCategoryVisible(false)
    end

    self:RefreshList()
end

function XaouItemWindow:ShowModePlaceholder()
    self:ClearItemButtons()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}

    local modeName = self:GetModeName(self.mainMode)

    if self.statusLine1 ~= nil then
        self.statusLine1.m_title.text = "โหมด : " .. tostring(modeName) .. " | กำลังเตรียมระบบ"
    end
    if self.statusLine2 ~= nil then
        self.statusLine2.m_title.text = "หน้านี้เป็นพื้นที่สำหรับฟังก์ชันใหม่"
    end

    local msg = "หน้า " .. tostring(modeName) .. "\nกำลังเตรียมระบบ"
    local btn = self:AddButton("btnModeEmpty", msg, 110, 235, 430, 90, nil)
    btn.tooltips = "กลับไปหน้าไอเทมได้จากปุ่มด้านล่าง"
    table.insert(self.itemButtons, btn)

    if self.pageText ~= nil then
        self.pageText.m_title.text = "หน้า " .. tostring(modeName)
    end
end


function XaouItemWindow:RefreshList()
    self:FixPage()
    self:ClearItemButtons()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}

    if self.mainMode ~= nil and self.mainMode ~= "item" then
        self:ShowModePlaceholder()
        return
    end

    local list = self:GetCurrentList()
    self:UpdateStatus(#list)
    local pageSize = self:GetPageSize()
    local startIndex = (self.page - 1) * pageSize + 1
    local endIndex = startIndex + pageSize - 1
    local row = 0

    -- อัปเดตชื่อปุ่มสลับโหมด
    if self.btnViewMode ~= nil then
        if self.viewMode == "grid" then
            self.btnViewMode.m_title.text = "📋 รายการ"
        else
            self.btnViewMode.m_title.text = "▦ ตาราง"
        end
    end

    if self.viewMode == "grid" then
        
        local startX = 180
        local startY = 185
        local cellW = 150
        local cellH = 120
        local gapX = 12
        local gapY = 6
        local cols = 4

        for i = startIndex, endIndex do
            local data = list[i]
            if data ~= nil then
                local idx = i - startIndex
                local col = idx % cols
                local r = math.floor(idx / cols)
                local def = Xaou_GetItemDef(data.id)
                local name = data.id
                local icon = ""
                if def ~= nil then
                    name = def.ThingName or data.id
                    icon = def.TexPath or ""
                end
                name = self:ShortName(name)
                local favMark = Xaou_IsFavorite(data.id) and "⭐ " or ""
                local text = favMark .. tostring(name)
                local btnName = "btnItem" .. tostring(i)
                local btn = nil
                if Xaou_UseProduceItemSlot == true then
                    btn = self:AddItemSlot(btnName, text, icon, data.count or 1,
                        startX + col * (cellW + gapX),
                        startY + r * (cellH + gapY),
                        cellW, cellH, data)
                else
                    btn = self:AddButton(btnName, text,
                        startX + col * (cellW + gapX),
                        startY + r * (cellH + gapY),
                        cellW, cellH, icon)
                end
                btn.tooltips = "ID: " .. tostring(data.id) .. "\nแตะเพื่อเลือกจำนวน"
                self.buttonData[btnName] = data
                table.insert(self.itemButtons, btn)

                
                local favName = "btnFavQuick" .. tostring(i)
                local favBtn = self:AddButton(favName, Xaou_GetFavText(data.id),
                    startX + col * (cellW + gapX) + cellW - 32,
                    startY + r * (cellH + gapY) + 3,
                    30, 24, nil)
                favBtn.tooltips = "เพิ่ม/เอาออกจากรายการโปรด\nID: " .. tostring(data.id)
                self.favButtonData[favName] = data
                table.insert(self.itemButtons, favBtn)

                row = row + 1
            end
        end
    else
        
        local startX = 200   -- แก้ตรางไอเทม
        local startY = 185
        local rowW = 520
        local rowH = 32
        local gap = 5

        for i = startIndex, endIndex do
            local data = list[i]
            if data ~= nil then
                row = row + 1
                local def = Xaou_GetItemDef(data.id)
                local name = data.id
                local icon = ""
                if def ~= nil then
                    name = def.ThingName or data.id
                    icon = def.TexPath or ""
                end

                local favMark = Xaou_IsFavorite(data.id) and "⭐ " or ""
                local text = favMark .. tostring(i) .. ". " .. tostring(name) .. "  x" .. tostring(data.count or 1)
                local btnName = "btnItem" .. tostring(i)
                local y = startY + (row - 1) * (rowH + gap)
                local btn = self:AddButton(btnName, text, startX, y, rowW - 42, rowH, icon)
                btn.tooltips = "ID: " .. tostring(data.id) .. "\nแตะเพื่อเลือกจำนวน"
                self.buttonData[btnName] = data
                table.insert(self.itemButtons, btn)

                
                local favName = "btnFavQuick" .. tostring(i)
                local favBtn = self:AddButton(favName, Xaou_GetFavText(data.id), startX + rowW - 38, y, 38, rowH, nil)
                favBtn.tooltips = "เพิ่ม/เอาออกจากรายการโปรด\nID: " .. tostring(data.id)
                self.favButtonData[favName] = data
                table.insert(self.itemButtons, favBtn)
            end
        end
    end

    if row == 0 then
        local btn = self:AddButton("btnEmpty", "ไม่พบรายการที่ค้นหา", 65, 185, 520, 34, nil)
        table.insert(self.itemButtons, btn)
    end

    self:RefreshPageText()
end

function XaouItemWindow:ApplySearch()
    local keyword = Xaou_GetInputText(self.inputSearch)
    if keyword == "" or keyword == "ค้นหา ID/ชื่อ" then
        self.searchKeyword = ""
    else
        self.searchKeyword = tostring(keyword)
    end
    self._lastAppliedKeyword = self.searchKeyword
    self.page = 1
    self:RefreshList()
end

function XaouItemWindow:CheckLiveSearch(force)
    
    if self.inputSearch == nil then return end

    local nowText = Xaou_GetInputText(self.inputSearch)
    if nowText == nil then nowText = "" end
    nowText = tostring(nowText)

    if nowText == "ค้นหา ID/ชื่อ" then
        nowText = ""
    end

    -- ครั้งแรกให้จำค่าไว้ก่อน ไม่รีเฟรชซ้ำถ้าไม่จำเป็น
    if self._lastInputText == nil then
        self._lastInputText = nowText
        if force == true and tostring(nowText) ~= tostring(self.searchKeyword or "") then
            self.searchKeyword = nowText
            self._lastAppliedKeyword = nowText
            self.page = 1
            self:RefreshList()
        end
        return
    end

    
    if force == true or nowText ~= self._lastInputText then
        self._lastInputText = nowText
        if tostring(nowText) ~= tostring(self._lastAppliedKeyword or "") then
            self.searchKeyword = nowText
            self._lastAppliedKeyword = nowText
            self.page = 1
            self:RefreshList()
        end
    end
end

function XaouItemWindow:ClearSearch()
    self.searchKeyword = ""
    if self.inputSearch ~= nil then
        self.inputSearch.m_title.text = ""
    end
    self._lastInputText = ""
    self._lastAppliedKeyword = ""
    self.page = 1
    self:RefreshList()
end

function XaouItemWindow:SetCategory(cat)
    self.category = cat or "all"
    self.page = 1
    self:RefreshList()
end

function XaouItemWindow:ToggleViewMode()
    if self.viewMode == "grid" then
        self.viewMode = "list"
    else
        self.viewMode = "grid"
    end
    self.page = 1
    self:RefreshList()
end

function XaouItemWindow:NextPage()
    self.page = (self.page or 1) + 1
    self:FixPage()
    self:RefreshList()
end

function XaouItemWindow:PrevPage()
    self.page = (self.page or 1) - 1
    self:FixPage()
    self:RefreshList()
end



function XaouAmountWindow:AddLabel(name, text, x, y, w, h)
    local obj = self:AddObjectFromUrl("ui://0xrxw6g7hdhl1b", x, y)
    obj.name = name
    obj.m_title.text = tostring(text)
    obj:SetSize(w or 200, h or 28, false)
    Xaou_CleanLabelObject(obj)
    return obj
end

function XaouAmountWindow:AddButton(name, text, x, y, w, h)
    local obj = self:AddObjectFromUrl("ui://0xrxw6g7hdhl18", x, y)
    obj.name = name
    obj.m_title.text = tostring(text)
    obj:SetSize(w or 100, h or 34, false)
    return obj
end


function XaouAmountWindow:CenterOnMain()
    local ok = pcall(function()
        local mainX = 0
        local mainY = 0
        local mainW = 660
        local mainH = 650

        if XaouItemWindow ~= nil then
            mainW = tonumber(XaouItemWindow.sx) or mainW
            mainH = tonumber(XaouItemWindow.sy) or mainH
            if XaouItemWindow.window ~= nil then
                mainX = tonumber(XaouItemWindow.window.x) or mainX
                mainY = tonumber(XaouItemWindow.window.y) or mainY
            end
        end

        local popupW = tonumber(self.sx) or 430
        local popupH = tonumber(self.sy) or 330
        local px = mainX + math.floor((mainW - popupW) / 2)
        local py = mainY + math.floor((mainH - popupH) / 2)

        if px < 0 then px = 0 end
        if py < 0 then py = 0 end

        if self.window ~= nil and self.window.SetXY ~= nil then
            self.window:SetXY(px, py)
        elseif self.window ~= nil then
            self.window.x = px
            self.window.y = py
        end

        
        if self.window ~= nil and self.window.BringToFront ~= nil then
            self.window:BringToFront()
        end
    end)

    if not ok then
        pcall(function() self:Center() end)
    end
end

function XaouAmountWindow:OnInit()
    self:SetTitle("เลือกจำนวน")
    self.sx = 430
    self.sy = 330
    self:SetSize(self.sx, self.sy)
    self.currentData = nil

    self.nameLabel = self:AddLabel("txtItemName", "ชื่อไอเทม", 35, 48, 350, 28)
    self.idLabel = self:AddLabel("txtItemID", "ID", 35, 78, 350, 28)
    self:AddLabel("txtTip", "เลือกจำนวนที่จะเสก", 35, 112, 350, 28)

    self:AddButton("btnX1", "x1", 45, 155, 90, 40)
    self:AddButton("btnX10", "x10", 165, 155, 90, 40)
    self:AddButton("btnX100", "x100", 285, 155, 90, 40)
    self:AddButton("btnX500", "x500", 95, 210, 100, 40)
    self:AddButton("btnX9999", "x9999", 235, 210, 110, 40)
    self.favButton = self:AddButton("btnFav", "☆ เพิ่มโปรด", 60, 260, 130, 34)
    self:AddButton("btnCancel", "ยกเลิก", 235, 260, 110, 34)

    self:CenterOnMain()
end

function XaouAmountWindow:SetItemData(data)
    self.currentData = data
    local def = nil
    if data ~= nil then def = Xaou_GetItemDef(data.id) end
    local name = data and data.id or ""
    if def ~= nil then name = def.ThingName or name end

    if self.nameLabel ~= nil then self.nameLabel.m_title.text = tostring(name) end
    if self.idLabel ~= nil then self.idLabel.m_title.text = "ID: " .. tostring(data and data.id or "") end
    if self.favButton ~= nil then
        if data ~= nil and Xaou_IsFavorite(data.id) then
            self.favButton.m_title.text = "⭐ เอาออกโปรด"
        else
            self.favButton.m_title.text = "☆ เพิ่มโปรด"
        end
    end
end

function XaouAmountWindow:SpawnAmount(amount)
    if self.currentData == nil then
        Xaou_Show("ไม่มีข้อมูลไอเทม", "Xaou")
        return
    end
    local ok = Xaou_DropItem(self.currentData.id, amount or 1)
    if ok ~= false then
        Xaou_AddRecent(self.currentData)
        if XaouItemWindow ~= nil then
            pcall(function() XaouItemWindow:RefreshList() end)
        end
    end
    self:Hide()
end

function XaouAmountWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" then
        if obj.name == "btnCancel" then
            self:Hide()
            return true
        elseif obj.name == "btnFav" then
            if self.currentData ~= nil then
                local added = Xaou_ToggleFavorite(self.currentData.id)
                if self.favButton ~= nil then
                    self.favButton.m_title.text = added and "☆ เอาออกโปรด" or "☆ เพิ่มโปรด"
                end
                if XaouItemWindow ~= nil then
                    pcall(function() XaouItemWindow:RefreshList() end)
                end
                Xaou_Show((added and "เพิ่มรายการโปรดแล้ว" or "เอาออกจากรายการโปรดแล้ว") .. "\n" .. tostring(self.currentData.id), "Xaou Favorite")
            end
            return true
        elseif obj.name == "btnX1" then
            self:SpawnAmount(1)
            return true
        elseif obj.name == "btnX10" then
            self:SpawnAmount(10)
            return true
        elseif obj.name == "btnX100" then
            self:SpawnAmount(100)
            return true
        elseif obj.name == "btnX500" then
            self:SpawnAmount(500)
            return true
        elseif obj.name == "btnX9999" then
            self:SpawnAmount(9999)
            return true
        end
    end
    return true
end

function XaouAmountWindow:OnShown()
    self:CenterOnMain()
end

function XaouAmountWindow:OnHide()
    if XaouItemWindow ~= nil then
        XaouItemWindow.amountOpen = false
    end
end

function Xaou_ShowAmountWindow(data)
    if XaouAmountWindow == nil then
        Xaou_Show("ไม่พบหน้าต่างเลือกจำนวน", "Xaou Error")
        return
    end
    if XaouItemWindow ~= nil then
        XaouItemWindow.amountOpen = true
    end
    XaouAmountWindow:SetItemData(data)
    XaouAmountWindow:Show()
    pcall(function() XaouAmountWindow:CenterOnMain() end)
end




function XaouItemWindow:ForceMainPosition()
    local ok = pcall(function()
        local rootW = 0
        local rootH = 0
        if CS ~= nil and CS.FairyGUI ~= nil and CS.FairyGUI.GRoot ~= nil and CS.FairyGUI.GRoot.inst ~= nil then
            rootW = tonumber(CS.FairyGUI.GRoot.inst.width) or 0
            rootH = tonumber(CS.FairyGUI.GRoot.inst.height) or 0
        end

        local w = tonumber(self.sx) or 660
        local h = tonumber(self.sy) or 650

        
        if rootW <= 0 then rootW = 1536 end
        if rootH <= 0 then rootH = 700 end

        local x = math.floor((rootW - w) / 2)
        local y = math.floor((rootH - h) / 2)

        
        if x < 0 then x = 0 end
        if y < 0 then y = 0 end

        
        if self.window ~= nil and self.window.SetXY ~= nil then
            self.window:SetXY(x, y)
        end
        if self.window ~= nil then
            self.window.x = x
            self.window.y = y
        end
        if self.SetXY ~= nil then
            self:SetXY(x, y)
        end
    end)

    if not ok then
        pcall(function() self:Center() end)
    end
end

function XaouItemWindow:OnInit()   -- แก้ขนาดกรอบ
    self.sx = 980
    self.sy = 620
    self.page = 1
    self.pageSize = 8
    self.category = "all"
    self.viewMode = "list"
    self.mainMode = "item"
    self.searchKeyword = ""
    self.buttonData = {}

    self:SetTitle("เมนูเสกของ")
    self:SetSize(self.sx, self.sy)
    
    self:AddLabel("txtTitle", "ผู้พัฒนา : Xaou009 & บัสเตอร์ฟายทำนู๋เสียใจ", 20, 36, 560, 26)
    self.statusLine1 = self:AddLabel("txtStatus1", "ไอเทม : 0 | ค้นพบ : 0 | หมวด : ทั้งหมด", 45, 62, 560, 22)
    self.statusLine2 = self:AddLabel("txtStatus2", "แพ็ก : 0 | เพิ่ม : +0 | ซ้ำ : 0", 45, 84, 560, 22)

    self:AddLabel("txtSearchLabel", "ค้นหา", 150, 110, 55, 26)
    self.inputSearch = self:AddInput("inputSearch", "", 230, 108, 100, 30)
    -- self:AddButton("btnSearch", "ค้นหา", 510, 106, 85, 32)
    self:AddButton("btnAll", "ทั้งหมด", 600, 106, 85, 32)

    -- ปุ่มหมวดด้านบน: เก็บไว้ในตารางเพื่อซ่อนตอนเปลี่ยนไปหน้าอื่น
    self.categoryButtons = {}
    table.insert(self.categoryButtons, self:AddButton("btnCatAll", "ทั้งหมด", 190, 140, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatvkski", "อาหาร", -60, 140, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatอาวุธ", "อาวุธ", -60, 190, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatโอสถ", "โอสถ", -60, 230, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatยารักษา", "ยารักษา", -60, 270, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatยันต์", "ยันต์", -60, 310, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatวัตถุดิบ", "วัตถุดิบ", -60, 350, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatอื่น", "อื่นๆ", -60, 390, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatFav", "★ โปรด", -60, 430, 130, 40))
    table.insert(self.categoryButtons, self:AddButton("btnCatRecent", "ล่าสุด", -60, 470, 130, 40))

    self:AddLabel("listBg", "", 45, 175, 575, 330)

    self.btnPrev = self:AddButton("btnPrev", "◀ ก่อนหน้า", 830, 450, 120, 34)
    self.pageText = self:AddLabel("txtPage", "หน้า 1 / 1", 830, 400, 150, 28)
    self.btnNext = self:AddButton("btnNext", "ถัดไป ▶", 830, 520, 120, 34)

    self.btnRefresh = self:AddButton("btnRefresh", "รีเฟรช", 350, 565, 100, 34)
    self.btnViewMode = self:AddButton("btnViewMode", "▦ ตาราง", 450, 565, 100, 34)
    local btn = self:AddButton("btnClose", "ปิด", 1000, 500, 140, 100)
    pcall(function()
        btn:GetChild("icon").icon = "Sprs/xaou104.png"
    end)
    
    for i = 0, 20 do
        pcall(function()
            local c = btn:GetChildAt(i)
            if c ~= nil and c.name ~= "icon" then
                c.visible = false
            end
        end)
    end
    
    pcall(function()
        btn:GetChild("icon").visible = true
    end)

    -- แท็บด้านล่าง 4 หน้า
    self.btnModeItem = self:AddButton("btnModeItem", "ไอเทม", 1000, 50, 140, 100, "Sprs/xaou105.png")
    
    self.btnModeBook = self:AddButton("btnModeBook", "คัมภีร์", 1000, 150, 140, 100, "Sprs/xaou106.png")
    -- self.btnModeBuilding = self:AddButton("btnModeBuilding", "อาคาร", 1000, 250, 140, 100)
    self.btnModeNpc = self:AddButton("btnModeNpc", "NPC", 1000, 250, 140, 100, "Sprs/xaou107.png")
    
    -- local btn = self:AddButton("btnModeDev", "ผู้พัฒนา", 1000, 450, 140, 100)
    -- pcall(function()
       -- btn:GetChild("icon").icon = "Sprs/xaou106.png"
    -- end)
    
    -- for i = 0, 20 do
       -- pcall(function()
         --   local c = btn:GetChildAt(i)
           -- if c ~= nil and c.name ~= "icon" then
             --   c.visible = false
            --end
        --end)
    --end
    
    -- pcall(function()
       -- btn:GetChild("icon").visible = true
    -- end)
    self.itemButtons = {}
    self:Center()
    self:ForceMainPosition()
end

function XaouItemWindow:OnObjectEvent(t, obj, context)
    
    if obj ~= nil and obj.name == "inputSearch" and t ~= "onClick" then
        pcall(function() self:CheckLiveSearch(true) end)
        return true
    end

    if t == "onClick" then
        if obj.name == "btnModeItem" then
            self:SetMainMode("item")
            return true
        elseif obj.name == "btnModeBook" then
            self:SetMainMode("book")
            return true
        elseif obj.name == "btnModeBuilding" then
            self:SetMainMode("building")
            return true
        elseif obj.name == "btnModeNpc" then
            self:SetMainMode("npc")
            return true
        elseif obj.name == "btnClose" then
            self:Hide()
            return true
        elseif obj.name == "btnRefresh" then
            self:RefreshList()
            return true
        elseif obj.name == "btnViewMode" then
            self:ToggleViewMode()
            return true
        elseif obj.name == "btnNext" then
            self:NextPage()
            return true
        elseif obj.name == "btnSearch" then
            self:ApplySearch()
            return true
        elseif obj.name == "btnAll" then
            self:ClearSearch()
            return true
        elseif obj.name == "btnPrev" then
            self:PrevPage()
            return true
        elseif obj.name == "btnCatAll" then
            self:SetCategory("all")
            return true
        elseif obj.name == "btnCatอื่น" then
            self:SetCategory("อื่น")
            return true
        elseif obj.name == "btnCatวัตถุดิบ" then
            self:SetCategory("วัตถุดิบ")
            return true
        elseif obj.name == "btnCatยันต์" then
            self:SetCategory("ยันต์")
            return true
        elseif obj.name == "btnCatโอสถ" then
            self:SetCategory("โอสถ")
            return true
        elseif obj.name == "btnCatยารักษา" then
            self:SetCategory("ยารักษา")
            return true
        elseif obj.name == "btnCatvkski" then
            self:SetCategory("vkski")
            return true
        elseif obj.name == "btnCatอาวุธ" then
            self:SetCategory("อาวุธ")
            return true
        elseif obj.name == "btnCat" then
            self:SetCategory("Fav")
            return true
        elseif obj.name == "btnCat" then
            self:SetCategory("Recent")
            return true
                elseif obj.name == "btnCatAll" then
            self:SetCategory("all")
            return true
        elseif obj.name == "btnCatMat" then
            self:SetCategory("material")
            return true
        elseif obj.name == "btnCatMagic" then
            self:SetCategory("magic")
            return true
        elseif obj.name == "btnCatSpecial" then
            self:SetCategory("special")
            return true
        elseif obj.name == "btnCatFav" then
            self:SetCategory("fav")
            return true
        elseif obj.name == "btnCatRecent" then
            self:SetCategory("recent")
            return true

            
        end

        local favData = nil
        if self.favButtonData ~= nil then
            favData = self.favButtonData[tostring(obj.name)]
        end
        if favData ~= nil then
            local added = Xaou_ToggleFavorite(favData.id)
            Xaou_Show((added and "เพิ่มรายการโปรดแล้ว" or "เอาออกจากรายการโปรดแล้ว") .. "\n" .. tostring(favData.id), "Xaou Favorite")
            self:RefreshList()
            return true
        end

        local data = nil
        if self.buttonData ~= nil then
            data = self.buttonData[tostring(obj.name)]
        end
        if data ~= nil then
            Xaou_ShowAmountWindow(data)
            return true
        end
    end
    return true
end

function XaouItemWindow:OnShown()
    self.amountOpen = false
    if (self.mainMode or "item") == "npc" then
        self.sx = 980; self.sy = 620; pcall(function() self:SetSize(self.sx, self.sy) end)
    end
    
    self._xaouFixTicks = 12
    self._xaouRefreshTicks = 8
    pcall(function() self:ForceMainPosition() end)
    pcall(function() Xaou_RebuildItemDatabase(true) end)
    pcall(function() self:SetTopCategoryVisible((self.mainMode or "item") == "item") end)
    self._lastInputText = nil
    self._lastAppliedKeyword = self.searchKeyword or ""
    pcall(function() self:RefreshList() end)
end

function XaouItemWindow:OnShowUpdate()
    
    if self._xaouFixTicks ~= nil and self._xaouFixTicks > 0 then
        self._xaouFixTicks = self._xaouFixTicks - 1
        pcall(function() self:ForceMainPosition() end)
    end
    if self._xaouRefreshTicks ~= nil and self._xaouRefreshTicks > 0 then
        self._xaouRefreshTicks = self._xaouRefreshTicks - 1
        pcall(function() self:RefreshList() end)
    end

    -- V10.3: ค้นหาแบบ Live Search ทันทีเมื่อข้อความเปลี่ยน
    pcall(function() self:CheckLiveSearch(false) end)
end

function XaouItemWindow:OnHide()
end

function Xaou_OpenIconItemSpawner()
    if XaouItemWindow ~= nil then
        XaouItemWindow.amountOpen = false
        XaouItemWindow:Show()

        
        XaouItemWindow._xaouFixTicks = 12
        XaouItemWindow._xaouRefreshTicks = 8
        XaouItemWindow._lastInputText = nil
        XaouItemWindow._lastAppliedKeyword = XaouItemWindow.searchKeyword or ""
        pcall(function() XaouItemWindow:ForceMainPosition() end)
        pcall(function() Xaou_RebuildItemDatabase(true) end)
        pcall(function() XaouItemWindow:SetTopCategoryVisible((XaouItemWindow.mainMode or "item") == "item") end)
        pcall(function() XaouItemWindow:RefreshList() end)
    else
        Xaou_Show("ไม่พบหน้าต่าง XaouItemWindow", "Xaou Error")
    end
end

function Xaou_OpenWndSimpleSpawner()
    Xaou_OpenIconItemSpawner()
end
local Xaou_LiveSearch_Mod = nil
pcall(function()
    if GameMain ~= nil and GameMain.NewMod ~= nil then
        Xaou_LiveSearch_Mod = GameMain:NewMod("Xaou_ItemSpawner_LiveSearch_Fix")

        function Xaou_LiveSearch_Mod:OnEnter()
            self._xaouSearchTimer = 0
        end

        function Xaou_LiveSearch_Mod:OnStep(nDeltaTime)
            self._xaouSearchTimer = (self._xaouSearchTimer or 0) + (tonumber(nDeltaTime) or 0)
            if self._xaouSearchTimer < 0.15 then
                return
            end
            self._xaouSearchTimer = 0

            if XaouItemWindow == nil or XaouItemWindow.inputSearch == nil then
                return
            end

            local visible = true
            pcall(function()
                if XaouItemWindow.window ~= nil and XaouItemWindow.window.visible ~= nil then
                    visible = XaouItemWindow.window.visible
                end
            end)

            if visible then
                pcall(function()
                    XaouItemWindow:CheckLiveSearch(false)
                end)
            end
        end
    end
end)




-- NPC system moved to separate files: 02-05_Xaou_Npc*.lua

local function Xaou_GetDeveloperCommands()
    return {
        { text="1. GitHub ผู้พัฒนา", actions={{kind="url", url="https://github.com/xaouxaou009-debug/Mod"}} },
        { text="2. Release ล่าสุด", actions={{kind="url", url="https://github.com/xaouxaou009-debug/Mod/releases"}} },
        { text="3. แจ้งปัญหา", actions={{kind="url", url="https://github.com/xaouxaou009-debug/Mod/issues"}} },
        { text="4. ข้อมูลม็อด", actions={{kind="message", title="XAOU", text="ผู้พัฒนา: xaouxaou009\nระบบ: XAOU Mod Center\nหน้า: ผู้พัฒนา"}} },
        { text="5. กลับหน้า NPC", page="npc" },
    }
end

function XaouItemWindow:RefreshDeveloperPage()
    self:ClearItemButtons()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}
    self.devButtonData = {}

    if self.statusLine1 ~= nil then
        self.statusLine1.m_title.text = "โหมด : ผู้พัฒนา | ลิงก์และข้อมูลม็อด"
    end
    if self.statusLine2 ~= nil then
        self.statusLine2.m_title.text = "กดที่รายการเพื่อเปิด GitHub / Releases / Issues"
    end

    local startX = 65
    local startY = 185
    local rowH = 34
    local gap = 8
    local fullW = 575

    local header = self:AddButton("devTableHeader", "หน้าผู้พัฒนา", startX, startY - 42, fullW, 30, nil)
    table.insert(self.itemButtons, header)

    local keyword = tostring(self.searchKeyword or "")
    local list = {}
    for _, cmd in ipairs(Xaou_GetDeveloperCommands()) do
        local okSearch = false
        if keyword == "" or keyword == "ค้นหา ID/ชื่อ" then
            okSearch = true
        else
            local k = string.lower(keyword)
            okSearch = string.find(string.lower(tostring(cmd.text or "")), k, 1, true) ~= nil
        end
        if okSearch then table.insert(list, cmd) end
    end

    for i, cmd in ipairs(list) do
        local y = startY + (i - 1) * (rowH + gap)
        local btnName = "btnDevCmd" .. tostring(i)
        local obj = self:AddButton(btnName, tostring(cmd.text or ""), startX, y, fullW, rowH, nil)
        obj.tooltips = tostring(cmd.text or "")
        self.devButtonData[btnName] = cmd
        table.insert(self.itemButtons, obj)
    end

    if self.pageText ~= nil then
        self.pageText.m_title.text = "ผู้พัฒนา"
    end

    pcall(function() self:UpdateBottomLayout() end)
end

-- จัดปุ่มด้านล่างสำหรับหน้า NPC แบบ Wide Table
function XaouItemWindow:UpdateBottomLayout()
    local function show(obj, v)
        if obj ~= nil then pcall(function() obj.visible = v end) end
    end
    local function move(obj, x, y)
        if obj ~= nil then
            pcall(function()
                if obj.SetXY ~= nil then obj:SetXY(x, y) else obj.x = x; obj.y = y end
            end)
        end
    end

    local mode = tostring(self.mainMode or "item")
    local cleanMode = (mode == "npc" or mode == "developer")

    if cleanMode then
        -- หน้า NPC/ผู้พัฒนา ใช้แท็บหลัก + ปิด ไม่ใช้ก่อนหน้า/ถัดไป/รีเฟรช/รายการ แก้กรอบ
        show(self.btnPrev, false)
        show(self.btnNext, false)
        show(self.pageText, false)
        show(self.btnRefresh, false)
        show(self.btnViewMode, false)
        show(self.btnClose, true)

        -- จัดแท็บหลักไว้กลางหน้าต่างแนวนอน
        move(self.btnModeItem, 1000, 50)
        move(self.btnModeBook, 1000, 150)
        move(self.btnModeBuilding, 1000, 250)
        move(self.btnModeNpc, 1000, 250)
        move(self.btnModeDev, 1000, 450)
        move(self.btnClose, 1000, 500)
        return
    end

    -- โหมดไอเทม/คัมภีร์/อาคาร กลับตำแหน่งเดิม
    show(self.btnPrev, true)
    show(self.btnNext, true)
    show(self.pageText, true)
    show(self.btnRefresh, true)
    show(self.btnViewMode, true)
    show(self.btnClose, true)

    move(self.btnPrev, 830, 450)
    move(self.pageText, 830, 400)
    move(self.btnNext, 830, 520)
    move(self.btnRefresh, 350, 565)
    move(self.btnViewMode, 450, 565)
    move(self.btnClose, 965, 400)
    move(self.btnModeItem, 1000, 50)
    move(self.btnModeBook, 1000, 150)
    move(self.btnModeBuilding, 1000, 250)
    move(self.btnModeNpc, 1000, 250)
    move(self.btnModeDev, 1000, 450)
end

-- เก็บฟังก์ชันเดิมไว้ แล้ว override เฉพาะส่วน NPC
local Xaou_OldRefreshList_NpcIntegrated = XaouItemWindow.RefreshList
function XaouItemWindow:RefreshList()
    if self.mainMode == "npc" then
        self:RefreshNpcPage()
        return
    elseif self.mainMode == "developer" then
        self:RefreshDeveloperPage()
        return
    end
    return Xaou_OldRefreshList_NpcIntegrated(self)
end

local Xaou_OldSetMainMode_NpcIntegrated = XaouItemWindow.SetMainMode
function XaouItemWindow:SetMainMode(mode)
    self.mainMode = tostring(mode or "item")
    self.page = 1

    -- เปลี่ยนชื่อหัวหน้าต่างตามโหมด
    local title = "เมนูเสกของ"
    if self.mainMode == "npc" then
        title = "เมนูจัดการ NPC"
    elseif self.mainMode == "book" then
        title = "เมนูคัมภีร์"
    elseif self.mainMode == "building" then
        title = "เมนูอาคาร"
    elseif self.mainMode == "developer" then
        title = "ผู้พัฒนา"
    end
    pcall(function() self:SetTitle(title) end)

    -- หน้า NPC/ผู้พัฒนา ใช้แนวนอนกว้างขึ้น แต่ความสูงเท่าเดิมเพื่อไม่ให้ล้นมือถือ
    if self.mainMode == "npc" or self.mainMode == "developer" then
        if self.mainMode == "npc" then
            self.npcPage = self.npcPage or "main"
        end
        self.sx = 980
        self.sy = 620
        pcall(function() self:SetSize(self.sx, self.sy) end)
    else
        self.sx = 980
        self.sy = 620
        pcall(function() self:SetSize(self.sx, self.sy) end)   -- แก้ขนาดกรอบ
    end

    if self.mainMode == "item" then
        self:SetTopCategoryVisible(true)
    else
        self:SetTopCategoryVisible(false)
    end
    pcall(function() self:ForceMainPosition() end)
    self:RefreshList()
    pcall(function() self:UpdateBottomLayout() end)
end

local Xaou_OldOnObjectEvent_NpcIntegrated = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil then
        if obj.name == "btnModeNpc" then
            self:SetMainMode("npc")
            return true
        elseif obj.name == "btnModeDev" then
            self:SetMainMode("developer")
            return true
        end
        if self.mainMode == "developer" and self.devButtonData ~= nil then
            local cmd = self.devButtonData[tostring(obj.name)]
            if cmd ~= nil then
                if cmd.page ~= nil then
                    self:SetMainMode(tostring(cmd.page))
                    return true
                end
                if cmd.actions ~= nil then
                    local ok = Xaou_ApplyNpcActions((self.npcTarget or Xaou_CurrentNpcTarget or {}), cmd.actions)
                    if ok then
                        Xaou_Show("ทำงานสำเร็จ\n" .. tostring(cmd.text), "ผู้พัฒนา")
                    end
                    return true
                elseif cmd.note ~= nil then
                    Xaou_Show(tostring(cmd.text) .. "\n" .. tostring(cmd.note), "ผู้พัฒนา")
                    return true
                end
            end
        end
        if self.mainMode == "npc" and self.npcButtonData ~= nil then
            local cmd = self.npcButtonData[tostring(obj.name)]
            if cmd ~= nil then
                if cmd.page ~= nil then
                    self.npcPage = tostring(cmd.page)
                    self:RefreshList()
                    return true
                end
                if cmd.actions ~= nil then
                    local npc = self.npcTarget or Xaou_CurrentNpcTarget
                    local ok = Xaou_ApplyNpcActions(npc, cmd.actions)
                    if ok then
                        Xaou_Show("ใช้คำสั่งสำเร็จ\n" .. Xaou_SafeNpcName(npc) .. "\n" .. tostring(cmd.text), "NPC")
                    end
                    return true
                elseif cmd.note ~= nil then
                    Xaou_Show(tostring(cmd.text) .. "\n" .. tostring(cmd.note), "NPC")
                    return true
                end
            end
        end
    end
    return Xaou_OldOnObjectEvent_NpcIntegrated(self, t, obj, context)
end

function Xaou_IconItemSpawner:ChangeTime(hour)
    World:SetDay(World.YearDayCount, hour, World.DayCount)
end
-- 📢 **ประกาศเกี่ยวกับการนำผลงานไปใช้งาน**

-- ม็อดนี้เป็นผลงานที่ผู้พัฒนาใช้เวลาในการศึกษา ทดลอง และพัฒนาด้วยตนเอง

-- ✅ สามารถดาวน์โหลดและใช้งานได้ตามปกติ

-- ❌ ห้ามคัดลอก ดัดแปลง รีอัปโหลด หรือเผยแพร่ผลงานนี้ในทุกช่องทาง โดยไม่ได้รับอนุญาตจากผู้พัฒนา

-- หากต้องการนำผลงานไปต่อยอด แก้ไข หรือเผยแพร่ กรุณาติดต่อขออนุญาตก่อนทุกครั้ง

-- โปรดเคารพสิทธิ์และให้เกียรติผู้สร้างสรรค์ผลงาน ขอบคุณทุกท่านที่สนับสนุนและใช้งานม็อดอย่างถูกต้อง 🙏

-- **ผู้พัฒนา:** xaouxaou009
