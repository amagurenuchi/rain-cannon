
return Def.ActorFrame{
	OnCommand = function(self)
		local screen = SCREENMAN:GetTopScreen()
		if screen then
			screen:SetNextScreenName("ScreenStageInformation")
		end
	end,
}
