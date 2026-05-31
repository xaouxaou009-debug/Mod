--吃货丹
local tbTable = GameMain:GetMod("_ModifierScript");
local tbModifier = tbTable:GetModifier("modifier_naobaijin");

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  self.controller = CS.BetterDriver.NpcController();
  self.controller:Enter(npc);
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  if self.controller then
    self.controller:Step(dt);
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
  npc.PropertyMgr:RemoveModifier("Dan_NaoBaiJin", true);
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
  self.controller = CS.BetterDriver.NpcController();
    self.controller:Enter(npc);
end

