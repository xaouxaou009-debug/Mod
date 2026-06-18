local Mod = GameMain:GetMod("Xiu_Gai_Qi_761152306")

Mod.QuickBuildEnable = false
Mod.FreeBuildEnable = false
Mod.FreeBuildBackup = {}

function Mod:ToggleQuickBuild()
    self.QuickBuildEnable = not self.QuickBuildEnable

    if CS.GameMain.Instance ~= nil then
        CS.GameMain.Instance.QuickBuild = self.QuickBuildEnable
    end

    if self.QuickBuildEnable then
        print("[BuildManager] QuickBuild ON")
    else
        print("[BuildManager] QuickBuild OFF")
    end
end

function Mod:ToggleFreeBuild()
    if self.FreeBuildEnable then
        self:DisableFreeBuild()
    else
        self:EnableFreeBuild()
    end
end

function Mod:EnableFreeBuild()
    local map = CS.XiaWorld.ThingMgr.s_mapThingDefs
    if map == nil then return end

    local buildings = map[4] -- 4 = Building
    if buildings == nil then return end

    local e = buildings:GetEnumerator()

    while e:MoveNext() do
        local def = e.Current.Value

        if def ~= nil and def.Building ~= nil and def.Building.BeMade ~= nil then
            local made = def.Building.BeMade
            local name = def.Name

            if self.FreeBuildBackup[name] == nil then
                self.FreeBuildBackup[name] = {
                    CostStuffCount = made.CostStuffCount,
                    CostStuffScale = made.CostStuffScale,
                    CostItems = made.CostItems
                }
            end

            made.CostStuffCount = 0
            made.CostStuffScale = 0
            made.CostItems = nil
        end
    end

    self.FreeBuildEnable = true
    print("[BuildManager] FreeBuild ON")
end

function Mod:DisableFreeBuild()
    local map = CS.XiaWorld.ThingMgr.s_mapThingDefs
    if map == nil then return end

    local buildings = map[4]
    if buildings == nil then return end

    local e = buildings:GetEnumerator()

    while e:MoveNext() do
        local def = e.Current.Value

        if def ~= nil and def.Building ~= nil and def.Building.BeMade ~= nil then
            local name = def.Name
            local old = self.FreeBuildBackup[name]

            if old ~= nil then
                local made = def.Building.BeMade
                made.CostStuffCount = old.CostStuffCount
                made.CostStuffScale = old.CostStuffScale
                made.CostItems = old.CostItems
            end
        end
    end

    self.FreeBuildEnable = false
    print("[BuildManager] FreeBuild OFF")
end