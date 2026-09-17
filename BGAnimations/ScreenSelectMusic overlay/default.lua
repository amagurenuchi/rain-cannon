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

t[#t+1] = LoadActor("../_mouse.lua", "ScreenSelectMusic")


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


return t
