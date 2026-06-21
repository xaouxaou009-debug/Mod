--灵气屏障
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_boss_barrier")


--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)

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

end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  tbData = tbData or {}
end

function tbModifier:Register()
  if GameMain:GetMod("MoreEvents").IsExist then
    CS.MoreEvents.EventManager.AddEvent("OnReduceDamage", "Boss_Barrier", tbModifier.CallBack)
    CS.MoreEvents.EventManager.AddEvent("OnReduceLingDamage", "Boss_Barrier", tbModifier.CallBack)
  end
end

function tbModifier:Unregister()
  if GameMain:GetMod("MoreEvents").IsExist then
    CS.MoreEvents.EventManager.RemoveEvent("OnReduceDamage", "Boss_Barrier")
    CS.MoreEvents.EventManager.RemoveEvent("OnReduceLingDamage", "Boss_Barrier")
  end
end

function tbModifier.CallBack(sender, e)
  local damage = e.Return
  local target = e.Target
  if target and target.PropertyMgr then
    modif = target.PropertyMgr:FindModifier("Boss_Barrier")
    if modif and damage > target.MaxLing * 0.1 then --有护盾并且伤害值大于最大灵气的10%时，直接无视伤害。
      print("伤害过量！")
      return 0
    end
  end
  return damage
end