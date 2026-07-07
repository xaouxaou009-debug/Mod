--真凰炽焰
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("Modifier_ZhenHuangChiYan")
local ZhiYaoZhuo = GameMain:GetMod("ZhiYaoZhuo")


local RATE = 0.02 --每次攻击敌人造成固定的灵气百分比伤害。

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  if npc.IsDisciple then --仅外门弟子装备有效。
    npc:RemoveModifier("Modifier_ZhenHuangChiYan")
  end
  --将武器的攻速拉满。
  local weapon = npc.Equip:GetWeapon()
  if weapon then
    ZhiYaoZhuo.SetPrivateProperty(weapon, "AttackSpeed", CS.XLua.Cast.Int32(10))
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
	--将武器的攻速恢复至def定义的数。
  local weapon = npc.Equip:GetWeapon()
  if weapon then
    local def_speed = weapon.def.Item.Equip.AttackSpeed
    ZhiYaoZhuo.SetPrivateProperty(weapon, "AttackSpeed", CS.XLua.Cast.Int32(def_speed))
  end
end

--获取存档数据
function tbModifier:OnGetSaveData()
	return nil
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

--注册事件。
function tbModifier:Register()
  GameMain:GetMod("_Event"):RegisterEvent(g_emEvent.WillFightBodyBeHit, self.CallBack, "Modifier_ZhenHuangChiYan")
end

--反注册事件。
function tbModifier:Unregister()

end

function tbModifier.CallBack(data, thing, objs)
  local from = objs[2]
  local target = thing
  local modifier = nil
  if from then modifier = from.PropertyMgr:FindModifier(data) end
  if modifier then
    local target_ling = target.MaxLing * RATE
    target:AddLing(-target_ling)
  end
end