local gameCommand = Var("GameCommand")

return Def.ActorFrame {

	LoadFont("Common Normal") .. {
		Name = "ChoiceText",
		Text = gameCommand:GetName(),
		OnCommand = function(self)
			self:halign(1):diffuse(color("#000000")):shadowlength(0)
		end,
	}
}
