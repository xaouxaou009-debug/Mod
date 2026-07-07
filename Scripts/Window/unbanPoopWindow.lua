local Windows = GameMain:GetMod("Windows")
local unbanPoopWindow = Windows:CreateWindow("unbanWindow")


function unbanPoopWindow:OnInit()
	-- print("Oninit");
	self.window.contentPane = UIPackage.CreateObject("AutoUnbanPoopGui", "unbanWindow")
	-- print("Pane set");
	self.window.closeButton = self:GetChild("frame"):GetChild("n5")
	-- print("closebutton set");
	self:GetChild("frame"):GetChild("title").text = "AutoUnbanPoop"
	-- print("title set");
	self:GetChild("n4").text = "Automatically Unban Poop"
	-- print("t1 set");
	self:GetChild("n5").text = "Every"
	-- print("t2 set");
	self:GetChild("n6").text = "Seconds"
	-- print("t3 set");
	-- self:GetChild("n2").selected = true
	-- self:GetChild("n3").text = 5
	self.window:Center()
	-- self.window:Show()
end

function unbanPoopWindow:OnShowUpdate()

end

function unbanPoopWindow:OnShown()

end

function unbanPoopWindow:OnHide()

end

-- function unbanPoopWindow:setToggle(toggle)
	-- self:GetChild("n2").selected = toggle
-- end

-- function unbanPoopWindow:setInterval(interval)
	-- self:interval = interval
	
-- end

-- function unbanPoopWindow:getToggle()
	-- return self:GetChild("n2").selected
-- end

-- function unbanPoopWindow:getInterval()
	-- return self:interval
-- end