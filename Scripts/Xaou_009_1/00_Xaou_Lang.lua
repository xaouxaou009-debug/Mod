Xaou_LangSystem = Xaou_LangSystem or {}
Xaou_LangSystem.current = Xaou_LangSystem.current or "th"

local function _xaou_merge(dst, src)
    if type(dst) ~= "table" then dst = {} end
    if type(src) == "table" then
        for k, v in pairs(src) do dst[k] = v end
    end
    return dst
end

Xaou_LangData = Xaou_LangData or {}
Xaou_LangData.th = _xaou_merge(Xaou_LangData.th, {
    ["lang.name"] = "ภาษาไทย",
    ["lang.button"] = "ภาษา: TH",
    ["lang.changed"] = "เปลี่ยนภาษาเป็นไทยแล้ว",

    ["window.title.main"] = "ศูนย์ม็อด Xaou009",
    ["window.title.item"] = "เมนูเสกของ",
    ["window.title.amount"] = "เลือกจำนวน",
    ["window.title.npc"] = "เมนูจัดการ NPC",
    ["window.devline"] = "ผู้พัฒนา : Xaou009 & บัสเตอร์ฟายทำนู๋เสียใจ",

    ["label.search"] = "ค้นหา",
    ["search.placeholder"] = "ค้นหา ID/ชื่อ",
    ["button.all"] = "ทั้งหมด",
    ["button.refresh"] = "รีเฟรช",
    ["button.close"] = "ปิด",
    ["button.cancel"] = "ยกเลิก",
    ["button.view.list"] = "📋 รายการ",
    ["button.view.grid"] = "▦ ตาราง",
    ["button.favorite.add"] = "☆ เพิ่มโปรด",
    ["button.favorite.remove"] = "⭐ เอาออกโปรด",

    ["mode.item"] = "ไอเทม",
    ["mode.book"] = "คัมภีร์",
    ["mode.building"] = "อาคาร",
    ["mode.npc"] = "NPC",
    ["mode.warp"] = "วาร์ป",
    ["mode.developer"] = "ผู้พัฒนา",

    ["cat.all"] = "ทั้งหมด",
    ["cat.recent"] = "ล่าสุด",
    ["cat.favorite"] = "★ โปรด",
    ["cat.food"] = "อาหาร",
    ["cat.weapon"] = "อาวุธ",
    ["cat.elixir"] = "โอสถ",
    ["cat.medicine"] = "ยารักษา",
    ["cat.talisman"] = "ยันต์",
    ["cat.material"] = "วัตถุดิบ",
    ["cat.other"] = "อื่นๆ",
    ["cat.magic"] = "อาวุธ/คัมภีร์",
    ["cat.special"] = "พิเศษ",

    ["status.item.line1"] = "ไอเทม : %s | ค้นพบ : %s | หมวด : %s",
    ["status.item.line2"] = "แพ็ก : %s | เพิ่ม : +%s | ซ้ำ : %s",
    ["status.keyword"] = "คำค้น : %s",
    ["status.mode.prepare"] = "โหมด : %s | กำลังเตรียมระบบ",
    ["status.mode.newarea"] = "หน้านี้เป็นพื้นที่สำหรับฟังก์ชันใหม่",
    ["status.npc.line1"] = "โหมด : NPC | หมวด : %s | เป้าหมาย : %s",
    ["status.npc.no_target"] = "ยังไม่ได้เลือก NPC : ให้เปิดจากปุ่มบนตัวละคร/NPC",
    ["status.npc.help"] = "เลือกหมวดซ้าย แล้วกดปุ่มคำสั่งด้านขวาได้ทันที",
    ["status.book.line1"] = "คัมภีร์ : %s | ค้นพบ : %s | หมวด : %s",
    ["status.book.help"] = "กดคัมภีร์เพื่อเปิดหน้า XML รับคัมภีร์แบบ ItemCache",

    ["amount.item_name"] = "ชื่อไอเทม",
    ["amount.tip"] = "เลือกจำนวนที่จะเสก",
    ["message.no_item_data"] = "ไม่มีข้อมูลไอเทม",
    ["message.item_not_found"] = "ไม่พบไอเทม ID:\n%s",
    ["message.spawn_no_pos"] = "หาตำแหน่งวางของไม่เจอ",
    ["message.spawn_ok"] = "%s\nเสกสำเร็จ จำนวน %s",
    ["message.spawn_fail_title"] = "เสกของล้มเหลว",
    ["message.spawn_ok_title"] = "เสกของสำเร็จ",
    ["message.no_search_result"] = "ไม่พบรายการที่ค้นหา",
    ["message.book_no_result"] = "ไม่พบคัมภีร์ที่ค้นหา",

    ["main.btn.multiply"] = "คูน×2",
    ["main.tip.multiply"] = "เพิ่มจำนวนไอเทมเป็น 2 เท่า",
    ["main.btn.youcui"] = "หลอมอสูร",
    ["main.tip.youcui"] = "ยกระดับคุณภาพไอเทมขึ้น 1 ขั้น โดยสำเร็จแน่นอน",
    ["main.btn.lingcui"] = "หลอมจิต",
    ["main.tip.lingcui"] = "หลอมจิตไอเทม 1 ครั้ง โดยสำเร็จแน่นอน",
    ["main.btn.tianjie"] = "ทัณฑ์สวรรค์36",
    ["main.tip.tianjie"] = "ทำให้อาวุธวิเศษผ่านการชำระล้างด้วยทัณฑ์สวรรค์ 36 ชั้น",
    ["main.tip.npc_mod"] = "เปิดเมนูแก้ไข NPC แบบ UI ใหม่",
})

