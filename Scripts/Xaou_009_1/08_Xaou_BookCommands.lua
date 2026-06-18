-- ============================================================
-- XAOU BOOK COMMANDS
-- ไฟล์นี้แยกไว้เผื่อเพิ่มหมวด/คำสั่งพิเศษของคัมภีร์ภายหลัง
-- ============================================================

function Xaou_GetBookCategories()
    return Xaou_BookCategories or {"ทั้งหมด"}
end

function Xaou_GetBookCommands(category, keyword)
    return Xaou_GetBookList(category, keyword)
end
