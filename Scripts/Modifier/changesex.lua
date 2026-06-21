--造化万神洗身丹
local tbTable = GameMain:GetMod("_ModifierScript");
local tbModifier = tbTable:GetModifier("modifier_changesex");

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  local sex = npc.LuaHelper:GetSex();
  if sex == 1 then --男的就会掉落宝贝。
    itemThing = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_Baobeier", nil, 0, 12, -1, 1);
    if itemThing then
      itemThing:SetName(npc:GetName() .. CS.TFMgr.Get("的宝贝"));
      itemThing.Rate = CS.XiaWorld.World.RandomRange(3, 10);
      npc.map:DropItem(itemThing, npc.Key, true, true, false, true, 5, false);
    end
  end
  local sex_property = typeof(CS.XiaWorld.NpcPropertyMgr):GetProperty("Sex");
  if sex_property then
    if sex == 1 then
      sex_property:SetValue(npc.PropertyMgr, CS.XiaWorld.g_emNpcSex.Female);
      npc.HairID = CS.XiaWorld.World.RandomRange(1, 11);
      --npc.PropertyMgr:RandomAgeSexAndName(CS.XiaWorld.g_emNpcSex.Female, false);
    elseif sex == 2 then
      sex_property:SetValue(npc.PropertyMgr, CS.XiaWorld.g_emNpcSex.Male);
      npc.HairID = CS.XiaWorld.World.RandomRange(1, 6);
      --npc.PropertyMgr:RandomAgeSexAndName(CS.XiaWorld.g_emNpcSex.Male, false);
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

