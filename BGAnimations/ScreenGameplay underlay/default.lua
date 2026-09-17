local t = Def.ActorFrame{}

-- Dark background for gameplay
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:FullScreen()
		self:diffuse(color("#000000"))
	end
}

t[#t+1] = LoadActor("../_songbg.lua")

return t
