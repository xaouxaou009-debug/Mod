--重力丹
local tbTable = GameMain:GetMod("_ModifierScript");
local tbModifier = tbTable:GetModifier("modifier_zhongli");

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  --满神性的神修吃了强制推后信仰天劫100天。可以受到幽淬的加成.
  xlua.private_accessible(CS.XiaWorld.GodPractice)
  if npc.PropertyMgr.Practice and npc.PropertyMgr.Practice.GodPracticeData then
    local god = npc.PropertyMgr.Practice.GodPracticeData
    if god.FeishengJieColdDown > 0 then
      god.FeishengJieColdDown = god.FeishengJieColdDown + 600*100*modifier.Scale
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

