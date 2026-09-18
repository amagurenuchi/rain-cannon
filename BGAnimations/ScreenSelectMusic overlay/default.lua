local wheel
local screen

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:rotationz(0)
	end;
	OnCommand = function(self)
		screen = SCREENMAN:GetTopScreen()
		wheel = screen:GetMusicWheel()
	end;
}

t[#t+1] = Def.Actor{
	OnCommand = function(self)
		self:sleep(0.5):queuecommand("RefreshWheel")
	end,
	RefreshWheelCommand = function(self)
		if wheel then wheel:Move(0) end
	end,
}

t[#t+1] = LoadActor("../_mouse.lua", "ScreenSelectMusic")

-- Player profile bar
local profile = PROFILEMAN:GetProfile(PLAYER_1)
local function ProfileValue(method, fallback)
	if profile and profile[method] then
		local ok, value = pcall(function() return profile[method](profile) end)
		if ok and value ~= nil then return value end
	end
	return fallback
end

t[#t+1] = Def.Quad{
	OnCommand = function(self)
		self:xy(SCREEN_WIDTH - 145, 60):zoomto(250, 50):diffuse(COLOR.MainHighlight)
	end,
}

t[#t+1] = LoadActor(THEME:GetPathG("", "Profilebar"), {
	AvatarPath = ProfileValue("GetAvatarPath", ""),
	ProfileName = ProfileValue("GetDisplayName", ProfileValue("GetName", "PLAYER 1")),
	Rating = ProfileValue("GetPlayerRating", 0),
	Rank = ProfileValue("GetRank", 0),
})..{
	OnCommand = function(self)
		self:xy(SCREEN_WIDTH - 150, 55)
	end,
}


t[#t+1] = LoadActor(THEME:GetPathG("","Banner"))..{
	OnCommand = function(self)
		self:xy(SCREEN_WIDTH-260,200)
	end,
	CurrentSongChangedMessageCommand = function(self) 
		local song = GAMESTATE:GetCurrentSong()
		if song then
			self:playcommand("SongUpdate",{Song = song, Steps = GAMESTATE:GetCurrentSteps(PLAYER)})
		else
			self:playcommand("SongUpdate",{Song = nil, Group = wheel:GetSelectedSection()})
		end
	end,
	CurrentRateChangedMessageCommand = function(self) 
		self:playcommand("RateUpdate",{Steps = GAMESTATE:GetCurrentSteps(PLAYER)})
	end,
	CurrentStepsP1ChangedMessageCommand = function(self)
		self:playcommand("StepsUpdate",{Steps = GAMESTATE:GetCurrentSteps(PLAYER)})
	end,
}

t[#t+1] = LoadActor(THEME:GetPathG("","MSDDisplay"))..{
	OnCommand = function(self)
		self:xy(SCREEN_WIDTH-260,385)
	end,
	CurrentSongChangedMessageCommand = function(self) 
		local song = GAMESTATE:GetCurrentSong()
		if song then
			self:playcommand("SongUpdate",{Song = song, Steps = GAMESTATE:GetCurrentSteps(PLAYER)})
		else
			self:playcommand("SongUpdate",{Song = nil, Group = wheel:GetSelectedSection()})
		end
	end,
	CurrentRateChangedMessageCommand = function(self) 
		self:playcommand("RateUpdate",{Steps = GAMESTATE:GetCurrentSteps(PLAYER)})
	end,
	CurrentStepsP1ChangedMessageCommand = function(self)
		self:playcommand("StepsUpdate",{Steps = GAMESTATE:GetCurrentSteps(PLAYER)})
	end,
}

t[#t+1] = LoadActor(THEME:GetPathG("","BestScoreDisplay"))..{
	OnCommand = function(self) self:xy(SCREEN_WIDTH-260, 535) end,
	CurrentSongChangedMessageCommand = function(self)
		self:playcommand("SongUpdate", {Song=GAMESTATE:GetCurrentSong(), Steps=GAMESTATE:GetCurrentSteps(PLAYER)})
	end,
	CurrentStepsP1ChangedMessageCommand = function(self)
		self:playcommand("StepsUpdate", {Steps=GAMESTATE:GetCurrentSteps(PLAYER)})
	end,
}

t[#t+1] = LoadActor(THEME:GetPathG("","StepsList"))..{
	OnCommand = function(self)
		self:xy(SCREEN_WIDTH-625, 285)
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:playcommand("SongUpdate")
	end,
	CurrentStepsP1ChangedMessageCommand = function(self)
		self:playcommand("StepsUpdate", {Steps = GAMESTATE:GetCurrentSteps(PLAYER)})
	end,
	CurrentRateChangedMessageCommand = function(self)
		self:playcommand("RateUpdate")
	end,
}

t[#t+1] = StandardDecorationFromFileOptional("Header","Header")

-- Keep the transition hint independent from the sliding select-screen content.
return t
