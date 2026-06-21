--蔡徐坤丹
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_caixukun")

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  for name,data in pairs(CS.XiaWorld.PlacesMgr.Instance.Places) do
    if data.School > 0 and data.School < 1000000 then
      local schoolPower = CS.XiaWorld.SchoolGlobleMgr.Instance:GetSchoolPower(data.School)
      if schoolPower then
        local add = false
        if schoolPower.Suzerain == -1 then
          schoolPower.Suzerain = 0
          add = true
        end
        if schoolPower.State == CS.XiaWorld.g_emSchoolState.Close then
          schoolPower.State = CS.XiaWorld.g_emSchoolState.Normal
          add = true
        end
        if schoolPower.LockPlace > 0 then
          schoolPower.LockPlace = 0
          add = true
        end
        if add then
          schoolPower.Power = schoolPower.Power + (modifier.Scale - 1) * 10000
        end
      end
    end
  end
end

--modifier step
function tbModifier:Step(modifier, npc, dt)

end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
	
end

--获取存档数据
function tbModifier:OnGetSaveData()
	return nil
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

