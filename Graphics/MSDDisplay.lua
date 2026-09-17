local args = ... or {}

local Values = {
	Song = nil,
	Steps = nil,
	Rate = 1,
	FrameWidth = 448+20,
	FrameHeight = 140,
	BorderSize = 1,
	BorderShadowOffSet = 5,
}

local skillsets = {
	{ name = "Stream", index = 2 },
	{ name = "Jumpstream", index = 3 },
	{ name = "Handstream", index = 4 },
	{ name = "Stamina", index = 5 },
	{ name = "JackSpeed", index = 6 },
	{ name = "Chordjack", index = 7 },
	{ name = "Technical", index = 8 },
}

local function GetDifficultyName(diff)
	if not diff then return "NORMAL" end
	local str = ToEnumShortString(diff)
	if str == "Beginner" then return "BEGINNER"
	elseif str == "Easy" then return "EASY"
	elseif str == "Medium" then return "NORMAL"
	elseif str == "Hard" then return "HARD"
	elseif str == "Challenge" then return "EXPERT"
	elseif str == "Edit" then return "EDIT"
	else return string.upper(str) end
end

local function GetMSD(steps, rate, index)
	if not steps or not steps.GetMSD then return 0 end
	rate = rate or 1
	local msd = steps:GetMSD(rate, index)
	if not msd or msd ~= msd or msd < 0 then return 0 end
	return msd
end

local function SetValues(args)
	if not args then return end
	for k,v in pairs(args) do
		Values[k] = v
	end
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		SetValues(args)
		self:playcommand("Update")
	end,
	UpdateCommand = function(self, params)
		SetValues(params)
		Values.Song = (params and params.Song) or GAMESTATE:GetCurrentSong()
		Values.Steps = (params and params.Steps) or GAMESTATE:GetCurrentSteps(PLAYER)
		if GAMESTATE:GetSongOptionsObject('ModsLevel_Current') then
			Values.Rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Current'):MusicRate()
		else
			Values.Rate = 1
		end
		self:PlayCommandsOnChildren("Update")
	end,
	SongUpdateCommand = function(self, params) self:playcommand("Update", params) end,
	StepsUpdateCommand = function(self, params) self:playcommand("Update", params) end,
	RateUpdateCommand = function(self, params) self:playcommand("Update", params) end,
	CurrentStepsChangedMessageCommand = function(self, params)
		Values.Steps = params and (params.ptr or params.Steps) or GAMESTATE:GetCurrentSteps(PLAYER)
		self:playcommand("Update")
	end,
}

-- Shadow quad
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(Values.FrameWidth, Values.FrameHeight)
		self:xy(Values.BorderShadowOffSet, Values.BorderShadowOffSet)
		self:diffuse(COLOR.MainHighlight)
	end,
}

-- Border
t[#t+1] = UIElements.Border(Values.FrameWidth, Values.FrameHeight, Values.BorderSize)..{
	UpdateCommand = function(self)
		self:diffuse(COLOR.MainBorder)
		self:GetChild("MaskSource"):zoomto(Values.FrameWidth, Values.FrameHeight)
		self:GetChild("MaskDest"):zoomto(Values.FrameWidth + Values.BorderSize*2, Values.FrameHeight + Values.BorderSize*2)
	end
}

-- Main Background
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(Values.FrameWidth, Values.FrameHeight)
		self:diffuse(COLOR.MainBackground)
	end,
}

-- Top Header: Difficulty Name & Meter
t[#t+1] = LoadFont("Common Normal") .. {
	Name = "DiffText",
	InitCommand = function(self)
		self:xy(-Values.FrameWidth/2 + 15, -Values.FrameHeight/2 + 15)
		self:halign(0)
		self:zoom(0.48)
		self:diffuse(COLOR.TextMain)
	end,
	UpdateCommand = function(self)
		local steps = Values.Steps or GAMESTATE:GetCurrentSteps(PLAYER)
		if steps then
			local diffName = GetDifficultyName(steps:GetDifficulty())
			local meter = steps:GetMeter()
			self:settextf("%s %d", string.upper(diffName), meter)
		else
			self:settext("NO CHART SELECTED")
		end
	end,
	SongUpdateCommand = function(self) self:playcommand("Update") end,
	StepsUpdateCommand = function(self) self:playcommand("Update") end,
}

-- Top Header Right: Overall MSD
t[#t+1] = LoadFont("Common Normal") .. {
	Name = "OverallMSDText",
	InitCommand = function(self)
		self:xy(Values.FrameWidth/2 - 15, -Values.FrameHeight/2 + 15)
		self:halign(1)
		self:zoom(0.7)
	end,
	UpdateCommand = function(self)
		local steps = Values.Steps or GAMESTATE:GetCurrentSteps(PLAYER)
		local rate = Values.Rate or 1
		local msd = GetMSD(steps, rate, 1)
		self:settextf("MSD: %.2f", msd)
		self:diffuse(GetRatingColor(msd))
	end,
	SongUpdateCommand = function(self) self:playcommand("Update") end,
	StepsUpdateCommand = function(self) self:playcommand("Update") end,
	RateUpdateCommand = function(self) self:playcommand("Update") end,
}

-- Divider line
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(0, -Values.FrameHeight/2 + 32)
		self:zoomto(Values.FrameWidth - 30, 1)
		self:diffuse(COLOR.MainBorder):diffusealpha(0.3)
	end
}

-- Grid of 8 Skillsets (4 columns x 2 rows)
local colXs = { -155, -52, 52, 155 }
local rowYs = { -5, 33 }

for i, sk in ipairs(skillsets) do
	local col = ((i - 1) % 4) + 1
	local row = math.floor((i - 1) / 4) + 1
	local cx = colXs[col]
	local cy = rowYs[row]

	-- Sub-card background for skillset
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(cx, cy)
			self:zoomto(96, 32)
			self:diffuse(COLOR.MainBorder):diffusealpha(0.08)
		end
	}

	-- Border for sub-card
	t[#t+1] = UIElements.Border(96, 32, 1)..{
		InitCommand = function(self)
			self:xy(cx, cy)
			self:diffuse(COLOR.MainBorder):diffusealpha(0.25)
		end
	}

	-- Skillset Label
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(cx, cy - 8)
			self:halign(0.5)
			self:zoom(0.35)
			self:diffuse(COLOR.TextSub1)
			self:settext(sk.name)
		end
	}

	-- Skillset MSD Value (colored using GetRatingColor)
	t[#t+1] = LoadFont("Common Normal") .. {
		Name = "SkillMSD_" .. sk.name,
		InitCommand = function(self)
			self:xy(cx, cy + 6)
			self:halign(0.5)
			self:zoom(0.48)
		end,
		UpdateCommand = function(self)
			local steps = Values.Steps or GAMESTATE:GetCurrentSteps(PLAYER)
			local rate = Values.Rate or 1
			local msd = GetMSD(steps, rate, sk.index)
			self:settextf("%.2f", msd)
			self:diffuse(GetRatingColor(msd))
		end,
		SongUpdateCommand = function(self) self:playcommand("Update") end,
		StepsUpdateCommand = function(self) self:playcommand("Update") end,
		RateUpdateCommand = function(self) self:playcommand("Update") end,
	}
end

return t
