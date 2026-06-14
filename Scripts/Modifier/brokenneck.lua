--缩骨丹
local tbTable = GameMain:GetMod("_ModifierScript");
local tbModifier = tbTable:GetModifier("modifier_brokenneck");

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  --神修吃了也能突破心境层次。
  if npc.PropertyMgr.Practice and npc.PropertyMgr.Practice.GodPracticeData then
    local god = npc.PropertyMgr.Practice.GodPracticeData
    god:MindStateLevelLevelUp()
  end
  if npc.PropertyMgr.Practice and npc.PropertyMgr.Practice.CurNeck then
    local neck = npc.PropertyMgr.Practice.CurNeck
    if neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.Gold and neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.Thunder and neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.God then
       npc.PropertyMgr.Practice:AddResource(CS.XiaWorld.g_emPracticeResourceType.Understand, 500);
       npc.LuaHelper:NeckBroken();
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
	return nil;
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

