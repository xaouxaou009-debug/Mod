-- ============================================================
-- XAOU BOOK SYSTEM / UI
-- แสดงคัมภีร์จาก XML ใน Lua แบบรายการ/ตาราง
-- ต้องโหลดหลัง 01 และหลัง 06-08
-- ============================================================

if XaouItemWindow == nil and _G ~= nil then
    XaouItemWindow = _G.XaouItemWindow
end

function XaouItemWindow:GetBookPageSize()
    if self.viewMode == "grid" then return 12 end
    return 8
end

function XaouItemWindow:GetBookMaxPage()
    local keyword = tostring(self.searchKeyword or "")
    local list = Xaou_GetBookCommands(self.bookCategory or "ทั้งหมด", keyword)
    local maxPage = math.ceil(#list / self:GetBookPageSize())
    if maxPage < 1 then maxPage = 1 end
    return maxPage
end

function XaouItemWindow:FixBookPage()
    local maxPage = self:GetBookMaxPage()
    if self.page == nil then self.page = 1 end
    if self.page < 1 then self.page = 1 end
    if self.page > maxPage then self.page = maxPage end
end

function XaouItemWindow:RefreshBookPage()
    self:ClearItemButtons()
    self.itemButtons = {}
    self.buttonData = {}
    self.favButtonData = {}
    self.bookButtonData = {}
    self.bookCatButtonData = {}

    self.bookCategory = self.bookCategory or "ทั้งหมด"
    local keyword = tostring(self.searchKeyword or "")
    local allCount = #(Xaou_BookList or {})
    local list = Xaou_GetBookCommands(self.bookCategory, keyword)
    self:FixBookPage()

    if self.statusLine1 ~= nil then
        self.statusLine1.m_title.text = "คัมภีร์ : " .. tostring(allCount) .. " | ค้นพบ : " .. tostring(#list) .. " | หมวด : " .. tostring(self.bookCategory)
    end
    if self.statusLine2 ~= nil then
        local text = "กดคัมภีร์เพื่อเปิดหน้า XML รับคัมภีร์แบบ ItemCache"
        if keyword ~= "" then text = text .. " | คำค้น : " .. keyword end
        self.statusLine2.m_title.text = text
    end

    if self.btnViewMode ~= nil then
        if self.viewMode == "grid" then
            self.btnViewMode.m_title.text = "📋 รายการ"
        else
            self.btnViewMode.m_title.text = "▦ ตาราง"
        end
    end

    -- หมวดคัมภีร์ด้านซ้าย
    -- เพิ่มระบบแบ่งหน้าหมวด: ใช้ปุ่ม ◀ / ▶ เพื่อเลื่อนหมวดด้านซ้าย
    local cats = Xaou_GetBookCategories()
    local menuX = -60
    local menuY = 140
    local menuW = 160
    local menuH = 34
    local menuGap = 6
    local maxCat = 10 -- เว้น 1 แถวล่างไว้ทำปุ่มเปลี่ยนหน้าหมวด

    self.bookCatPage = self.bookCatPage or 1
    local maxCatPage = math.ceil(#cats / maxCat)
    if maxCatPage < 1 then maxCatPage = 1 end
    if self.bookCatPage < 1 then self.bookCatPage = 1 end
    if self.bookCatPage > maxCatPage then self.bookCatPage = maxCatPage end

    local startCat = (self.bookCatPage - 1) * maxCat + 1
    local endCat = startCat + maxCat - 1
    local showIndex = 0

    for i = startCat, endCat do
        local cat = cats[i]
        if cat ~= nil then
            showIndex = showIndex + 1
            local label = tostring(cat)
            if string.len(label) > 42 then label = string.sub(label, 1, 42) .. "..." end
            local name = "btnBookCat" .. tostring(showIndex)
            local btn = self:AddButton(name, label, menuX, menuY + (showIndex - 1) * (menuH + menuGap), menuW, menuH, nil)
            btn.tooltips = "หมวด: " .. tostring(cat) .. "\nหน้าหมวด: " .. tostring(self.bookCatPage) .. "/" .. tostring(maxCatPage)
            self.bookCatButtonData[name] = cat
            table.insert(self.itemButtons, btn)
        end
    end

    -- ปุ่มเปลี่ยนหน้าหมวดด้านซ้าย
    local catPageY = menuY + maxCat * (menuH + menuGap)
    local btnCatPrev = self:AddButton("btnBookCatPrev", "◀", menuX, catPageY, 50, menuH, nil)
    btnCatPrev.tooltips = "หมวดก่อนหน้า"
    table.insert(self.itemButtons, btnCatPrev)

    local btnCatPage = self:AddButton("btnBookCatPage", tostring(self.bookCatPage) .. "/" .. tostring(maxCatPage), menuX + 54, catPageY, 52, menuH, nil)
    btnCatPage.tooltips = "หน้าหมวดคัมภีร์"
    table.insert(self.itemButtons, btnCatPage)

    local btnCatNext = self:AddButton("btnBookCatNext", "▶", menuX + 110, catPageY, 50, menuH, nil)
    btnCatNext.tooltips = "หมวดถัดไป"
    table.insert(self.itemButtons, btnCatNext)

    local pageSize = self:GetBookPageSize()
    local startIndex = (self.page - 1) * pageSize + 1
    local endIndex = startIndex + pageSize - 1
    local row = 0

    if self.viewMode == "grid" then
        local startX = 200
        local startY = 185
        local cellW = 122
        local cellH = 86
        local gapX = 10
        local gapY = 12
        local cols = 4
        for i = startIndex, endIndex do
            local book = list[i]
            if book ~= nil then
                local idx = i - startIndex
                local col = idx % cols
                local r = math.floor(idx / cols)
                local text = Xaou_BookCleanText(book.text or book.id)
                if string.len(text) > 28 then text = string.sub(text, 1, 28) .. "..." end
                local btnName = "btnBook" .. tostring(i)
                local icon = book.icon or "Sprs/xaou02.png"
                local btn = self:AddButton(btnName, text, startX + col * (cellW + gapX), startY + r * (cellH + gapY), cellW, cellH, icon)
                btn.tooltips = "ID: " .. tostring(book.id) .. "\nหมวด: " .. tostring(book.cat) .. "\nกดเพื่อเปิด รับคัมภีร์"
                self.bookButtonData[btnName] = book
                table.insert(self.itemButtons, btn)
                row = row + 1
            end
        end
    else
        local startX = 200
        local startY = 185
        local rowW = 620
        local rowH = 32
        local gap = 5
        for i = startIndex, endIndex do
            local book = list[i]
            if book ~= nil then
                row = row + 1
                local text = tostring(i) .. ". " .. Xaou_BookCleanText(book.text or book.id)
                local y = startY + (row - 1) * (rowH + gap)
                local btnName = "btnBook" .. tostring(i)
                local icon = book.icon or "Sprs/xaou02.png"
                local btn = self:AddButton(btnName, text, startX, y, rowW, rowH, icon)
                btn.tooltips = "ID: " .. tostring(book.id) .. "\nหมวด: " .. tostring(book.cat) .. "\nStory: " .. tostring(book.story)
                self.bookButtonData[btnName] = book
                table.insert(self.itemButtons, btn)
            end
        end
    end

    if row == 0 then
        local btn = self:AddButton("btnBookEmpty", "ไม่พบคัมภีร์ที่ค้นหา", 200, 185, 520, 34, nil)
        table.insert(self.itemButtons, btn)
    end

    if self.pageText ~= nil then
        self.pageText.m_title.text = "หน้า " .. tostring(self.page) .. " / " .. tostring(self:GetBookMaxPage()) .. " (" .. tostring(#list) .. "/" .. tostring(allCount) .. ")"
    end
end

local Xaou_OldRefreshList_BookIntegrated = XaouItemWindow.RefreshList
function XaouItemWindow:RefreshList()
    if self.mainMode == "book" then
        self:RefreshBookPage()
        return
    end
    return Xaou_OldRefreshList_BookIntegrated(self)
end

local Xaou_OldNextPage_BookIntegrated = XaouItemWindow.NextPage
function XaouItemWindow:NextPage()
    if self.mainMode == "book" then
        self.page = (self.page or 1) + 1
        self:FixBookPage()
        self:RefreshList()
        return
    end
    return Xaou_OldNextPage_BookIntegrated(self)
end

local Xaou_OldPrevPage_BookIntegrated = XaouItemWindow.PrevPage
function XaouItemWindow:PrevPage()
    if self.mainMode == "book" then
        self.page = (self.page or 1) - 1
        self:FixBookPage()
        self:RefreshList()
        return
    end
    return Xaou_OldPrevPage_BookIntegrated(self)
end

local Xaou_OldSetMainMode_BookIntegrated = XaouItemWindow.SetMainMode
function XaouItemWindow:SetMainMode(mode)
    mode = tostring(mode or "item")
    if mode == "book" then
        self.bookCategory = self.bookCategory or "ทั้งหมด"
    end
    return Xaou_OldSetMainMode_BookIntegrated(self, mode)
end

local Xaou_OldOnObjectEvent_BookIntegrated = XaouItemWindow.OnObjectEvent
function XaouItemWindow:OnObjectEvent(t, obj, context)
    if t == "onClick" and obj ~= nil and self.mainMode == "book" then
        -- ปุ่มเปลี่ยนหน้าหมวดด้านซ้าย
        if tostring(obj.name) == "btnBookCatPrev" then
            self.bookCatPage = (self.bookCatPage or 1) - 1
            if self.bookCatPage < 1 then self.bookCatPage = 1 end
            self:RefreshList()
            return true
        end

        if tostring(obj.name) == "btnBookCatNext" then
            local cats = Xaou_GetBookCategories()
            local maxCat = 10
            local maxCatPage = math.ceil(#cats / maxCat)
            if maxCatPage < 1 then maxCatPage = 1 end
            self.bookCatPage = (self.bookCatPage or 1) + 1
            if self.bookCatPage > maxCatPage then self.bookCatPage = maxCatPage end
            self:RefreshList()
            return true
        end

        -- ปุ่มแสดงเลขหน้า ไม่ต้องทำอะไร กดแล้วรีเฟรชเฉย ๆ
        if tostring(obj.name) == "btnBookCatPage" then
            self:RefreshList()
            return true
        end

        if self.bookCatButtonData ~= nil then
            local cat = self.bookCatButtonData[tostring(obj.name)]
            if cat ~= nil then
                self.bookCategory = tostring(cat)
                self.page = 1
                self:RefreshList()
                return true
            end
        end
        if self.bookButtonData ~= nil then
            local book = self.bookButtonData[tostring(obj.name)]
            if book ~= nil then
                Xaou_BookReceive(book)
                 self:Hide()
                return true
            end
        end
    end
    return Xaou_OldOnObjectEvent_BookIntegrated(self, t, obj, context)
end
