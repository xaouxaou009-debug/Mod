

if Xaou_RegisterItemPack ~= nil then
    Xaou_RegisterItemPack("API Example Pack", {
        { id = "Item_FengEgg", count = 1, cat = "special" },
    })
else
    Xaou_ItemPacks = Xaou_ItemPacks or {}
    table.insert(Xaou_ItemPacks, {
        name = "API Example Pack",
        items = {
            { id = "Item_FengEgg", count = 1, cat = "special" },
        }
    })
end
