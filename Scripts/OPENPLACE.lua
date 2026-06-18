local OPENPLACE = GameMain:GetMod("OPENPLACE");
local time = 0;
local flag = 0;

function OPENPLACE:OnStep(dt)
if flag == 0 then
time = time + dt;
if time >= 10  then
flag = 1;
CS.XiaWorld.PlacesMgr.Instance:UnlockAll()
end
end
end

