return Def.ActorFrame{
	
	Def.Quad{
		Name="Horizontal",
		InitCommand = function(self)
			self:x(-4):zoomto(504,44):halign(0)
			self:diffuseramp()
			self:effectperiod(1)
			self:effectcolor1(color("#FFFFFF00"))
			self:effectcolor2(Alpha(COLOR.MainHighlight,0.2))
		end,
	}

}