local wheel
local screen

local function ChangeMusicRate(delta)
	local current = GAMESTATE:GetSongOptionsObject("ModsLevel_Current")
	if not current or not current.MusicRate then return end

	local rate = current:MusicRate()
	local newRate = math.max(0.05, math.min(3.0, rate + delta))
	for _, level in ipairs({"ModsLevel_Preferred", "ModsLevel_Song", "ModsLevel_Current"}) do
		local options = GAMESTATE:GetSongOptionsObject(level)
		if options and options.MusicRate then
			options:MusicRate(newRate)
		end
	end
	MESSAGEMAN:Broadcast("CurrentRateChanged", {oldRate = rate, rate = newRate})
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:rotationz(0)
	end;
	OnCommand = function(self)
		screen = SCREENMAN:GetTopScreen()
		wheel = screen:GetMusicWheel()
		screen:AddInputCallback(function(event)
			local deviceButton = event.DeviceInput and event.DeviceInput.button
			if event.type == "InputEventType_FirstPress" and deviceButton == "DeviceButton_space" then
				local song = GAMESTATE:GetCurrentSong()
				if song and GAMESTATE:GetCurrentSteps(PLAYER_1) then
					SCREENMAN:AddNewScreenToTop("ScreenChartPreview")
				end
				return false
			end
		if event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat" then
			if event.button == "EffectUp" then
				ChangeMusicRate(0.05)
			elseif event.button == "EffectDown" then
				ChangeMusicRate(-0.05)
			end
		end
	end)
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

t[#t+1] = LoadActor("../_cursor.lua", "ScreenSelectMusic")

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
	AvatarPath = getAvatarPath(PLAYER_1),
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
	CurrentRateChangedMessageCommand = function(self, params)
		self:playcommand("RateUpdate",{Steps = GAMESTATE:GetCurrentSteps(PLAYER), rate = params and params.rate})
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
	CurrentRateChangedMessageCommand = function(self, params)
		self:playcommand("RateUpdate",{Steps = GAMESTATE:GetCurrentSteps(PLAYER), rate = params and params.rate})
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
	CurrentRateChangedMessageCommand = function(self, params)
		self:playcommand("RateUpdate", {Steps=GAMESTATE:GetCurrentSteps(PLAYER), rate=params and params.rate})
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
