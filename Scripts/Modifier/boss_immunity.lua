--物理免疫
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_boss_immunity")


--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  --很简单，只要灵气不是零，则每帧都移除所有的物理伤害。
  if npc.LingV > 0 then
    npc.PropertyMgr.BodyData:RemoveAllDamange()
    if npc.MaxAge < 99999 then --保持寿元最大。
      npc.PropertyMgr:AddMaxAge(99999 - npc.MaxAge)
    end
    npc.PropertyMgr.Age = 18 --永远的18岁。
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
	
end

--获取存档数据
function tbModifier:OnGetSaveData()
	
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  tbData = tbData or {}
end

