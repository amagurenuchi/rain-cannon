local args = ... or {}

local Values = {
	AvatarPath = "",
	ProfileName = "",
	Rating = 0,
	Rank = 0,
	FrameWidth = 250,
	FrameHeight = 50,
	BorderSize = 1,
	ButtonZ = 0,
	BackgroundColor = COLOR.MainBackground,
	TextColor = COLOR.TextMain,
	BorderColor = COLOR.MainBorder,
	ProfileTextScale = 0.8,
	RatingTextScale = 0.4
}

local function SetValues(args)
	for k,v in pairs(args) do
		Values[k] = v
	end
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		SetValues(args)
		self:playcommand("Update",args)
	end,
	UpdateCommand = function(self, params)
		SetValues(params)
		self:PlayCommandsOnChildren("Update")
	end
}


-- Border
t[#t+1] = UIElements.Border(Values.FrameWidth,Values.FrameHeight,Values.BorderSize)..{
	UpdateCommand = function(self)
		self:diffuse(COLOR.MainBorder)
		self:GetChild("MaskSource"):zoomto(Values.FrameWidth, Values.FrameHeight)
		self:GetChild("MaskDest"):zoomto(Values.FrameWidth+Values.BorderSize*2, Values.FrameHeight+Values.BorderSize*2)
	end
}

-- Background Button
t[#t+1] = UIElements.QuadButton(Values.ButtonZ)..{
	UpdateCommand = function(self)
		self:zoomto(Values.FrameWidth,Values.FrameHeight)
		self:diffuse(COLOR.MainBackground):diffusealpha(0.9)
		self:z(Values.ButtonZ)
	end
}


-- Player Avatar
t[#t+1] = Def.Sprite {
	UpdateCommand = function(self)
		self:x(-Values.FrameWidth/2)
		self:halign(0)
		self:Load(Values.AvatarPath)
		self:zoomto(Values.FrameHeight,Values.FrameHeight)
	end
}

-- Rating text
t[#t+1] = LoadFont("Common Normal")..{
	UpdateCommand = function(self)
		self:xy(-Values.FrameWidth/2+Values.FrameHeight+5,10)
		self:halign(0)
		self:zoom(Values.RatingTextScale)
		self:diffuse(GetRatingColor(Values.Rating))
		self:settextf("%0.2f | #%d",Values.Rating, Values.Rank)
	end
}

-- Player Name
t[#t+1] = LoadFont("Common Normal")..{
	UpdateCommand = function(self)
		self:xy(-Values.FrameWidth/2+Values.FrameHeight+5,-5)
		self:halign(0)
		self:zoom(Values.ProfileTextScale)
		self:maxwidth((Values.FrameWidth-Values.FrameHeight-10)/Values.ProfileTextScale)
		self:diffuse(COLOR.TextMain)
		self:settext(Values.ProfileName)
	end
}



return t