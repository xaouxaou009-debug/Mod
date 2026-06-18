--育母丹
local tbTable = GameMain:GetMod("_ModifierScript");
local tbModifier = tbTable:GetModifier("modifier_yumu");
local ZhiYaoZhuo = GameMain:GetMod("ZhiYaoZhuo");

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  local zhu = GameUlt.CallBoss("Boss_Zhulong", nil, nil, false);
  if CS.XiaWorld.FightMapMgr.Instance.MapSchool > 0 then
    self.zhu = zhu;
    zhu:SetCamp(g_emFightCamp.Friend);
    Map:BossFightEnd();
  end
  if modifier.Scale > 1 then
    zhu:AddModifier("Boss_Qianghua", modifier.Scale);
    zhu:AddLing(zhu.MaxLing - zhu.LingV);
    for k,v in pairs(zhu.FightParts) do
      local npc = ThingMgr:FindThingByID(v.ID);
      if npc then
        npc:AddModifier("Boss_Qianghua_Part", modifier.Scale);
        npc:AddLing(npc.MaxLing - npc.LingV);
      end
    end
  end
  if modifier.Scale > 10 then --强化超过10倍（12淬以上），则添加额外掉落品。掉落率跟强化次数有关。
    ZhiYaoZhuo.AddDrop(npc.Key, "Item_YinYangShuangYu", 1, math.max(0.001 * modifier.Scale, 1));
  end
  if modifier.Scale > 500 then
    zhu:AddModifier("Boss_Barrier", modifier.Scale);
  end
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  if CS.XiaWorld.FightMapMgr.Instance.MapSchool == 0 then --在自己家或者野外，则正常删除这个modifier，因为可以自己杀。
    npc:RemoveModifier("Dan_YuMu")
  end
  if CS.XiaWorld.FightMapMgr.MainMap and CS.XiaWorld.FightMapMgr.Instance.MapSchool > 0 and CS.XiaWorld.FightMapMgr.MainMap.Submission then
    npc:RemoveModifier("Dan_YuMu")
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
	if CS.XiaWorld.FightMapMgr.MainMap and CS.XiaWorld.FightMapMgr.Instance.MapSchool > 0 and self.zhu then
    self.zhu:DoDeath()
  end
end

--获取存档数据
function tbModifier:OnGetSaveData()
	return nil;
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

