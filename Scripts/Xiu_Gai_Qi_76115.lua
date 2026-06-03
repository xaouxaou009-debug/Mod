
require('Scripts/lib.lua')
local Xiu_Gai_Qi_76115 = GameMain:NewMod("Xiu_Gai_Qi_76115");--先注册一个新的MOD模块

function Xiu_Gai_Qi_76115:OnEnter()
	print("Xiu_Gai_Qi_76115 OnEnter");
	self.mod_enable = true;
	
	local Event = GameMain:GetMod("_Event");
	Event:RegisterEvent(g_emEvent.SelectItem,  
	function(evt, item, objs) 
		self:AddBtn2Item(evt, item, objs); 
	end, "Xiu_Gai_Qi_76115");
		Event:RegisterEvent(g_emEvent.SelectNpc,  
	function(evt, npc, objs) 
		if npc ~= self.last_item then
			self.last_item = npc
			self:AddBtn2Npc(evt, npc, objs); 
		end
	end, "Xiu_Gai_Qi_76115");
	if World.GameMode == CS.XiaWorld.g_emGameMode.Fight then
		self.mod_enable = false;
	end
	print("Xiu_Gai_Qi_76115 OnEnter");
end

function Xiu_Gai_Qi_76115:AddBtn2Item(evt, thing, objs)
	print(thing);
	
	if not self.mod_enable then
		return;
	end
	
	print("thing ~= nil ",thing ~= nil);
	print("thing.ThingType == g_emThingType.Item ",thing.ThingType == g_emThingType.Item);
	if thing ~= nil and thing.ThingType == g_emThingType.Item then 

		thing:RemoveBtnData("คูน×2");
		thing:AddBtnData(
			"คูน×2", 
			"res/Sprs/ui/icon_hand", 
			"GameMain:GetMod('Xiu_Gai_Qi_76115'):MultiItems(bind)", 
			"เพิ่มไอเทมคูนx2", 
			nil
		);
		thing:RemoveBtnData("幽淬");
		thing:RemoveBtnData("หลอมอสูร");
		thing:AddBtnData(
			"หลอมอสูร", 
			"res/Sprs/ui/icon_hand", 
			"GameMain:GetMod('Xiu_Gai_Qi_76115'):YouCuiItems(bind)", 
			"ยกระดับคุณภาพไอเทมขึ้น 1 ขั้น โดยสำเร็จแน่นอน", 
			nil
		);
		thing:RemoveBtnData("灵淬");
		thing:RemoveBtnData("หลอมจิต");
		thing:AddBtnData(
			"หลอมจิต", 
			"res/Sprs/ui/icon_hand", 
			"GameMain:GetMod('Xiu_Gai_Qi_76115'):LingCuiItems(bind)", 
			"หลอมจิตไอเทม 1 ครั้ง โดยสำเร็จแน่นอน", 
			nil
		);
		-- thing:RemoveBtnData("满灵");
		-- thing:AddBtnData(
		-- 	"满灵", 
		-- 	"res/Sprs/ui/icon_hand", 
		-- 	"GameMain:GetMod('Xiu_Gai_Qi_76115'):FullLing(bind)", 
		-- 	"将物品的灵气提高到上限", 
		-- 	nil
		-- );
		if thing.IsFaBao == true then
			thing:RemoveBtnData("天劫");
			thing:AddBtnData(
				"天劫", 
				"res/Sprs/ui/icon_hand", 
				"GameMain:GetMod('Xiu_Gai_Qi_76115'):TianJie(bind)", 
				"让法宝获得三十六重天劫洗练", 
				nil
			);
		end
	end
end


function Xiu_Gai_Qi_76115:GenGai(item)
local zzz=CS.XiaWorld.NpcLuaHelper(item);
zzz:TriggerStory("Game_Modifier");
end

function Xiu_Gai_Qi_76115:AddBtn2Npc(evt, thing, objs)
	print(thing);
	
	
	print("thing ~= nil ",thing ~= nil);
	print("thing.ThingType == g_emThingType.Npc ",thing.ThingType == g_emThingType.Npc);
	if thing ~= nil and thing.ThingType == g_emThingType.Npc then 
		thing:RemoveBtnData("ปรับค่า");
		thing:AddBtnData(
			"ปรับค่า", 
			"res/Sprs/ui/icon_flag", 
			"GameMain:GetMod('Xiu_Gai_Qi_76115'):GenGai(bind)", 
			"ปรับค่าตัวละคร", 
			nil
		);

	
		
		end
	end


function Xiu_Gai_Qi_76115:MultiItems(item)

    local count = item.Count

    print("Count =", count)

    item:ChangeCount(count * 2)

end

function Xiu_Gai_Qi_76115:YouCuiItems(item)
	if item.Rate < 12 then
		item:SoulCrystalYouPowerUp(100)
	end
end

function Xiu_Gai_Qi_76115:LingCuiItems(item)
	item:SoulCrystalLingPowerUp(100)
end

function Xiu_Gai_Qi_76115:FullLing(item)
	print(item.MaxLing)
	print(item.LingV)
	iLing = item.MaxLing - item.LingV;
	item:AddLing(iLing);
end

function Xiu_Gai_Qi_76115:TianJie(item)
	for i=1,50 do
		item.Fabao:	AddGodCount(1);
	end
	
end

--代码参考了多人操作helper的mod
