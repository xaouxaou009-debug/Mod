--苍龙寒星
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("Modifier_CangLongHanXing")

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  if npc.IsDisciple then --仅外门弟子装备有效。
    npc:RemoveModifier("Modifier_CangLongHanXing")
  end
  npc:SetSpecialFlag(CS.XiaWorld.g_emNpcSpecailFlag.FLAG_GODMODE)
end

--modifier step
function tbModifier:Step(modifier, npc, dt)

end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
	npc:RemoveSpecialFlag(CS.XiaWorld.g_emNpcSpecailFlag.FLAG_GODMODE)
end

--获取存档数据
function tbModifier:OnGetSaveData()
	return nil
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

--注册事件。
function tbModifier:Register()
  
end

--反注册事件。
function tbModifier:Unregister()

end