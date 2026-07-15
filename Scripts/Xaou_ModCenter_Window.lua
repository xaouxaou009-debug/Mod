-- Xaou Mod Center. Routes to existing feature windows without replacing game logic.

local XMC_View, XMC_Target, XMC_Section = nil, nil, "quick"
local XMC_CompatShell = false
local XMC_Page, XMC_PageSize = 1, 6
local XMC_FeatureData = {}
local XMC_WindowTitle = "Xaou ACS Mod"

local XMC_Sections = {
    quick = {title="เมนู ฟังก์ชั่น", desc="ฟังก์ชันที่ ACS_Mod มีอยู่ตอนนี้", features={
        {text="เสกไอเทม", action="item"}, {text="เปิดใจ+เพิ่มความสัมพันธ์", action="jianghu"},
        {text="เปิดคลังจักรวาล", action="space"}, {text="ไอเทมคูณ2", action="world_tools"},
        {text="เปิด-ปิด ก่อสร้าง", action="tools"}, 
        {text="เวลา / ฤดูกาล / อากาศ", action="time_weather"}, {text="เรียกบอส", action="boss"}, 
        {text="เตาควบคุมอุณหภูมิ", action="building_temp"},
         
         
    }},
    npc = {title="ระบบ NPC", desc="จัดการตัวละครและดึงคนเข้าสำนัก", features={
        {text="แก้ไขค่า NPC ", action="legacy_npc"}, {text="ดึง NPC เข้าสำนัก", action="selector"},
        {text="เพิ่มค่าสถานะทั้ง 5", action="boost_five_stats"}, {text="ทะลวงขั้นทันที", action="breakthrough_now"},
        {text="ชุบชีวิต NPC", action="revive_npc"}, {text="ขโมยของ NPC", action="steal_npc_item"},
        {text="ยืดเวลาทัณฑ์สวรรค์", action="extend_heavenly_tribulation"},


        
    }},
    book = {title="คัมภีร์และวิชา", desc="ระบบหอคัมภีร์และการเรียนวิชา", features={
        {text="เก็บคัมภีร์เข้าหอ", action="bulk_book"}, {text="เรียนวิชา", action="learn"},
        {text="หนังสือคัมภีร์", action="book_menu"}, 
        
    }},
    world = {title="กำลังพัฒนา", desc="กำลังพัฒนา", features={
        
       -- {text="เปิดแผนที่วาร์ป", action="warp_map"}, {text="วาร์ป NPC กลับสำนัก", action="warp_home"}, --
       -- {text="เครื่องมือสร้าง", action="tools"}, --
        
    }},
    developer = {title="ผู้พัฒนา", desc="เครื่องมือเดิมและหน้าทดสอบของ Xaou", features={
        -- {text="เปิด Mod Center เดิม", action="legacy_npc"},
        
    }},
}

local function xmc_child(view, name)
    local value=nil; pcall(function() value=view:GetChild(name) end); return value
end
local function xmc_text(obj, value)
    if not obj then return end
    pcall(function() obj.text=tostring(value or "") end); pcall(function() obj.title=tostring(value or "") end)
end
local function xmc_visible(obj, value)
    if not obj then return end
    pcall(function() obj.visible=value==true end); pcall(function() obj.touchable=value==true end); pcall(function() obj.enabled=value==true end)
end
local function xmc_enabled(obj, value)
    if not obj then return end
    pcall(function() obj.enabled=value==true end)
    pcall(function() obj.touchable=value==true end)
    pcall(function() obj.alpha=value==true and 1 or 0.45 end)
end
local function xmc_name(npc)
    if Xaou_SafeNpcName then return Xaou_SafeNpcName(npc) end
    local name="NPC เป้าหมาย"; pcall(function() name=tostring(npc.Name or npc:GetName()) end); return name
