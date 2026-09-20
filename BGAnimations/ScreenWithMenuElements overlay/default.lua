local t = Def.ActorFrame{
	InitCommand = function(self)
		self:rotationz(0)
	end
}

t[#t+1] = StandardDecorationFromFileOptional("Header","Header")
t[#t+1] = LoadActor("../_mouse.lua")

return t
