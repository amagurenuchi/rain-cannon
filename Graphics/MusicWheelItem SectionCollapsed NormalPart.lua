local t =  Def.ActorFrame{
}


t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(500,40)
		self:halign(0)
	end,
	SetCommand = function(self)
		self:diffuse(COLOR.MainBackground)
		self:diffusealpha(0.9)
	end,
	BeginCommand = function(self) self:queuecommand('Set') end,
	OffCommand = function(self) self:visible(false) end
}

t[#t+1] = UIElements.Border(500,40,1)..{
	InitCommand = function(self)
		self:diffuse(COLOR.MainBorder)
		self:x(250)
	end
}

return t
