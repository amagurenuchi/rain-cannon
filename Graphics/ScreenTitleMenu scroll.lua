local gameCommand = Var("GameCommand")

return Def.ActorFrame {
	LoadFont("Common Normal") .. {
		Text = THEME:GetString("ScreenTitleMenu", gameCommand:GetText()),
		InitCommand = function(self)
			self:halign(1):diffuse(color("#000000")):shadowlength(0):zoom(0.6)
		end,
		GainFocusCommand = function(self)
			self:stoptweening():smooth(0.1):diffuse(COLOR.MainHighlight):zoom(0.65)
		end,
		LoseFocusCommand = function(self)
			self:stoptweening():smooth(0.1):diffuse(color("#000000")):zoom(0.6)
		end,
	}
}
