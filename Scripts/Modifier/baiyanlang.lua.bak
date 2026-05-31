--白眼狼丹
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_baiyanlang")
local ZhiYaoZhuo = GameMain:GetMod("ZhiYaoZhuo")


--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  local tbInfo = {
		KC = "Item",
		Line = {StartObj = npc},
		HeadMsg = "请选择要策反的白眼狼。。。啊不对，秘宝",
		Apply = 
			function(_, map, k, tbMode) 
				local t = tbMode:GetThing(g_emThingType.Item, k, map)
        t:BindItem2Npc(npc)
			end,
		Check = 
			function(_, map, k, tbMode) 
				local t = tbMode:GetThing(g_emThingType.Item, k, map)
				return t.IsMiBao
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
	return nil
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