end
local function xmc_real_npc(npc)
    if Xaou_GetRealNpcObject then return Xaou_GetRealNpcObject(npc) end
    local real=npc; pcall(function() if npc.npcObj then real=npc.npcObj end end); return real
end
local function xmc_update_target(view)
    local name=xmc_name(XMC_Target)
    if XMC_CompatShell then
        xmc_text(xmc_child(view,"subtitle"),"NPC เป้าหมาย: "..name.." | ผู้พัฒนา: Xaou009")
    else
        xmc_text(xmc_child(view,"npcName"),name)
    end
    local status="พร้อมใช้งาน"
    local real=xmc_real_npc(XMC_Target)
    pcall(function()
        local school=real.SchoolID or 0
        local stage=real.Practice and real.Practice.GongStage or "-"
        status="สำนัก: "..tostring(school).." | ขั้นฝึกฝน: "..tostring(stage)
    end)
    if not XMC_CompatShell then xmc_text(xmc_child(view,"npcStatus"),status) end
    local icon=""; pcall(function() icon=tostring(real.Race.TexPath or real.Race.Rolepaint or "") end)
    local loader=xmc_child(view,XMC_CompatShell and "portrait" or "npcPortrait"); pcall(function() loader.url=icon end); xmc_visible(loader,icon~="")
end
local function xmc_refresh(view)
    xmc_text(xmc_child(view,"title"),XMC_WindowTitle)
    local section=XMC_Sections[XMC_Section] or XMC_Sections.quick
    local total=#section.features
    local maxPage=math.max(1,math.ceil(total/XMC_PageSize))
    XMC_Page=math.max(1,math.min(XMC_Page,maxPage))
    local first=(XMC_Page-1)*XMC_PageSize+1
    xmc_text(xmc_child(view,XMC_CompatShell and "npcName" or "sectionTitle"),section.title)
    xmc_text(xmc_child(view,XMC_CompatShell and "npcStatus" or "description"),section.desc.."  |  หน้า "..tostring(XMC_Page).."/"..tostring(maxPage))
    XMC_FeatureData={}
    for i=1,XMC_PageSize do
        local btn=xmc_child(view,XMC_CompatShell and (i<=3 and ({"btnOpenHeart","btnMaxFavor","btnRefresh"})[i] or "") or ("feature"..i)); local data=section.features[first+i-1]
        if data then xmc_text(btn,data.text); XMC_FeatureData[i]=data; xmc_visible(btn,true)
        else xmc_visible(btn,false) end
    end
    if not XMC_CompatShell then
        local prev,nextb=xmc_child(view,"feature7"),xmc_child(view,"feature8")
        xmc_text(prev,"◀ ย้อนกลับ");xmc_text(nextb,"ถัดไป ▶")
        xmc_visible(prev,true);xmc_visible(nextb,true)
        xmc_enabled(prev,XMC_Page>1);xmc_enabled(nextb,XMC_Page<maxPage)
    end
    local menus={{"menuQuick","quick","เมนูฟังก์ชั่น"},{"menuNpc","npc","NPC"},{"menuBook","book","คัมภีร์"},{"menuWorld","world","โลก"},{"menuDeveloper","developer","ผู้พัฒนา"}}
    for index,m in ipairs(menus) do
        local menuName=XMC_CompatShell and ("npcBtn"..tostring(index)) or m[1]
        xmc_text(xmc_child(view,menuName),(XMC_Section==m[2] and "▶ " or "")..m[3])
    end
    if XMC_CompatShell then
        xmc_text(xmc_child(view,"npcBtn6"),"ปิดหน้าต่าง")
        xmc_visible(xmc_child(view,"btnPrev"),false);xmc_visible(xmc_child(view,"btnNext"),false);xmc_visible(xmc_child(view,"txtPage"),false)
        xmc_text(xmc_child(view,"hint"),"เลือกหมวดด้านซ้าย แล้วเลือกเครื่องมือด้านขวา")
    end
end