Xaou_LangData.en = _xaou_merge(Xaou_LangData.en, {
    ["lang.name"] = "English",
    ["lang.button"] = "Language: EN",
    ["lang.changed"] = "Language changed to English.",

    ["window.title.main"] = "Xaou009 Mod Center",
    ["window.title.item"] = "Item Spawner Menu",
    ["window.title.amount"] = "Select Amount",
    ["window.title.npc"] = "NPC Manager",
    ["window.devline"] = "Developer : Xaou009 & Busterfire",

    ["label.search"] = "Search",
    ["search.placeholder"] = "Search ID/Name",
    ["button.all"] = "All",
    ["button.refresh"] = "Refresh",
    ["button.close"] = "Close",
    ["button.cancel"] = "Cancel",
    ["button.view.list"] = "📋 List",
    ["button.view.grid"] = "▦ Grid",
    ["button.favorite.add"] = "☆ Favorite",
    ["button.favorite.remove"] = "⭐ Remove Fav",

    ["mode.item"] = "Items",
    ["mode.book"] = "Scriptures",
    ["mode.building"] = "Buildings",
    ["mode.npc"] = "NPC",
    ["mode.warp"] = "Warp",
    ["mode.developer"] = "Developer",

    ["cat.all"] = "All",
    ["cat.recent"] = "Recent",
    ["cat.favorite"] = "★ Favorite",
    ["cat.food"] = "Food",
    ["cat.weapon"] = "Weapons",
    ["cat.elixir"] = "Elixirs",
    ["cat.medicine"] = "Medicine",
    ["cat.talisman"] = "Talismans",
    ["cat.material"] = "Materials",
    ["cat.other"] = "Others",
    ["cat.magic"] = "Magic / Books",
    ["cat.special"] = "Special",

    ["status.item.line1"] = "Items : %s | Found : %s | Category : %s",
    ["status.item.line2"] = "Packs : %s | Extra : +%s | Duplicate : %s",
    ["status.keyword"] = "Keyword : %s",
    ["status.mode.prepare"] = "Mode : %s | Preparing system",
    ["status.mode.newarea"] = "This page is reserved for new features",
    ["status.npc.line1"] = "Mode : NPC | Category : %s | Target : %s",
    ["status.npc.no_target"] = "No NPC selected: open this menu from a character/NPC button",
    ["status.npc.help"] = "Choose a left category, then tap a command button on the right.",
    ["status.book.line1"] = "Scriptures : %s | Found : %s | Category : %s",
    ["status.book.help"] = "Tap a scripture to open the XML ItemCache reward page",

    ["amount.item_name"] = "Item Name",
    ["amount.tip"] = "Choose the amount to spawn",
    ["message.no_item_data"] = "No item data",
    ["message.item_not_found"] = "Item ID not found:\n%s",
    ["message.spawn_no_pos"] = "Could not find a place to drop the item",
    ["message.spawn_ok"] = "%s\nSpawned successfully. Amount: %s",
    ["message.spawn_fail_title"] = "Spawn Failed",
    ["message.spawn_ok_title"] = "Spawn Success",
    ["message.no_search_result"] = "No matching items found",
    ["message.book_no_result"] = "No matching scriptures found",

    ["main.btn.multiply"] = "Multiply ×2",
    ["main.tip.multiply"] = "Double the item stack amount",
    ["main.btn.youcui"] = "Demon Refine",
    ["main.tip.youcui"] = "Raise item quality by 1 level with guaranteed success",
    ["main.btn.lingcui"] = "Spirit Refine",
    ["main.tip.lingcui"] = "Spirit-refine the item once with guaranteed success",
    ["main.btn.tianjie"] = "Heavenly Tribulation 36",
    ["main.tip.tianjie"] = "Temper the magical treasure with 36 heavenly tribulation layers",
    ["main.tip.npc_mod"] = "Open the new NPC editor UI",
})

-- แปลข้อความไทยเดิมแบบไม่ต้องแก้ data list ทั้งหมด
Xaou_LangTextMapEN = Xaou_LangTextMapEN or {}
_xaou_merge(Xaou_LangTextMapEN, {
    ["ทั้งหมด"] = "All",
    ["ล่าสุด"] = "Recent",
    ["★ โปรด"] = "★ Favorite",
    ["อาหาร"] = "Food",
    ["อาวุธ"] = "Weapons",
    ["โอสถ"] = "Elixirs",
    ["ยารักษา"] = "Medicine",
    ["ยันต์"] = "Talismans",
    ["วัตถุดิบ"] = "Materials",
    ["อื่นๆ"] = "Others",
    ["อื่น"] = "Other",
    ["คัมภีร์"] = "Scriptures",
    ["ไอเทม"] = "Items",
    ["วาร์ป"] = "Warp",
    ["ผู้พัฒนา"] = "Developer",

    ["การตั่งค่าแบบด่วน"] = "Quick Settings",
    ["ตัวละคร"] = "Character",
    ["ต่อสู้"] = "Combat",
    ["งาน"] = "Work",
    ["ยกเลิกการบัพ"] = "Remove Buffs",
    ["เพิ่มเติม"] = "More",
    ["NPC สำนักอื่น"] = "Other Sect NPCs",
    ["เป้าหมาย NPC"] = "Target NPC",
    ["รายการคำสั่ง NPC"] = "NPC Commands",
    ["หน้า"] = "Page",
    ["กำลังเตรียมระบบ"] = "Preparing system",
    ["เปิดหมวด"] = "Open category",
    ["หน้าหมวด"] = "Category page",
    ["หมวด"] = "Category",
    ["หมวดก่อนหน้า"] = "Previous category",
    ["หมวดถัดไป"] = "Next category",
    ["หน้าหมวดคัมภีร์"] = "Scripture category page",
    ["หมวด NPC ก่อนหน้า"] = "Previous NPC category",
    ["หมวด NPC ถัดไป"] = "Next NPC category",
    ["หน้าหมวด NPC"] = "NPC category page",
    ["NPC ที่เลือกจากปุ่มบนตัวละคร"] = "NPC selected from the character button",
    ["หน้าคำสั่ง NPC ก่อนหน้า"] = "Previous NPC command page",
    ["หน้าคำสั่ง NPC"] = "NPC command page",
    ["หน้าคำสั่ง NPC ถัดไป"] = "Next NPC command page",
    ["กดเพื่อเปิด รับคัมภีร์"] = "Tap to open scripture reward",
    ["ไม่พบหน้าต่าง XaouItemWindow"] = "XaouItemWindow not found",
    ["บัฟ"] = "Buff",
    ["ปลดล็อก"] = "Unlock",
    ["หลายคำสั่ง"] = "Multiple commands",
    ["◀ กลับ"] = "◀ Back",
    ["◀ ก่อนหน้า"] = "◀ Previous",
    ["ถัดไป ▶"] = "Next ▶",
    ["◀ ย้อนกลับ"] = "◀ Previous",
    ["หน้าถัดไป ▶"] = "Next Page ▶",
    ["เปิดหน้า"] = "Open Page",
    ["คำสั่ง Lua"] = "Lua Command",
    ["ข้อความ"] = "Message",
    ["เปิดลิงก์"] = "Open Link",
    ["เมนู"] = "Menu",
    ["ปรับค่า"] = "Modify",
    ["ข้อมูล"] = "Info",

    ["1. ตั่งค่าด่วน"] = "1. Quick Settings",
    ["2. ตัวละคร"] = "2. Character",
    ["3. ต่อสู้"] = "3. Combat",
    ["5. ยกเลิกเอฟเฟกต์"] = "5. Remove Effects",
    ["6. เพิ่มเติม"] = "6. More",
    ["7. NPC สำนักอื่น"] = "7. Other Sect NPCs",
    ["1. โหมดตายยาก"] = "1. Survival Mode",
    ["2. ไม่ต้องกิน/ดื่ม/เหนื่อย"] = "2. No Food/Drink/Fatigue",
    ["3. พรสวรรค์สูงสุด"] = "3. Max Talent",
    ["4. หลอมอาวุธ/โอสถระดับเทพ"] = "4. Divine Craft/Alchemy",
    ["5. ปรุงโอสถได้ x100"] = "5. Alchemy Yield x100",
    ["6. พลังต่อสู้ขั้นสุด"] = "6. Ultimate Combat Power",
    ["7. โบนัสการฝึกฝน"] = "7. Cultivation Bonus",
    ["8. ความเร็วทำงานสูงสุด"] = "8. Max Work Speed",
    ["9. ◀ กลับ"] = "9. ◀ Back",
    ["🤝 เปิดใจ"] = "🤝 Open Heart",
    ["💞 เปิดใจ + ความชอบเต็ม"] = "💞 Open Heart + Max Favor",
    ["📋 ดูข้อมูล"] = "📋 View Info",
})


