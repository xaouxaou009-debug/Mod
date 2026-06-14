--五小药的基础属性修正脚本。由于更新以后是按百分比的，所以会造成低资质的小人无法提升，这个脚本则会将五围的加成以基础值的方式再加一次。
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_fivebasedan")

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  xlua.private_accessible(CS.XiaWorld.Modifier.ModifierBase)
  modifier.Version = 0
  modifier:ModifyBaseFive(npc.PropertyMgr, modifier.Scale)
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

