local curFolder = ""
local top

local function GetSelectedDifficultyGrade(song, selectedSteps)
	local steps = selectedSteps or GAMESTATE:GetCurrentSteps(PLAYER_1)
	if not song or not steps then
		return nil
	end

	local ok, profile = pcall(function() return PROFILEMAN:GetProfile(PLAYER_1) end)
	if not ok then profile = nil end
	if not profile then return nil end
	local scores = {}
	if SCOREMAN and SCOREMAN.GetScoresByKey then
		local ok, byRate = pcall(function() return SCOREMAN:GetScoresByKey(steps:GetChartKey()) end)
		if ok and byRate then
			for _, scoreList in pairs(byRate) do
				if scoreList.GetScores then
					for _, score in ipairs(scoreList:GetScores()) do scores[#scores+1] = score end
				end
			end
		end
	end

	-- GetHighScoresByKey is the preferred Etterna API. Keep the older
	-- HighScoreList path as a fallback for compatible StepMania builds.
	if profile.GetHighScoresByKey then
		local ok, result = pcall(function()
			return profile:GetHighScoresByKey(steps:GetChartKey())
		end)
		if ok and type(result) == "table" and #scores == 0 then scores = result end
	end
	if #scores == 0 and profile.GetHighScoreList then
		local ok, list = pcall(function() return profile:GetHighScoreList(song, steps) end)
		if not ok or not list then
			ok, list = pcall(function() return profile:GetHighScoreList(steps) end)
		end
		if ok and list and list.GetHighScores then
			scores = list:GetHighScores()
		end
	end
	if #scores == 0 and steps.GetHighScoreList then
		local ok, list = pcall(function() return steps:GetHighScoreList(profile) end)
		if ok and list and list.GetHighScores then scores = list:GetHighScores() end
	end

	local best
	for _, score in pairs(scores) do
		if score and score.GetWifeScore and (not best or score:GetWifeScore() > best:GetWifeScore()) then
			best = score
		end
	end
	if not best then return nil end
	local grade = best.GetWifeGrade and best:GetWifeGrade() or best:GetGrade()
	local names = {Tier01="AAAA",Tier02="AAA",Tier03="AA",Tier04="A",Tier05="B",Tier06="C",Tier07="D",Failed="FAILED",None="--"}
	return names[tostring(grade):gsub("Grade_", "")] or tostring(grade)
end
local t =  Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
	end,
	SetCommand = function(self,params)
		self:name(tostring(params.Index))
	end
}


t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(500,40)
		self:halign(0)
		self:zwrite(true):clearzbuffer(true):blend('BlendMode_NoEffect')
	end
}

t[#t+1] = UIElements.QuadButton(1) .. {
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(500,40)
		self:halign(0)
		self:visible(false)
	end,
	TopPressedCommand = function(self, params)
		if params.input ~= "DeviceButton_left mouse button" then
			return
		end

		local newIndex = tonumber(self:GetParent():GetName())
		local wheel = top:GetMusicWheel()
		local size = wheel:GetNumItems()
		local move = newIndex-wheel:GetCurrentIndex()

		if math.abs(move)>math.floor(size/2) then
			if newIndex > wheel:GetCurrentIndex() then
				move = (move)%size-size
			else
				move = (move)%size
			end
		end
		
		local wheelType = wheel:MoveAndCheckType(move)
		wheel:Move(0)

		-- TODO: play sounds.
		if move == 0 then
			if wheelType == 'WheelItemDataType_Section' then
				if wheel:GetSelectedSection() == curFolder then
					wheel:SetOpenSection("")
					curFolder = ""
				else
					wheel:SetOpenSection(wheel:GetSelectedSection())
					curFolder = wheel:GetSelectedSection()
				end
			else
				top:SelectCurrent(0)
			end
		end
	end
}

t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(500,40)
		self:halign(0)
	end,
	SetCommand = function(self)
		self:name("Wheel"..tostring(self:GetParent():GetName()))
		self:diffusealpha(0.8)
	end,
	BeginCommand = function(self) self:queuecommand('Set') end,
	OffCommand = function(self) self:visible(false) end
}

t[#t+1] = Def.Sprite {
	InitCommand = function(self)
		self:halign(0)
		self:x(5)
	 	self:diffusealpha(0.8)
	end,
	SetMessageCommand = function(self,params)
		local song = params.Song
		local bnpath = nil
		if song then
			bnpath = params.Song:GetBannerPath()
			if bnpath then
				self:LoadBackground(bnpath)
				self:zoomto(96,30)
			end
		end
	end
}


t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(500-5,-22+10)
		self:halign(1)
		self:zoom(0.4)
	end,
	SetMessageCommand = function(self,params)
		local song = params.Song

		if song then
			local seconds = song:GetStepsSeconds()
			self:visible(true)
			if seconds < PREFSMAN:GetPreference("LongVerSongSeconds") then
				self:settext("Normal")
				self:diffuse(COLOR.TextMain)
			elseif seconds < PREFSMAN:GetPreference("MarathonVerSongSeconds") then
				self:settext("Long")
				self:diffuse(COLOR.SongLong)
			elseif seconds < PREFSMAN:GetPreference("MarathonVerSongSeconds")*2 then
				self:settext("Marathon")
				self:diffuse(COLOR.SongMarathon)
			else
				self:settext("UltraMarathon")
				self:diffuse(COLOR.SongUltraMarathon)
			end
		end
	end
}

-- Keep the grade in its own bottom-right actor. The wheel's Steps payload is
-- preferred over GAMESTATE so rapid chart changes cannot show a stale grade.
t[#t+1] = LoadFont("DFPGothic 64px") .. {
	InitCommand = function(self)
		self:xy(470, 10):halign(1):zoom(0.42):visible(false)
	end,
	SetMessageCommand = function(self, params)
		local song = params.Song
		local steps = params.Steps or GAMESTATE:GetCurrentSteps(PLAYER_1)
		local current = GAMESTATE:GetCurrentSong()
		local sameIndex = top and params.Index and tonumber(params.Index) == top:GetMusicWheel():GetCurrentIndex()
		local sameSong = song and current and song.GetMusicPath and current.GetMusicPath
			and song:GetMusicPath() == current:GetMusicPath()
		local grade = (sameSong or sameIndex) and GetSelectedDifficultyGrade(song, steps) or nil
		self:settext(grade or "")
		self:visible(grade ~= nil)
	end
}

t[#t+1] = UIElements.Border(500,40,1)..{
	InitCommand = function(self)
		self:diffuse(COLOR.MainBorder)
		self:x(250)
	end
}

t[#t+1] = LoadActor("round_star") .. {
	InitCommand = function(self)
		self:xy(3,-19)
		self:zoom(0.25)
		self:wag()
		self:diffuse(Color.Yellow)
	end,
	SetMessageCommand = function(self,params)
		local song = params.Song
		self:visible(false)
		if song then
			if song:IsFavorited() then
				self:visible(true)
			end
		end
	end
}

return t