_xaou_merge(Xaou_LangTextMapEN, {
    ["A2 Arena p=ว่าง"] = "A2 Arena p=empty",
    ["Candidate API ที่เจอบน PlacesMgr:"] = "Candidate APIs found on PlacesMgr:",
    ["ERROR ดึงรายชื่อไม่ได้"] = "ERROR: Could not load list",
    ["GitHub ผู้พัฒนา"] = "Developer GitHub",
    ["Release ล่าสุด"] = "Latest Release",
    ["RpgArena แบบไม่ส่ง p"] = "RpgArena without p",
    ["RpgArena_YingTian ไม่ส่ง p"] = "RpgArena_YingTian without p",
    ["RpgQianKun ไม่ส่ง p"] = "RpgQianKun without p",
    ["RpgTower ไม่ส่ง p"] = "RpgTower without p",
    ["Unlock world/place ที่รู้จัก"] = "Unlock known worlds/places.",
    ["Unlock ทั้งหมด"] = "Unlock All",
    ["กดที่รายการเพื่อเปิด GitHub / Releases / Issues"] = "Tap an item to open GitHub / Releases / Issues",
    ["กรุณากดเลือก NPC ก่อนใช้คำสั่งนี้"] = "Please select an NPC before using this command.",
    ["กลับหน้า NPC"] = "Back to NPC",
    ["กลับหน้าไอเทม"] = "Back to Items",
    ["ขโมยของ NPC"] = "Steal NPC Items",
    ["ข้อมูล Candidate"] = "Candidate Info",
    ["ข้อมูล Tester"] = "Tester Info",
    ["ข้อมูลม็อด"] = "Mod Info",
    ["ความเร็วงานรวม +999"] = "Total Work Speed +999",
    ["ความเร็วทำงานสูงสุด"] = "Max Work Speed",
    ["ความเร็วในการเรียนรู้ +999"] = "Learning Speed +999",
    ["ค่าพื้นฐานของสภาวะจิต +999"] = "Base Mental State +999",
    ["ค้น Place"] = "Search Place",
    ["ค้นสถานที่"] = "Search Places",
    ["งาน"] = "Work",
    ["จักรวาลย่อส่วน"] = "Mini Universe",
    ["ชุบชีวิต NPC"] = "Revive NPC",
    ["ช่วยหา key จุดวาร์ปที่ปลอดภัย"] = "Help find safe warp keys.",
    ["ดู HomeKey/EmptyKey"] = "View HomeKey/EmptyKey.",
    ["ดู field ของ Place ตัวอย่างจาก runtime"] = "View example Place fields from runtime.",
    ["ดูข้อมูล Map / Key"] = "View Map / Key Info",
    ["ดูข้อมูล NPC / Key"] = "View NPC / Key Info",
    ["ดูรายชื่อ NPC candidates"] = "View NPC Candidate List",
    ["ด่วน"] = "Quick",
    ["ตรวจ PlacesMgr + candidate API"] = "Check PlacesMgr + candidate APIs.",
    ["ตอนดึก"] = "Late Night",
    ["ตอนเช้า"] = "Morning",
    ["ตอนเย็น"] = "Evening",
    ["ตัวละคร"] = "Character",
    ["ตั่งค่าด่วน"] = "Quick Settings",
    ["ตาย"] = "Dead",
    ["ต่อสู้"] = "Combat",
    ["ทดสอบจุดสำนัก"] = "Test Sect Point",
    ["ทะลวงขั้นทันที"] = "Breakthrough Now",
    ["ทำงานสำเร็จ"] = "Completed successfully",
    ["นี่คือหน้าสุดท้ายแล้ว"] = "This is the last page.",
    ["นี่คือหน้าแรกแล้ว"] = "This is the first page.",
    ["ปรับขนาดพื้นที่ค่ายกล +999"] = "Formation Area Size +999",
    ["ปรับขีดจำกัดจำนวนศิษย์ศรัทธาหลัก +999"] = "Core Believer Limit +999",
    ["ปรับความจุค่ายกล +999"] = "Formation Capacity +999",
    ["ปรับความมั่นคงของสภาวะจิต +999"] = "Mental State Stability +999",
    ["ปรับความเร็วการบินผจญภัย +999"] = "Adventure Flight Speed +999",
    ["ปรับความเร็วการสำรวจผจญภัย +999"] = "Adventure Exploration Speed +999",
    ["ปรับความเร็วการหลอมโอสถ +999"] = "Alchemy Speed +999",
    ["ปรับค่าทันสวรรค์สายเทพ +999"] = "Divine Heavenly Tribulation +999",
    ["ปรับค่าพลังบำเพ็ญแท้เพิ่มเติม +999"] = "Extra True Cultivation Power +999",
    ["ปรับค่าเรื่องการต่อสู้"] = "Combat Settings",
    ["ปรับค่าเรื่องการต่อสู้(สายเทพ)"] = "Divine Combat Settings",
    ["ปรับค่าเรื่องงาน สร้าง/โอสถ"] = "Work / Craft / Alchemy Settings",
    ["ปรับจำนวนคัมภีร์ลับสูงสุด +999"] = "Max Secret Scriptures +999",
    ["ปรับตัวคูณความแข็งแกร่งของโล่พลัง +999"] = "Shield Strength Multiplier +999",
    ["ปรับตัวคูณค่าสถานะผู้พิทักษ์เทพ +999"] = "Divine Guardian Stat Multiplier +999",
    ["ปรับตัวคูณชื่อเสียงการผจญภัย +999"] = "Adventure Prestige Multiplier +999",
    ["ปรับตัวคูณฟื้นฟูพลังวิญญาณของอาวุธวิเศษ +999"] = "Magic Treasure Soul Recovery Multiplier +999",
    ["ปรับตัวคูณเวลาคอขวดจากการผจญภัย +999"] = "Adventure Bottleneck Time Multiplier +999",
    ["ปรับตัวคูณโอกาสทะลวงคอขวด +999"] = "Breakthrough Chance Multiplier +999",
    ["ปรับตัวค่าความหยั่งรู้ +999"] = "Inspiration Value +999",
    ["ปรับประสิทธิภาพการดูดซับลมปราณ +999"] = "Qi Absorption Efficiency +999",
    ["ปรับผลกระทบของอารมณ์ต่อสภาวะจิต +999"] = "Mood Impact on Mental State +999",
    ["ปรับพลังวิญญาณสูงสุดของ NPC +999"] = "NPC Max Soul Power +999",
    ["ปรับพลังโจมตีของวิชา +999"] = "Spell Attack Power +999",
    ["ปรับระยะเวลาหน่วงก่อนคอขวดเริ่มนับถอยหลัง +999"] = "Bottleneck Countdown Delay +999",
    ["ปรับลมปราณพื้นฐาน +999"] = "Base Qi +999",
    ["ปรับอัตราการบริโภคน้ำ +999"] = "Water Consumption Rate +999",
    ["ปรับอัตราการบริโภคอาหาร +999"] = "Food Consumption Rate +999",
    ["ปรับอัตราการใช้ความบันเทิง +999"] = "Entertainment Consumption Rate +999",
    ["ปรับอัตราการใช้พลังงาน +999"] = "Energy Consumption Rate +999",
    ["ปรับอัตราการใช้พลังปราณแท้ +999"] = "True Qi Consumption Rate +999",
    ["ปรับอัตราการได้รับพลังปราณแท้ +999"] = "True Qi Gain Rate +999",
    ["ปรับอัตราสำเร็จพื้นฐานการสร้างศาสตราเทพ +999"] = "Divine Artifact Base Success Rate +999",
    ["ปรับแต่งความเร็วงานพื้นฐาน +999"] = "Base Work Speed +999",
    ["ปรับแต่งอัตราเพิ่มแต้มประสบการณ์ +999"] = "EXP Gain Rate +999",
    ["ปรับโบนัสการฟื้นฟูความบันเทิง +999"] = "Entertainment Recovery Bonus +999",
    ["ปรับโบนัสการฟื้นฟูจากการดื่มน้ำ +999"] = "Water Recovery Bonus +999",
    ["ปรับโบนัสการฟื้นฟูจากอาหาร +999"] = "Food Recovery Bonus +999",
    ["ปรับโบนัสการฟื้นฟูบาดแผลภายใน +999"] = "Internal Injury Recovery Bonus +999",
    ["ปรับโบนัสการฟื้นฟูพลังงาน +999"] = "Energy Recovery Bonus +999",
    ["ปรับโบนัสการฟื้นฟูพลังปราณแท้ +999"] = "True Qi Recovery Bonus +999",
    ["ปรับโบนัสการใช้พลังวิญญาณของวิชา +999"] = "Spell Soul Power Cost Bonus +999",
    ["ปรับโบนัสขีดจำกัดเตาหลอม +999"] = "Furnace Limit Bonus +999",
    ["ปรับโบนัสความเป็นเทพ +999"] = "Divinity Bonus +999",
    ["ปรับโบนัสความเร็วการดูดซับลมปราณ +999"] = "Qi Absorption Speed Bonus +999",
    ["ปรับโบนัสความเร็วการบำเพ็ญ +999"] = "Cultivation Speed Bonus +999",
    ["ปรับโบนัสความเร็วการบินระหว่างออกผจญภัย +999"] = "Adventure Flight Speed Bonus +999",
    ["ปรับโบนัสความเร็วการสร้างรากฐาน +999"] = "Foundation Building Speed Bonus +999",
    ["ปรับโบนัสความเร็วการหลอมอาวุธวิเศษ +999"] = "Magic Treasure Craft Speed Bonus +999",
    ["ปรับโบนัสความเร็วการหลอมโอสถ +999"] = "Alchemy Speed Bonus +999",
    ["ปรับโบนัสความเร็วโจมตีของอาวุธวิเศษ +999"] = "Magic Treasure Attack Speed Bonus +999",
    ["ปรับโบนัสความแข็งแกร่งโล่พลัง +999"] = "Shield Strength Bonus +999",
    ["ปรับโบนัสคุณภาพอาวุธวิเศษ +999"] = "Magic Treasure Quality Bonus +999",
    ["ปรับโบนัสคูลดาวน์ของวิชา +999"] = "Spell Cooldown Bonus +999",
    ["ปรับโบนัสบทลงทัณฑ์สวรรค์ +999"] = "Heavenly Tribulation Bonus +999",
    ["ปรับโบนัสปริมาณการผลิตโอสถ +999"] = "Alchemy Yield Bonus +999",
    ["ปรับโบนัสปริมาณการผลิตโอสถจากทักษะปรุงโอสถ +999"] = "Alchemy Skill Yield Bonus +999",
    ["ปรับโบนัสพลังวิญญาณสูงสุดอาวุธวิเศษ +999"] = "Magic Treasure Max Soul Power Bonus +999",
    ["ปรับโบนัสพลังอาวุธวิเศษ +999"] = "Magic Treasure Power Bonus +999",
    ["ปรับโบนัสฟื้นฟูพลังวิญญาณของอาวุธวิเศษ +999"] = "Magic Treasure Soul Recovery Bonus +999",
    ["ปรับโบนัสระดับขั้นอาวุธวิเศษ +999"] = "Magic Treasure Grade Bonus +999",
    ["ปรับโบนัสระยะกระเด็นของอาวุธวิเศษ +999"] = "Magic Treasure Knockback Range Bonus +999",
    ["ปรับโบนัสศักยภาพ +999"] = "Potential Bonus +999",
    ["ปรับโบนัสอัตราความสำเร็จในการหลอมโอสถ +999"] = "Alchemy Success Rate Bonus +999",
    ["ปรับโบนัสอัตราสำเร็จการหลอมอาวุธวิเศษ +999"] = "Magic Treasure Craft Success Bonus +999",
    ["ปรับโบนัสอัตราสำเร็จจากทักษะปรุงโอสถ +999"] = "Alchemy Skill Success Bonus +999",
    ["ปรุงโอสถได้ x100"] = "Alchemy Yield x100",
    ["ปลดล็อก/สถานะ"] = "Unlock / Status",
    ["ปลดล็อกวิชาบ่มเพาะ"] = "Unlock Cultivation Laws",
    ["ปลดล็อกสถานที่: "] = "Unlocked place: ",
    ["ปลดล็อกสถานที่ทั้งหมด"] = "Unlock All Places",
    ["ปลดล็อกสถานที่ทั้งหมดแล้ว"] = "All places unlocked.",
    ["ปลดล็อกสถานที่ไม่สำเร็จ"] = "Failed to unlock places.",
    ["ปิด"] = "Closed",
    ["ปิดโหมดตายยาก"] = "Turn Off Survival Mode",
    ["ปุ่มทดลอง อาจไม่มีผลในบางแมพ"] = "Experimental button; may not work on some maps.",
    ["พบทั้งหมด: "] = "Total found: ",
    ["พรสวรรค์สูงสุด"] = "Max Talent",
    ["พลังต่อสู้ขั้นสุด"] = "Ultimate Combat Power",
    ["พิกัดวาร์ป"] = "Warp Coordinates",
    ["ฟังก์ชันนี้จากรูปทดสอบใช้ได้แล้ว"] = "This worked in the screenshot test.",
    ["ยกเลิก"] = "Cancel",
    ["ยกเลิกเอฟเฟกต์"] = "Remove Effects",
    ["ยังหา key ตัวอย่างไม่ได้"] = "Could not find an example key yet.",
    ["ยังไม่พบคำสั่งย้ายตำแหน่งของเกมเวอร์ชันนี้"] = "No position-moving command found for this game version yet.",
    ["ยังไม่มี NPC เป้าหมาย"] = "No target NPC yet.",
    ["ยังไม่รู้จัก"] = "Unknown",
    ["ยังไม่ได้ใส่รหัสสถานที่"] = "No place code entered.",
    ["ยืดเวลาของทัณฑ์สวรรค์"] = "Extend Heavenly Tribulation Timer",
    ["ย้ายปุ่มทดลองไปหน้า 2"] = "Move test buttons to page 2.",
    ["ระบบ"] = "System",
    ["ระบบวาร์ป"] = "Warp System",
    ["ระบบวาร์ป / แผนที่"] = "Warp / Map System",
    ["ระบบสถานที่"] = "Place System",
    ["ระบบแผนที่"] = "Map System",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 1"] = "Get 20 Scriptures - Set 1",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 10"] = "Get 20 Scriptures - Set 10",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 11"] = "Get 20 Scriptures - Set 11",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 12"] = "Get 20 Scriptures - Set 12",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 13"] = "Get 20 Scriptures - Set 13",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 14"] = "Get 20 Scriptures - Set 14",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 15"] = "Get 20 Scriptures - Set 15",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 16"] = "Get 20 Scriptures - Set 16",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 17"] = "Get 20 Scriptures - Set 17",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 18"] = "Get 20 Scriptures - Set 18",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 19"] = "Get 20 Scriptures - Set 19",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 2"] = "Get 20 Scriptures - Set 2",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 20"] = "Get 20 Scriptures - Set 20",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 21"] = "Get 20 Scriptures - Set 21",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 22"] = "Get 20 Scriptures - Set 22",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 23"] = "Get 20 Scriptures - Set 23",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 24"] = "Get 20 Scriptures - Set 24",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 25"] = "Get 20 Scriptures - Set 25",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 26"] = "Get 20 Scriptures - Set 26",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 27"] = "Get 20 Scriptures - Set 27",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 28"] = "Get 20 Scriptures - Set 28",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 29"] = "Get 20 Scriptures - Set 29",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 3"] = "Get 20 Scriptures - Set 3",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 30"] = "Get 20 Scriptures - Set 30",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 4"] = "Get 20 Scriptures - Set 4",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 5"] = "Get 20 Scriptures - Set 5",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 6"] = "Get 20 Scriptures - Set 6",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 7"] = "Get 20 Scriptures - Set 7",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 8"] = "Get 20 Scriptures - Set 8",
    ["รับคัมภีร์ 20 เล่ม ชุดที่ 9"] = "Get 20 Scriptures - Set 9",
    ["รายชื่อ Settings ถัดไป"] = "Next Settings List",
    ["รายชื่อจาก PlacesMgr"] = "List from PlacesMgr",
    ["รายชื่อสถานที่ Settings"] = "Settings Place List",
    ["รายชื่อสถานที่จาก Settings"] = "Place List from Settings",
    ["รายละเอียด Place"] = "Place Details",
    ["รีเซ็ตกิน/ดื่ม/เหนื่อย"] = "Reset Food/Drink/Fatigue",
    ["รีเซ็ตความเร็วงาน"] = "Reset Work Speed",
    ["รีเซ็ตพรสวรรค์สูงสุด"] = "Reset Max Talent",
    ["รีเซ็ตพลังต่อสู้"] = "Reset Combat Power",
    ["ลองล้างฝุ่นแล้ว แต่ไม่พบรายการฝุ่นในแมพนี้"] = "Tried clearing dust, but no dust list was found on this map.",
    ["ลองเรียก API เดินทางทีละชุด"] = "Try travel APIs one set at a time.",
    ["ล้างฝุ่น / สิ่งกีดขวาง"] = "Clear Dust / Obstacles",
    ["ล้างฝุ่น/สิ่งกีดขวางแล้ว จำนวนประมาณ "] = "Cleared dust/obstacles. Estimated count: ",
    ["ล้างฝุ่นแผนที่ไม่สำเร็จ"] = "Failed to clear map dust.",
    ["วาร์ป NPC กลับสำนัก"] = "Warp NPC Back to Sect",
    ["วิชาระดับสวรรค์ สุ่ม 20 ครั้ง"] = "Random Heaven Laws x20",
    ["วิชาสายหลักทั้งหมด"] = "All Main Laws",
    ["วิเคราะห์พิกัด"] = "Analyze Coordinates",
    ["ศูนย์ม็อด Xaou009"] = "Xaou009 Mod Center",
    ["สถานที่สำนัก"] = "Sect Places",
    ["สถานที่สำนัก / School Places"] = "Sect / School Places",
    ["สถานที่ใกล้ X/Y"] = "Places Near X/Y",
    ["สรุประบบวาร์ป"] = "Warp System Summary",
    ["สรุปสิ่งที่ทำได้/ยังต้องหา"] = "Summary of what works / what still needs research.",
    ["สร้างด่วน ON/OFF"] = "Quick Build ON/OFF",
    ["สร้างฟรี ON/OFF"] = "Free Build ON/OFF",
    ["สัตว์อสูร"] = "Beasts",
    ["สัตว์อสูร / ศัตรู"] = "Beasts / Enemies",
    ["สำนัก"] = "Sect",
    ["สุ่มเรียกอสูร"] = "Random Beast Summon",
    ["สแกน API PlacesMgr"] = "Scan PlacesMgr API",
    ["สแกน Runtime Manager"] = "Scan Runtime Manager",
    ["หนังสือคัมภีร์"] = "Scripture Books",
    ["หน้า 1/3 ใช้งานจริง: วาร์ป NPC / เปิดหมอก / ค้นสถานที่"] = "Page 1/3 Main Tools: Warp NPC / Reveal Map / Search Places",
    ["หน้า 2/3 Debug: ใช้ตอนแกะ API เท่านั้น"] = "Page 2/3 Debug: API research only",
    ["หน้า 3/7 v4.0: ชุดทดสอบหลัก กดทีละปุ่ม ถ้าค้างให้จำปุ่มที่กด"] = "Page 3/7 v4.0: Main test set. Tap one by one; if it freezes, remember the button.",
    ["หน้า 4/7 v4.0: ชุด B ลองค่า p แปลก ๆ / สลับ world"] = "Page 4/7 v4.0: Set B, test unusual p values / switch worlds",
    ["หน้า 5/7 v4.0: บังคับเลือก NPC candidate คนละตัว"] = "Page 5/7 v4.0: Force different NPC candidates",
    ["หน้า 6/7 v4.0: ลองเรียกตัวช่วยก่อนเข้า"] = "Page 6/7 v4.0: Try helper calls before entering",
    ["หน้า 7/7 v4.0: ปุ่มเก่าเก็บไว้เทียบผล"] = "Page 7/7 v4.0: Old buttons kept for comparison",
    ["หน้าถัดไป ▶"] = "Next Page ▶",
    ["หน้าผู้พัฒนา"] = "Developer Page",
    ["หลอมอาวุธ/โอสถระดับเทพ"] = "Divine Craft / Alchemy",
    ["หา Enter/Visit/Goto/Travel โดยไม่เรียกจริง"] = "Find Enter/Visit/Goto/Travel without calling them.",
    ["หา Instance RPGMapMgr"] = "Find RPGMapMgr Instance",
    ["หา manager ที่อาจสั่ง Travel/Enter"] = "Find managers that may trigger Travel/Enter.",
    ["หาจุดเกิด/จุดกลางสำนักไม่เจอ"] = "Could not find spawn point / sect center.",
    ["อธิบายความต่าง X/Y กับ GridKey"] = "Explain the difference between X/Y and GridKey.",
    ["อยู่"] = "Active",
    ["ออกไปแล้ว"] = "Left",
    ["อุณหภูมิขีดจำกัดต่ำสุดขั้นสุด +999"] = "Extreme Low Temperature Limit +999",
    ["อุณหภูมิขีดจำกัดสูงสุดขั้นสุด +999"] = "Extreme High Temperature Limit +999",
    ["อ่าน Key ของ NPC ไม่ได้"] = "Could not read NPC Key.",
    ["อ่านข้อมูล"] = "Read Info",
    ["อ่านรายชื่อ Place จาก Runtime ของเกมโดยตรง"] = "Read Place list directly from game runtime.",
    ["เช็ก PlacesMgr"] = "Check PlacesMgr",
    ["เดินทาง/เข้า Place"] = "Travel / Enter Place",
    ["เปลียนเวลาของเกม"] = "Change Game Time",
    ["เปลี่ยนเป็นปีเก็บเกี่ยวอุดมสมบูรณ์"] = "Set Year to Bountiful Harvest",
    ["เปิด"] = "Open",
    ["เปิด UI/เลือก Place"] = "Open UI / Select Place",
    ["เปิดหมอกแผนที่"] = "Reveal Map Fog",
    ["เปิดหมอกแผนที่แล้ว"] = "Map fog revealed.",
    ["เปิดหมอกแผนที่ไม่สำเร็จ"] = "Failed to reveal map fog.",
    ["เปิดเมนูเสกของ"] = "Open Item Spawner",
    ["เปิดเลือก NPC v3.7"] = "Open NPC Selector v3.7",
    ["เปิดเลือก NPC เกม"] = "Open Game NPC Selector",
    ["เพิ่ม อาวุธวิเศษ 5 ช่อง"] = "Magic Treasure Slots +5",
    ["เพิ่มการฟื้นฟูร่างกาย +999"] = "Body Recovery +999",
    ["เพิ่มความเร็วในการเดิน +999"] = "Move Speed +999",
    ["เพิ่มค่าความเร็วในการบินของอาวุธพิเศษ +999"] = "Magic Treasure Flight Speed +999",
    ["เพิ่มค่าต้านทานการกระเด็นจากอาวุธวิเศษ +999"] = "Magic Treasure Knockback Resistance +999",
    ["เพิ่มค่าสถานะทั้ง 5"] = "Boost All 5 Attributes",
    ["เพิ่มค่าอารมณ์พื้นฐาน +999"] = "Base Mood +999",
    ["เพิ่มค่าอำพรางซ่อนเร้นตัว +999"] = "Stealth / Concealment +999",
    ["เพิ่มค่าโบนัสความเร็วการเลี้ยวของอาวุธวิเศษ +999"] = "Magic Treasure Turn Speed Bonus +999",
    ["เพิ่มค่าโบนัสจำนวนผู้ศรัทธาเป็นพลัง +999"] = "Believer-to-Power Bonus +999",
    ["เพิ่มจำนวนผู้ศรัทธาษ +9999"] = "Believers +9999",
    ["เพิ่มต้านธาตุทั้งห้า +999"] = "Five Elements Resistance +999",
    ["เพิ่มทนต่อความเจ็บปวด +999"] = "Pain Tolerance +999",
    ["เพิ่มพลัง โจมตีอาวุธวิเศษ +999"] = "Magic Treasure Attack +999",
    ["เพิ่มพลังเวท +999"] = "Spell Power +999",
    ["เพิ่มระยะมองเห็น +999"] = "Vision Range +999",
    ["เพิ่มอายุขัย +9999"] = "Lifespan +9999",
    ["เพิ่มอุณหภูมิต่ำสุดที่ทนได้ +999"] = "Minimum Temperature Tolerance +999",
    ["เพิ่มอุณหภูมิสูงสุดที่ทนได้ +999"] = "Maximum Temperature Tolerance +999",
    ["เพิ่มเกราะโล่ +999"] = "Shield Armor +999",
    ["เพิ่มเติม"] = "More",
    ["เพิ่มเลือด สูงสุด +999"] = "Max HP +999",
    ["เพิ่มโบนัสความยาวหางอาวุธวิเศษ +999"] = "Magic Treasure Trail Length Bonus +999",
    ["เพิ่มโบนัสระยะเวลาคาถา +999"] = "Spell Duration Bonus +999",
    ["เพิ่มโอกาสหลบ +999"] = "Dodge Chance +999",
    ["เพิ่มโอกาสโจมตี +999"] = "Hit Chance +999",
    ["เมนูคัมภีร์"] = "Scripture Menu",
    ["เมนูปรับเวลาเดิม"] = "Original Time Menu",
    ["เมนูหลัก"] = "Main Menu",
    ["เมนูอากาศเดิม"] = "Original Weather Menu",
    ["เมนูอาคาร"] = "Building Menu",
    ["เรียกอสูร : นกฟีนิกซ์เพลิง"] = "Summon Beast: Fire Phoenix",
    ["เรียกอสูร : มังกรฟ้า"] = "Summon Beast: Azure Dragon",
    ["เรียกอสูร : มังกรไฟ"] = "Summon Beast: Fire Dragon",
    ["เรียกโจรป่า"] = "Summon Bandits",
    ["เลื่อนกล้องไปยังตำแหน่ง NPC จาก NpcKey"] = "Move camera to NPC position from NpcKey.",
    ["เลื่อนหน้ารายชื่อสถานที่"] = "Go to next Place-list page.",
    ["เลื่อนไปดูตำแหน่ง NPC แล้ว"] = "Moved view to NPC position.",
    ["เวลา / ฤดูกาล / อากาศ"] = "Time / Season / Weather",
    ["แจ้งปัญหา"] = "Report Issue",
    ["แสดง Key ของ NPC เป้าหมาย"] = "Show the target NPC key.",
    ["แสดง Place ที่ผูกกับ School"] = "Show Places linked to Schools.",
    ["แสดง key รอบสำนัก"] = "Show Keys Around Sect",
    ["แสดงค่า Map.Size / HomeKey / CenterKey"] = "Show Map.Size / HomeKey / CenterKey.",
    ["แสดงรายชื่อ Place จาก Settings"] = "Show Place list from Settings.",
    ["โจรป่าระดับสูง"] = "Summon Elite Bandits",
    ["โบนัสการฝึกฝน"] = "Cultivation Bonus",
    ["โบนัสการได้รับศรัทธาของอาณาจักรเทพ +999"] = "God Realm Faith Gain Bonus +999",
    ["โบนัสอุปกรณ์ต่ออัตราแปลงโล่ +999"] = "Equipment Shield Conversion Bonus +999",
    ["โฟกัส NPC ที่เลือก"] = "Focus Selected NPC",
    ["โลก/เวลา"] = "World / Time",
    ["โหมด : ผู้พัฒนา | ลิงก์และข้อมูลม็อด"] = "Mode: Developer | Mod links and info",
    ["โหมดตายยาก"] = "Survival Mode",
    ["โอกาสการเกิดฝันดี+1"] = "Good Dream Chance +1",
    ["โอกาสการเกิดฝันร้าย+0.1"] = "Nightmare Chance +0.1",
    ["ใช้ NPC เป้าหมายล่าสุด หรือ me ถ้าไม่มี"] = "Use the latest target NPC, or me if none.",
    ["ใช้ UnLockAll ถ้ามือถือรองรับ"] = "Use UnLockAll if mobile supports it.",
    ["ใช้ข้อความในช่องค้นหาเพื่อค้น Place"] = "Use the search box to find a Place.",
    ["ไม่ต้องกิน/ดื่ม/เหนื่อย"] = "No Food/Drink/Fatigue",
    ["ไม่พบ GSchool.JianghuNpcs"] = "GSchool.JianghuNpcs not found",
    ["ไม่พบ NPC สำนักอื่น"] = "No other sect NPCs found",
    ["ไม่พบ PlacesMgr"] = "PlacesMgr not found",
    ["ไม่พบ candidate method"] = "No candidate method found",
    ["ไม่พบข้อมูล JianghuNpcs"] = "No JianghuNpcs data found",
    ["ไม่พบฟังก์ชัน DebugTravelTesterInfo"] = "Function DebugTravelTesterInfo not found",
    ["ไม่มีจุดวาร์ป"] = "No warp point",
    ["ไม่มีเป้าหมาย NPC"] = "No target NPC",
    ["ไม่เรียกวาร์ป แค่ดู NPC/Target"] = "No warp call; only inspect NPC/Target.",
    ["▶ Debug เก่า"] = "▶ Old Debug",
    ["▶ NPC Source"] = "▶ NPC Source",
    ["▶ Pre Action"] = "▶ Pre Action",
    ["▶ ชุด B"] = "▶ Set B",
    ["▶ หน้า Debug"] = "▶ Debug Page",
    ["▶ หน้า Tester"] = "▶ Tester Page",
    ["▶ หน้าแรก"] = "▶ First Page",
    ["◀ Pre Action"] = "◀ Pre Action",
    ["◀ กลับหน้าไอเทม"] = "◀ Back to Items",
    ["◀ ชุด A"] = "◀ Set A",
    ["◀ ชุด B"] = "◀ Set B",
    ["◀ หน้า Debug"] = "◀ Debug Page",
    ["◀ หน้าแรกแล้ว"] = "◀ First page",
    ["◀ หน้าใช้งานจริง"] = "◀ Main Tools",
    ["☀ เที่ยงวัน"] = "☀ Noon",
    ["🌍 ระบบวาร์ป / แผนที่"] = "🌍 Warp / Map System",
})

