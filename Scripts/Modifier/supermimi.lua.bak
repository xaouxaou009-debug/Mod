--超级秘密丹
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_supermimi")
local ZhiYaoZhuo = GameMain:GetMod("ZhiYaoZhuo")


local g_emFabaoSpecialAbility = CS.XiaWorld.Fight.g_emFabaoSpecialAbility
local g_emFaBaoP = CS.XiaWorld.Fight.g_emFaBaoP

local RANDOM_MIBAOS = {
  {Kind = g_emFabaoSpecialAbility.HitCountAddDamage, nParam1 = 15, sParam1 = "TheWholeBody", sParam2 = "FivePoison", Desc = "每{nParam1}次攻击修行者本体，会穿透护盾造成额外伤害。"},
  {Kind = g_emFabaoSpecialAbility.FlyDamageAddP, fParam1 = 0.001, Desc = "法宝每飞行1秒，基础威力就提高{fParam1}%，返回后清空。"},
  {Kind = g_emFabaoSpecialAbility.HitAddRecovery, fParam1 = 0.01, Desc = "造成伤害的{fParam1}%会补充为法宝自身的灵气。"},
  {Kind = g_emFabaoSpecialAbility.HitCountAddMirror, nParam1=15, nParam2=1, fParam1=0.1, Desc = "每攻击{nParam1}次，产生{nParam2}道剑光分化，持续{fParam1}秒"},
  {Kind = g_emFabaoSpecialAbility.HitCountAddSubColdDown, nParam1=10, fParam1=0.5, Desc = "每{nParam1}次攻击会减少{fParam1}秒技能CD。"},
  {Kind = g_emFabaoSpecialAbility.FristHitPowerUp, fParam1=1, Desc = "第一剑威力增加{fParam1}%，法宝补充灵气重置。"},
}

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  local info = CS.XiaWorld.SpNpcMgr.Instance:AddSpNpc("info_SpDropList")
  if modifier.Scale > 1 then --幽淬过的超级秘密丹添加强化BUFF。
    info.Modifiers:Add("Boss_Qianghua")
    info.ModifierScales:Add(modifier.Scale - 1)
  end
  if modifier.Scale > 500 then --33淬以上的BOSS则添加灵气屏障。
    info.Modifiers:Add("Boss_Barrier")
    info.ModifierScales:Add(1)
  end
  if modifier.Scale > 3500 then --44淬以上大能添加物理免疫。
    info.Modifiers:Add("Boss_Immunity")
    info.ModifierScales:Add(1)
  end
  local daneng = CS.XiaWorld.SpNpcMgr.Instance:CallSpNpc(info.Name)
  if modifier.Scale > 8 then --11淬以上的大能会携带随机的神器法宝，法宝威力随幽淬次数而增加。
    local fabao = ItemRandomMachine.RandomFabao(CS.XiaWorld.g_emItemLable.FightFabao, 12, 12, 1, nil, nil, 12, true)
    local atk = fabao.Fabao:GetProperty(g_emFaBaoP.AttackPower)
    fabao.Fabao:SetProperty(g_emFaBaoP.AttackPower, atk * modifier.Scale / 8)
    if modifier.Scale > 60 then --如果大于22淬，则这个法宝还可能有随机的秘宝能力。
      local special_ability = self:GetMiBaoPower(math.random(#RANDOM_MIBAOS), modifier.Scale / 60)
      fabao.Fabao.AbilityDatas:Add(special_ability)
    end
    daneng:EquipItem(fabao, CS.XiaWorld.g_emEquipType.AtkFabao) --在第一个位置携带圣器法宝。
    fabao:AddLing(fabao.Fabao:GetProperty(g_emFaBaoP.MaxLing) * (1 + fabao.Fabao:GetNpcPropertyFinalValue(daneng, "NpcFight_FabaoMaxLingAddP")), 0) --把法宝灵气补满。
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
	return nil
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

function tbModifier:GetMiBaoPower(index, scale)
  local data = ZhiYaoZhuo.deepcopy(RANDOM_MIBAOS[index]) --我们需要复制一份原表格以防止更改基础数据。
  for k,v in pairs(data) do
    if k == "nParam1" then
      data[k] = math.random(v)
    elseif k == "nParam2" then
      data[k] = math.random(v * math.floor(scale))
    elseif k == "fParam1" then
      data[k] = v * scale
    end
  end
  for cap in string.gmatch(data.Desc, "{(.-)}") do
    local d = data[cap]
    if cap == "fParam1" and (data.Kind == g_emFabaoSpecialAbility.FlyDamageAddP or data.Kind == g_emFabaoSpecialAbility.HitAddRecovery or data.Kind == g_emFabaoSpecialAbility.FristHitPowerUp) then
      d = d * 100
    end
    data.Desc = string.gsub(data.Desc, "{"..cap.."}", string.format("%.2f", d))
  end
  return data
end