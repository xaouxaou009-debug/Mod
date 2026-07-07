local unbanMod = GameMain:NewMod("UnbanPoopAutomatically");
-- local unbanWindow = GameMain:GetMod("Windows"):GetWindow("unbanPoopWindow")
-- Hello there, and welcome to my script
-- Written by XorOwl on 2021-09-19

local myTime = 0
local interval = 5
local enabled = true
local debug = nil
function unbanMod:OnInit()
	myTime = 0
	local myWindow = GameMain:GetMod("Windows"):GetWindow("unbanWindow")
	myWindow.window:Show()
	myWindow:GetChild('n2').selected = enabled
	myWindow:GetChild('n3').text = interval
	myWindow.window:Hide()
end

function unbanMod:OnEnter()
	-- print("Example enter");
	-- local itemdef = ThingMgr:GetDef(g_emThingType.Item,"Item_ModTestItem");--获取物品的def数据
	-- print(itemdef.ThingName);
	
	-- GameMain:GetMod("Windows"):GetWindow("SampleWindow"):Show();
	-- GameMain:GetMod("Windows"):GetWindow("unbanPoopWindow"):Show();
	
	-- local myWindow = GameMain:GetMod("Windows"):GetWindow("unbanWindow")
	-- myWindow.window:Show()
	-- myWindow:GetChild('n2').selected = enabled
	-- myWindow:GetChild('n3').text = interval
	
end

local function doUnbanPoop()

	-- first, grab the world, you'll need a local version to access
	local thisWorld = CS.XiaWorld
	-- next you need an instance of the ThingMgr
	local thingManager = thisWorld.ThingMgr.Instance
	-- and last you need the list of shit!
	local shitlist = Map.Things:GetNameItemList ("Item_Shit")
	-- TODO get boolean flag that can be toggled in the ui
	local unbanPoop = true;
	if shitlist ~= nil then
		for x, y in pairs(shitlist) do
			-- take the id that you got out of the list and get the actual item object
			thisThing = thingManager:FindThingByID(y)
			-- UNBAN!
			thisThing:SetActable(true)
		end
	end
end
function unbanMod:OnSetHotKey()
	-- this will be useful later.
	local tbHotKey = { 
		{
			ID = "unbanAllPoop", 
			Name = "UnbanPoop", 
			Type = "Mod", 
			InitialKey1 = "LeftShift+U",
			InitialKey2 = "",
		},
		{
			ID = "openPoopMenu", 
			Name = "UnbanPoopToggle", 
			Type = "Mod", 
			InitialKey1 = "LeftControl+U"
		},
	}
	return tbHotKey
end

function unbanMod:OnHotKey(ID,state)
    -- print("hotkey")
	if ID == "unbanAllPoop" and state == "down" then 
		doUnbanPoop()
		print('bbbbb')
	end
	if ID == "openPoopMenu" and state == "down" then 
		print('aaaa')
		local myWindow = GameMain:GetMod("Windows"):GetWindow("unbanWindow")
		myWindow.window:Show()

	end
	
end

function unbanMod:OnStep(dt)
	local myWindow = GameMain:GetMod("Windows"):GetWindow("unbanWindow")
	enabled = myWindow:GetChild('n2').selected
	interval = tonumber(myWindow:GetChild('n3').text)
	myTime = myTime + dt
	if myTime >= interval then
		--print("Example Step"..dt);
		if enabled then 
			doUnbanPoop()
		end
		myTime = 0
		
	end
end

function unbanMod:OnLeave()
	
end

function unbanMod:OnSave()
	-- local window = GameMain:GetMod("Windows"):GetWindow("unbanWindow")
	local taggle = "false"
	if enabled then
		taggle = "true"
	end
	local tbSave = {
		toggle = taggle,
		interval = interval
	};
	
	return tbSave
end

function unbanMod:OnLoad(tbLoad)
	-- tbLoad = tbLoad or {}
	debug = {}
	table.insert(debug,enabled);
	if tbLoad.toggle == "true" or tbLoad.toggle ~= "false" then 
		-- window:GetChild('n2').selected = true
		enabled = true
		
	else
		enabled = false
	end
	table.insert(debug,enabled);
	if tbLoad.interval ~= nil and tbLoad.interval ~= "" then
		-- window:GetChild('n3').text = tbLoad.interval
		interval = tbLoad.interval
	else
		-- window:GetChild('n3').text = 5
		interval = 5
	end
end

function unbanMod:NeedSyncData()
	 return false;
end

function unbanMod:OnSyncLoad(tbData)
	-- self.syncdata = tbData;
end

function unbanMod:OnSyncSave()
	-- return {a=1,b=2};
end

function unbanMod:OnAfterLoad()
	
end
function unbanMod:getDebug()
	return debug
end
-- function unbanMod:GetUnbanWindow()
	-- local window = GameMain:GetMod("Windows"):GetWindow("unbanWindow")
	-- repeat
		-- window = GameMain:GetMod("Windows"):GetWindow("unbanWindow")
	-- until window
	-- return window
-- end

local tbTest = GameMain:GetMod("UnbanPoopAutomatically");



-- notes for later