function Xaou_GetLang()
    if Xaou_LangSystem == nil or Xaou_LangSystem.current == nil then return "th" end
    local lang = tostring(Xaou_LangSystem.current)
    if lang ~= "en" then lang = "th" end
    return lang
end

function Xaou_SetLang(lang)
    lang = tostring(lang or "th")
    if lang ~= "en" then lang = "th" end
    Xaou_LangSystem.current = lang
    return lang
end

function Xaou_T(key, fallback)
    local lang = Xaou_GetLang()
    local data = Xaou_LangData and Xaou_LangData[lang]
    if type(data) == "table" and data[key] ~= nil then return tostring(data[key]) end
    local th = Xaou_LangData and Xaou_LangData.th
    if type(th) == "table" and th[key] ~= nil then return tostring(th[key]) end
    if fallback ~= nil then return tostring(fallback) end
    return tostring(key or "")
end

function Xaou_AutoText(text)
    text = tostring(text or "")
    if Xaou_GetLang() ~= "en" then return text end
    if Xaou_LangTextMapEN ~= nil and Xaou_LangTextMapEN[text] ~= nil then
        return tostring(Xaou_LangTextMapEN[text])
    end

    -- รองรับเมนูที่มีเลขนำหน้า เช่น "1. ข้อความ"
    local n, rest = string.match(text, "^(%d+)%.%s*(.+)$")
    if n ~= nil and rest ~= nil and Xaou_LangTextMapEN ~= nil then
        local cleaned = tostring(rest)
        if Xaou_LangTextMapEN[cleaned] ~= nil then
            return tostring(n) .. ". " .. tostring(Xaou_LangTextMapEN[cleaned])
        end
    end

    -- Pattern พิเศษสำหรับหน้าที่มีตัวเลข
    local p = string.match(text, "^ปรับการต่อสู้ %((หน้า %d+)%)$")
    if p ~= nil then
        local num = string.match(p, "(%d+)") or ""
        return "Combat Settings (Page " .. tostring(num) .. ")"
    end
    p = string.match(text, "^ปรับค่าเรื่องงาน สร้าง/โอสถ %((หน้า %d+)%)$")
    if p ~= nil then
        local num = string.match(p, "(%d+)") or ""
        return "Work / Craft / Alchemy Settings (Page " .. tostring(num) .. ")"
    end
    p = string.match(text, "^ปรับค่าเรื่องการต่อสู้%(สายเทพ (%d+)%)$")
    if p ~= nil then
        return "Divine Combat Settings (Page " .. tostring(p) .. ")"
    end

    local cur, maxp = string.match(text, "^หน้า%s+(%d+)%/(%d+)%s+|%s+ถัดไป ▶$")
    if cur ~= nil then return "Page " .. cur .. "/" .. maxp .. " | Next ▶" end
    cur, maxp = string.match(text, "^หน้า%s+(%d+)%/(%d+)%s+|%s+สุดท้ายแล้ว$")
    if cur ~= nil then return "Page " .. cur .. "/" .. maxp .. " | Last Page" end

    return text
