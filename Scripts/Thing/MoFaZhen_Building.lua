local tbThing = GameMain:GetMod("ThingHelper"):GetThing("MoFaZhen_Building");

--点击建筑
function tbThing:OnPutDown()

  self.it:RemoveBtnData("Get Qi", nil, "bind.luaclass:GetTable():SelectNpcOut()", "Use magic circle Qi to replenish your own Qi", nil);
  self.it:AddBtnData("Get Qi", nil, "bind.luaclass:GetTable():SelectNpcOut()", "Use magic circle Qi to replenish your own Qi", nil);

  self.it:RemoveBtnData("Insert Qi", nil, "bind.luaclass:GetTable():SelectNpcIn()", "Insert half of your max Qi to feed the magic circle", nil);
  self.it:AddBtnData("Insert Qi", nil, "bind.luaclass:GetTable():SelectNpcIn()", "Insert half of your max Qi to feed the magic circle", nil);

end

--使用、查询内门NPC
function tbThing:SelectNpcOut()
  CS.Wnd_SelectNpc.Instance:Select(
		WorldLua:GetSelectNpcCallback(function(rs)
			if (rs == nil or rs.Count == 0) then
				return
			end
			self:OutLing(ThingMgr:FindThingByID(rs[0]))
		end), 
	g_emNpcRank.Disciple, 1, 1, nil, nil, "Choose role");
end

function tbThing:SelectNpcIn()
  CS.Wnd_SelectNpc.Instance:Select(
		WorldLua:GetSelectNpcCallback(function(rs)
			if (rs == nil or rs.Count == 0) then
				return
			end
			self:InLing(ThingMgr:FindThingByID(rs[0]))
		end), 
	g_emNpcRank.Disciple, 1, 1, nil, nil, "Choose role");
end

function tbThing:OutLing(npc)
	local Ling = npc.MaxLing - npc.LingV;
	Ling = math.ceil(Ling)
	local name = self.it:GetName()
	if(self.it.LingV > Ling) then
		npc:AddLing(Ling);
		self.it:AddLing(-Ling);
		world:ShowMsgBox(name..'provided'..npc.Name..'with'..Ling..'Qi');
		return;
	end
	Ling = self.it.LingV;
	npc:AddLing(Ling);
	self.it:AddLing(-Ling);
	world:ShowMsgBox(name..'provided'..npc.Name..'with'..Ling..'Qi');
end

function tbThing:InLing(npc)
	local Ling = npc.LingV / 2;
	Ling = math.ceil(Ling);
	npc:AddLing(-Ling);
	self.it:AddLing(Ling);
	local name = self.it:GetName()
	world:ShowMsgBox(npc.Name..'provided'..name..'with'..Ling..'Qi');
end