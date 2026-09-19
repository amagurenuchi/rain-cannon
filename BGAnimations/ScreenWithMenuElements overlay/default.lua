local screen

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:rotationz(0)
	end,
	OnCommand = function(self)
		screen = SCREENMAN:GetTopScreen()
		if screen then
			self:AddChild(LoadActor("../_cursor.lua", screen:GetName()))
		end
	end
}

t[#t+1] = StandardDecorationFromFileOptional("Header","Header")

return t