end

function Xaou_ToggleLang()
    if Xaou_GetLang() == "th" then Xaou_SetLang("en") else Xaou_SetLang("th") end
    pcall(function()
        if XaouItemWindow ~= nil and XaouItemWindow.RefreshLanguageStaticTexts ~= nil then
            XaouItemWindow:RefreshLanguageStaticTexts()
        end
        if XaouItemWindow ~= nil and XaouItemWindow.RefreshList ~= nil then
            XaouItemWindow:RefreshList()
        end
    end)
    pcall(function()
        if Xaou_Show ~= nil then Xaou_Show(Xaou_T("lang.changed", "Language changed"), "Xaou Language") end
    end)
    return Xaou_GetLang()
end



_xaou_merge(Xaou_LangData.th, {
    ["window.size.button"] = "ขนาด",
    ["window.size.normal"] = "ปกติ",
    ["window.size.small"] = "เล็ก",
    ["window.size.changed.normal"] = "เปลี่ยนขนาดหน้าต่างเป็นแบบปกติแล้ว",
    ["window.size.changed.small"] = "เปลี่ยนขนาดหน้าต่างเป็นแบบเล็กแล้ว",
})

_xaou_merge(Xaou_LangData.en, {
    ["window.size.button"] = "Size",
    ["window.size.normal"] = "Normal",
    ["window.size.small"] = "Small",
    ["window.size.changed.normal"] = "Window size changed to Normal.",
    ["window.size.changed.small"] = "Window size changed to Small.",
})

