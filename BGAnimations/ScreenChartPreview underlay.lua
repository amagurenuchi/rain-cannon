local t = Def.ActorFrame{}

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:diffuse(COLOR and COLOR.MainBackground or color("#FFFFFF"))
		self:diffusealpha(0.85)
		self:FullScreen()
	end	
}

return t
