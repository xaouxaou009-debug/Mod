--阴阳双鱼
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_yinyangshuangyu")
local ZhiYaoZhuo = GameMain:GetMod("ZhiYaoZhuo")

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  local tbInfo = {
		KC = "Npc",
		Line = {StartObj = npc},
		HeadMsg = "请选择要复活的一个NPC",
		Apply = 
			function(_, map, k, tbMode)
        xlua.private_accessible(CS.XiaWorld.Npc)
        xlua.private_accessible(CS.XiaWorld.NpcBodyData)
				local t = tbMode:GetThing(g_emThingType.Npc, k, map)
        t.HealthState = CS.XiaWorld.g_emNpcHealthState.Normal
        t.IsCorpse = false
        t.PropertyMgr.BodyData:RemoveAllDamange()
        t.PropertyMgr.BodyData:BuildBody()
        t.PropertyMgr.BodyData.HealthValue = 300
        t.PropertyMgr.BodyData.Dead = false
        t.PropertyMgr.BodyData.Dying = false
			end,
		Check = 
			function(_, map, k, tbMode) 
				local t = tbMode:GetThing(g_emThingType.Npc, k, map)
				return t.ThingType == g_emThingType.Npc
			end,
	}

	world:EnterUILuaMode("TableCtrl", tbInfo)
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
	return nil;
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