_xaou_merge(Xaou_LangTextMapEN, {
    ["ขนาด"] = "Size",
    ["ปกติ"] = "Normal",
    ["เล็ก"] = "Small",
    ["เปลี่ยนขนาดหน้าต่างเป็นแบบปกติแล้ว"] = "Window size changed to Normal.",
    ["เปลี่ยนขนาดหน้าต่างเป็นแบบเล็กแล้ว"] = "Window size changed to Small.",
})

Xaou_WindowSizeSystem = Xaou_WindowSizeSystem or {}
if Xaou_WindowSizeSystem.small == nil then Xaou_WindowSizeSystem.small = false end
Xaou_WindowSizeSystem.normalScale = Xaou_WindowSizeSystem.normalScale or 1.00
Xaou_WindowSizeSystem.smallScale = Xaou_WindowSizeSystem.smallScale or 0.88

function Xaou_IsSmallWindow()
    return Xaou_WindowSizeSystem ~= nil and Xaou_WindowSizeSystem.small == true
end

function Xaou_GetWindowScale()
    if Xaou_IsSmallWindow() then
        return tonumber(Xaou_WindowSizeSystem.smallScale or 0.88) or 0.88
    end
    return tonumber(Xaou_WindowSizeSystem.normalScale or 1.00) or 1.00