function Xaou_CloseStandaloneModCenter()
    if XMC_View then pcall(function() XMC_View:RemoveFromParent() end);pcall(function() XMC_View:Dispose() end);XMC_View=nil end
end

local function xmc_open_legacy()
    if Xaou_OpenNpcManagerWindow then return Xaou_OpenNpcManagerWindow(XMC_Target) end
    if XaouItemWindow then
        XaouItemWindow:SetNpcTarget(XMC_Target); XaouItemWindow.mainMode="npc"; XaouItemWindow.npcPage="quick"
        XaouItemWindow:Show(); pcall(function() XaouItemWindow:RefreshList() end)
    end
end
local function xmc_action(action)
    if action=="item" and Xaou_OpenItemSpawnerWindow then
        local ok, result = pcall(Xaou_OpenItemSpawnerWindow)
        if ok and result ~= false then
            Xaou_CloseStandaloneModCenter()
            return result
        end
        if world then world:ShowMsgBox("เปิดหน้าต่างเสกไอเทมไม่สำเร็จ\n"..tostring(result)) end
        return false
    end
    if action=="jianghu" and Xaou_OpenJianghuRelationsWindow then return Xaou_OpenJianghuRelationsWindow() end
    if action=="boss" then
        if Xaou_OpenBossSummonWindow==nil then pcall(require,'Scripts/XaouBossSummonWindow.lua') end
        if Xaou_OpenBossSummonWindow then return Xaou_OpenBossSummonWindow() end
    end
    if action=="building_temp" then
        if Xaou_OpenWorldToolsWindow then
            Xaou_CloseStandaloneModCenter()
            return Xaou_OpenWorldToolsWindow(nil, "building")
        end
    end
    if action=="manual_books" and Xaou_OpenBookMenuWindow then
        local ok,result=pcall(function()
            return Xaou_OpenBookMenuWindow(XMC_Target, "manual")
        end)
    
        if ok and result~=false then
            Xaou_CloseStandaloneModCenter()
            return result
        end
    
        if world then
            world:ShowMsgBox(
                "เปิดหน้าหนังสือคัมภีร์ไม่สำเร็จ\n"..
                tostring(result)
            )
        end
        return false
    end
    if action=="learn" and Xaou_OpenLearnWindow then
        local target=XMC_Target
        local ok,result=pcall(function() return Xaou_OpenLearnWindow(target) end)
        if ok and result~=false then Xaou_CloseStandaloneModCenter();return result end
        if world then world:ShowMsgBox("เปิดหน้าเรียนวิชาไม่สำเร็จ\n"..tostring(result)) end
        return false
    end
    if action=="time_weather" then
        if Xaou_OpenWorldToolsWindow == nil then
            pcall(require, "Scripts/Xaou_WorldTools_Core.lua")
            pcall(require, "Scripts/Xaou_WorldTools_Window.lua")
        end
        if Xaou_OpenWorldToolsWindow ~= nil then
            Xaou_CloseStandaloneModCenter()
            local ok, result = pcall(function()
                return Xaou_OpenWorldToolsWindow(nil, "climate")
            end)
            if ok and result ~= false then return true end
            if world then world:ShowMsgBox("เปิดเมนูเวลา / ฤดูกาล / อากาศไม่สำเร็จ\n" .. tostring(result)) end
            return false
        end
        if world then world:ShowMsgBox("ไม่พบหน้าต่างเครื่องมือเวลา") end
        return false
    end
    if action=="boost_five_stats" then
        if XMC_Target == nil then
            if world then world:ShowMsgBox("กรุณาเลือก NPC ก่อน") end
            return false
        end

        if Xaou_ApplyNpcActions == nil then
            pcall(require, "Scripts/Xaou_NpcHelper.lua")
            pcall(require, "Scripts/Xaou_NpcActions.lua")
        end

        if Xaou_ApplyNpcActions == nil then
            if world then world:ShowMsgBox("ไม่พบระบบเพิ่มค่าสถานะ NPC") end
            return false
        end

        local ok, success, detail = pcall(function()
            return Xaou_ApplyNpcActions(XMC_Target, {
                {kind="addmodifier", id="QuanBu76"},
            })
        end)

        if ok and success == true then
            if world then world:ShowMsgBox("เพิ่มค่าสถานะทั้ง 5 สำเร็จแล้ว") end
            return true
        end

        if world then
            world:ShowMsgBox("เพิ่มค่าสถานะไม่สำเร็จ\n" .. tostring(detail or success))
        end
        return false
    end
    if action=="breakthrough_now" then
        if XMC_Target == nil then
            if world then world:ShowMsgBox("กรุณาเลือก NPC ก่อน") end
            return false
        end

        if Xaou_ApplyNpcActions == nil then
            pcall(require, "Scripts/Xaou_NpcHelper.lua")
            pcall(require, "Scripts/Xaou_NpcActions.lua")
        end

        if Xaou_ApplyNpcActions == nil then
            if world then world:ShowMsgBox("ไม่พบระบบจัดการ NPC") end
            return false
        end

        local ok, success, detail = pcall(function()
            return Xaou_ApplyNpcActions(XMC_Target, {
                {kind="addmodifier", id="Dan_BrokenNeck76"},
            })
        end)

        if ok and success == true then
            if world then world:ShowMsgBox("ใช้คำสั่งทะลวงขั้นสำเร็จแล้ว") end
            return true
        end

        if world then
            world:ShowMsgBox("ทะลวงขั้นไม่สำเร็จ\n" .. tostring(detail or success))
        end
        return false
    end
    if action=="revive_npc" or action=="steal_npc_item" then
        if XMC_Target == nil then
            if world then world:ShowMsgBox("กรุณาเลือก NPC ก่อน") end
            return false
        end

        if Xaou_ApplyNpcActions == nil then
            pcall(require, "Scripts/Xaou_NpcHelper.lua")
            pcall(require, "Scripts/Xaou_NpcActions.lua")
        end

        if Xaou_ApplyNpcActions == nil then
            if world then world:ShowMsgBox("ไม่พบระบบจัดการ NPC") end
            return false
        end

        local modifierId = action=="revive_npc"
            and "Modifier_YinYangShuangYu76"
            or "Dan_BaiYanLang76"

        Xaou_CloseStandaloneModCenter()
        local ok, success, detail = pcall(function()
            return Xaou_ApplyNpcActions(XMC_Target, {
                {kind="addmodifier", id=modifierId},
            })
        end)

        if ok and success == true then return true end
        if world then
            world:ShowMsgBox("เปิดโหมดเลือกเป้าหมายไม่สำเร็จ\n" .. tostring(detail or success))
        end
        return false
    end
    if action=="extend_heavenly_tribulation" then
        if XMC_Target == nil then
            if world then world:ShowMsgBox("กรุณาเลือก NPC ก่อน") end
            return false
        end

        if Xaou_ApplyNpcActions == nil then
            pcall(require, "Scripts/Xaou_NpcHelper.lua")
            pcall(require, "Scripts/Xaou_NpcActions.lua")
        end

        if Xaou_ApplyNpcActions == nil then
            if world then world:ShowMsgBox("ไม่พบระบบจัดการ NPC") end
            return false
        end

        local ok, success, detail = pcall(function()
            return Xaou_ApplyNpcActions(XMC_Target, {
                {kind="addmodifier", id="Dan_ZhongLi76"},
            })
        end)

        if ok and success == true then
            if world then world:ShowMsgBox("ยืดเวลาทัณฑ์สวรรค์แล้ว 100 วัน") end
            return true
        end

        if world then
            world:ShowMsgBox("ยืดเวลาทัณฑ์สวรรค์ไม่สำเร็จ\n" .. tostring(detail or success))
        end
        return false
    end
    if action=="bulk_book" and Xaou_OpenBulkEsotericaWindow then
        local target=XMC_Target
        local ok,result=pcall(function() return Xaou_OpenBulkEsotericaWindow(target) end)
        if ok and result~=false then Xaou_CloseStandaloneModCenter();return result end
        if world then world:ShowMsgBox("เปิดหน้าเก็บคัมภีร์ไม่สำเร็จ\n"..tostring(result)) end
        return false
    end
    if action=="unlock_all_gong" then
        if Xaou_RunNewBookCommand==nil then
            pcall(require, "Scripts/Xaou_BookMenu_Core.lua")
        end
    
        if Xaou_RunNewBookCommand then
            local ok, success, detail=pcall(function()
                return Xaou_RunNewBookCommand(XMC_Target, {
                    text="วิชาสายหลักทั้งหมด",
                    category="unlock",
                    story="Xaou_Unlock_AllGong",
                })
            end)
    
            if ok and success==true then
                if world then
                    world:ShowMsgBox("ปลดล็อกวิชาสายหลักทั้งหมดแล้ว")
                end
                return true
            end
    
            if world then
                world:ShowMsgBox(
                    "ปลดล็อกวิชาไม่สำเร็จ\n"..
                    tostring(detail or success)
                )
            end
            return false
        end
    end
    if action=="book_menu" and Xaou_OpenBookMenuWindow then
        local target=XMC_Target
        local ok,result=pcall(function() return Xaou_OpenBookMenuWindow(target) end)
        if ok and result~=false then Xaou_CloseStandaloneModCenter();return result end
        if world then world:ShowMsgBox("เปิดเมนูคัมภีร์ไม่สำเร็จ\n"..tostring(result)) end
        return false
    end
    if action=="world_tools" and Xaou_OpenWorldToolsWindow then
        local ok,result=pcall(function() return Xaou_OpenWorldToolsWindow(nil,"world") end)
        if ok and result~=false then Xaou_CloseStandaloneModCenter();return result end
        if world then world:ShowMsgBox("เปิดเครื่องมือโลกไม่สำเร็จ\n"..tostring(result)) end
        return false
    end
    if action=="space" then
        local opener = Xaou_SpaceRing_OpenOriginalStorageUI
        if opener == nil then
            if world then world:ShowMsgBox("ไม่พบฟังก์ชันเปิดคลังจักรวาลเดิมของเกม") end
            return false
        end

        local ok, result = pcall(function()
            return opener(XMC_Target)
        end)

        if ok and result ~= false then
            return result
        end

        if world then
            world:ShowMsgBox("เปิดคลังจักรวาลไม่สำเร็จ\n" .. tostring(result))
        end
        return false
    end
    Xaou_CloseStandaloneModCenter()
    if action=="tools" and Xaou_OpenConstructionToolsWindow then return Xaou_OpenConstructionToolsWindow() end
    if action=="selector" and Xaou_OpenExternalNpcSelector then return Xaou_OpenExternalNpcSelector() end
    if action=="warp_map" and Xaou_WarpSystem and Xaou_WarpSystem.ShowMap then return Xaou_WarpSystem.ShowMap() end
    if action=="warp_home" and Xaou_WarpSystem and Xaou_WarpSystem.WarpSelectedNpcHome then return Xaou_WarpSystem.WarpSelectedNpcHome(XMC_Target) end
    if action=="map_info" and Xaou_WarpSystem and Xaou_WarpSystem.DebugMapInfo then return Xaou_WarpSystem.DebugMapInfo() end
    if action=="legacy_npc" then return xmc_open_legacy() end
    if world then world:ShowMsgBox("ฟังก์ชันนี้ยังไม่พร้อมใช้งาน") end
