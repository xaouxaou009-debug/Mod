--蛤蛤丹
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_haha")

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  local list = npc.Equip:FindFabaoEmbryo()
  if list then
    for _,id in pairs(list) do
      local item = ThingMgr:FindThingByID(id)
      if item then
        for _,data in pairs(item.FabaoAcriveData.Actives) do
          if data.def.eventid == CS.XiaWorld.FabaoEvenType.MapStay or data.def.eventid == CS.XiaWorld.FabaoEvenType.Trance or data.def.eventid == CS.XiaWorld.FabaoEvenType.Carry then
            data.Count = data.Count + (1 * modifier.Scale)
          end
        end
      end
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