end

-- คืนค่าขนาดฐานเดิมไว้ก่อน แล้วใช้ scale ย่อทั้งหน้าต่างแทน
-- วิธีนี้ไม่ทำให้ตำแหน่งปุ่ม/มือถือเพี้ยน และไม่ตัดปุ่มที่อยู่นอกกรอบเดิม
function Xaou_GetWindowSize(defaultW, defaultH)
    return tonumber(defaultW or 980) or 980, tonumber(defaultH or 620) or 620
end

function Xaou_GetWindowEffectiveSize(defaultW, defaultH)
    local w, h = Xaou_GetWindowSize(defaultW, defaultH)
    local s = Xaou_GetWindowScale()
    return math.floor(w * s), math.floor(h * s)
end

function Xaou_GetWindowSizeName()
    if Xaou_IsSmallWindow() then
        return Xaou_T("window.size.small", "เล็ก")
    end
    return Xaou_T("window.size.normal", "ปกติ")
end

function Xaou_WindowSizeButtonText()
    return Xaou_T("window.size.button", "ขนาด") .. ": " .. Xaou_GetWindowSizeName()
end

function Xaou_ToggleWindowSize()
    Xaou_WindowSizeSystem.small = not Xaou_IsSmallWindow()
    return Xaou_WindowSizeSystem.small
