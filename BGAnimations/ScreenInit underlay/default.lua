local t = Def.ActorFrame{}

-- Solid full screen background quad to guarantee 100% opacity over fallback engine layers
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:FullScreen()
		self:diffuse(COLOR.MainBackground)
		self:diffusealpha(1)
	end
}

t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements", "underlay"))

return t