end

function Xaou_OpenStandaloneModCenter(npc)
    Xaou_CloseStandaloneModCenter(); XMC_Target=npc or Xaou_CurrentNpcTarget; XMC_Section="quick";XMC_Page=1
    local pkg=UIPackage or (CS.FairyGUI and CS.FairyGUI.UIPackage); local root=(GRoot and GRoot.inst) or (CS.FairyGUI and CS.FairyGUI.GRoot.inst)
    if not pkg or not root then return false end
    pcall(function() pkg.AddPackage("UI/XaoCtr") end)
    local view=nil
    local errors={}
    local function try_create(label, creator)
        if view then return end
        local ok, value=pcall(creator)
        if ok and value then view=value else errors[#errors+1]=label..": "..tostring(value) end
    end
    try_create("CreateObject",function() return pkg.CreateObject("XaoCtr","XaouModCenterWindow") end)
    try_create("CreateObject.xml",function() return pkg.CreateObject("XaoCtr","XaouModCenterWindow.xml") end)
    try_create("CreateObjectFromURL",function() return pkg.CreateObjectFromURL("ui://xmc97319xmc01") end)
    try_create("package item URL",function()
        local url=pkg.GetItemURL("XaoCtr","XaouModCenterWindow")
        if not url or tostring(url)=="" then return nil end
        return pkg.CreateObjectFromURL(url)
    end)
    if not view then
        try_create("compat JianghuNpcWindow",function() return nil end)
        if view then XMC_CompatShell=true end
    else
        XMC_CompatShell=false
    end
    if not view then return false,table.concat(errors,"\n") end
    XMC_View=view;root:AddChild(view);view.x=(root.width-view.width)/2;view.y=(root.height-view.height)/2
    xmc_text(xmc_child(view,"btnClose"),"×");xmc_text(xmc_child(view,"btnLanguage"),"ภาษา: TH")
    local menus={{"menuQuick","quick"},{"menuNpc","npc"},{"menuBook","book"},{"menuWorld","world"},{"menuDeveloper","developer"}}
    for index,m in ipairs(menus) do
        local buttonName, sectionName=XMC_CompatShell and ("npcBtn"..tostring(index)) or m[1],m[2]
        local b=xmc_child(view,buttonName)
        if b then b.onClick:Add(function() XMC_Section=sectionName;XMC_Page=1;xmc_refresh(view) end) end
    end
    local featureLimit=XMC_CompatShell and 3 or XMC_PageSize
    for i=1,featureLimit do
        local featureIndex=i
        local b=xmc_child(view,XMC_CompatShell and ({"btnOpenHeart","btnMaxFavor","btnRefresh"})[featureIndex] or ("feature"..featureIndex))
        if b then b.onClick:Add(function() local d=XMC_FeatureData[featureIndex];if d then xmc_action(d.action) end end) end
    end
    if not XMC_CompatShell then
        local prev,nextb=xmc_child(view,"feature7"),xmc_child(view,"feature8")
        if prev then prev.onClick:Add(function() if XMC_Page>1 then XMC_Page=XMC_Page-1;xmc_refresh(view) end end) end
        if nextb then nextb.onClick:Add(function()
            local section=XMC_Sections[XMC_Section] or XMC_Sections.quick
            local maxPage=math.max(1,math.ceil(#section.features/XMC_PageSize))
            if XMC_Page<maxPage then XMC_Page=XMC_Page+1;xmc_refresh(view) end
        end) end
    end
    local close=xmc_child(view,"btnClose");if close then close.onClick:Add(Xaou_CloseStandaloneModCenter) end
    if XMC_CompatShell then local close2=xmc_child(view,"npcBtn6");if close2 then close2.onClick:Add(Xaou_CloseStandaloneModCenter) end end
    local lang=xmc_child(view,"btnLanguage");if lang then lang.onClick:Add(function() if Xaou_ToggleLanguage then Xaou_ToggleLanguage() end end) end
    xmc_update_target(view);xmc_refresh(view);return true
end