end

function Xaou_ApplyWindowSizeTo(wnd, defaultW, defaultH)
    if wnd == nil then return end
    local w, h = Xaou_GetWindowSize(defaultW or wnd.sx or 980, defaultH or wnd.sy or 620)
    local scale = Xaou_GetWindowScale()

    pcall(function()
        wnd.sx = w
        wnd.sy = h
    end)
    pcall(function()
        if wnd.SetSize ~= nil then wnd:SetSize(w, h) end
    end)

    -- ย่อ/ขยายทั้งหน้าต่างแบบปลอดภัย ใช้ pcall กันบางเครื่องไม่มี method นี้
    -- ให้ความสำคัญกับ wnd.window ก่อน เพื่อไม่ให้บางเครื่องโดน scale ซ้อนสองชั้น
    local applied = false
    pcall(function()
        if wnd.window ~= nil and wnd.window.SetScale ~= nil then
            wnd.window:SetScale(scale, scale)
            applied = true
        end
    end)
    pcall(function()
        if wnd.window ~= nil and applied == false then
            wnd.window.scaleX = scale
            wnd.window.scaleY = scale
            applied = true
        end
    end)
    if applied == false then
        pcall(function()
            if wnd.SetScale ~= nil then
                wnd:SetScale(scale, scale)
                applied = true
            end
        end)
    end
    if applied == false then
        pcall(function()
            wnd.scaleX = scale
            wnd.scaleY = scale
        end)
    end
end
