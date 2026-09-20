local t = Def.ActorFrame{
	InitCommand = function(self)
		self:rotationz(0)
	end
}

t[#t+1] = StandardDecorationFromFileOptional("Header","Header")

return t
