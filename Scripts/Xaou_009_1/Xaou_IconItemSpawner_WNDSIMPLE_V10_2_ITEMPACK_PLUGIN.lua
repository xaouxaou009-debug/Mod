-- v.10.4

local XaouItemWindow = CS.Wnd_Simple.CreateWindow("XaouItemWindow")
local XaouAmountWindow = CS.Wnd_Simple.CreateWindow("XaouAmountWindow")

-- เพิ่ม/แก้รายการตรงนี้ได้เลย
local XaouBaseItemList = {


}


local XaouItemList = nil
local XaouItemMap = nil
local XaouDatabaseSignature = ""
local XaouPackStats = { packs = 0, extra = 0, total = 0, duplicate = 0 }

local function Xaou_NormalizeItemData(data)
    if data == nil then return nil end
    local id = data.id or data.ID or data.Name or data.name
    if id == nil or tostring(id) == "" then return nil end
    return {
        id = tostring(id),
        count = tonumber(data.count or data.Count or data.num or data.Num or 1) or 1,
        cat = tostring(data.cat or data.category or data.Category or "special"),
        pack = tostring(data.pack or data.Pack or data.packName or data.PackName or ""),
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
    obj:SetSize(w or 100, h or 34, false)
    if icon ~= nil and icon ~= "" then
        pcall(function()
            if obj.m_icon ~= nil then
                obj.m_icon.icon = icon
            end
        end)
    end
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

function XaouItemWindow:RefreshList()
    self:FixPage()
    self:ClearItemButtons()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}

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
        
        local startX = 65
        local startY = 185
        local cellW = 122
        local cellH = 86
        local gapX = 10
        local gapY = 12
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
                local btn = self:AddButton(btnName, text,
                    startX + col * (cellW + gapX),
                    startY + r * (cellH + gapY),
                    cellW, cellH, icon)
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
        
        local startX = 65
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
                    self.favButton.m_title.text = added and "⭐ เอาออกโปรด" or "☆ เพิ่มโปรด"
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

function XaouItemWindow:OnInit()
    self.sx = 660
    self.sy = 650
    self.page = 1
    self.pageSize = 8
    self.category = "all"
    self.viewMode = "list"
    self.searchKeyword = ""
    self.buttonData = {}

    self:SetTitle("เมนูเสกของ")
    self:SetSize(self.sx, self.sy)

    self:AddLabel("txtTitle", "เมนูเสกของแบบรายการ + รูปไอเทม", 45, 36, 560, 26)
    self.statusLine1 = self:AddLabel("txtStatus1", "ไอเทม : 0 | ค้นพบ : 0 | หมวด : ทั้งหมด", 45, 62, 560, 22)
    self.statusLine2 = self:AddLabel("txtStatus2", "แพ็ก : 0 | เพิ่ม : +0 | ซ้ำ : 0", 45, 84, 560, 22)

    self:AddLabel("txtSearchLabel", "ค้นหา", 65, 110, 55, 26)
    self.inputSearch = self:AddInput("inputSearch", "", 120, 108, 270, 28)
    self:AddButton("btnSearch", "ค้นหา", 400, 106, 85, 32)
    self:AddButton("btnAll", "ทั้งหมด", 495, 106, 85, 32)

    self:AddButton("btnCatAll", "ทั้งหมด", 30, 146, 60, 30)
    self:AddButton("btnCatvkski", "อาหาร", 100, 146, 50, 30)
    self:AddButton("btnCatอาวุธ", "อาวุธ", 160, 146, 50, 30)
    self:AddButton("btnCatโอสถ", "โอสถ", 220, 146, 50, 30)
    self:AddButton("btnCatยารักษา", "ยารักษา", 280, 146, 50, 30)
    self:AddButton("btnCatยันต์", "ยันต์", 340, 146, 50, 30)
    self:AddButton("btnCatวัตถุดิบ", "วัตถุดิบ", 400, 146, 50, 30)
    self:AddButton("btnCatอื่น", "อื่นๆ", 460, 146, 50, 30)
    self:AddButton("btnCatFav", "⭐ โปรด", 520, 146, 50, 30)
    self:AddButton("btnCatRecent", "ล่าสุด", 580, 146, 50, 30)

    self:AddLabel("listBg", "", 45, 175, 575, 330)

    self:AddButton("btnPrev", "◀ ก่อนหน้า", 65, 515, 120, 34)
    self.pageText = self:AddLabel("txtPage", "หน้า 1 / 1", 235, 519, 150, 28)
    self:AddButton("btnNext", "ถัดไป ▶", 430, 515, 120, 34)

    self:AddButton("btnRefresh", "รีเฟรช", 135, 565, 100, 34)
    self.btnViewMode = self:AddButton("btnViewMode", "▦ ตาราง", 280, 565, 100, 34)
    self:AddButton("btnClose", "ปิด", 425, 565, 100, 34)
    self:AddLabel("txtTitle", "[ผู้พัฒนา Mod : XaouXaou_009] & บัสเตอร์ฟายทำนู๋เสียใจ", 310, 620, 560, 26)
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
        if obj.name == "btnClose" then
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
    
    self._xaouFixTicks = 12
    self._xaouRefreshTicks = 8
    pcall(function() self:ForceMainPosition() end)
    pcall(function() Xaou_RebuildItemDatabase(true) end)
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

-- 📢 **ประกาศเกี่ยวกับการนำผลงานไปใช้งาน**

-- ม็อดนี้เป็นผลงานที่ผู้พัฒนาใช้เวลาในการศึกษา ทดลอง และพัฒนาด้วยตนเอง

-- ✅ สามารถดาวน์โหลดและใช้งานได้ตามปกติ

-- ❌ ห้ามคัดลอก ดัดแปลง รีอัปโหลด หรือเผยแพร่ผลงานนี้ในทุกช่องทาง โดยไม่ได้รับอนุญาตจากผู้พัฒนา

-- หากต้องการนำผลงานไปต่อยอด แก้ไข หรือเผยแพร่ กรุณาติดต่อขออนุญาตก่อนทุกครั้ง

-- โปรดเคารพสิทธิ์และให้เกียรติผู้สร้างสรรค์ผลงาน ขอบคุณทุกท่านที่สนับสนุนและใช้งานม็อดอย่างถูกต้อง 🙏

-- **ผู้พัฒนา:** xaouxaou009
