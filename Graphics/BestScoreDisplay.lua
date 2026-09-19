local Values = { Song = nil, Steps = nil, Rate = 1 }
local width, height = 420, 112

local function BestScore(song, steps)
	if not song or not steps then return nil end
	local ok, profile = pcall(function() return PROFILEMAN:GetProfile(PLAYER_1) end)
	if not ok or not profile then return nil end
	local scores = {}
	if SCOREMAN and SCOREMAN.GetScoresByKey then
		local success, byRate = pcall(function() return SCOREMAN:GetScoresByKey(steps:GetChartKey()) end)
		if success and byRate then
			for _, list in pairs(byRate) do
				if list.GetScores then for _, score in ipairs(list:GetScores()) do scores[#scores+1] = score end end
			end
		end
	end
	if profile.GetHighScoresByKey then
		local success, result = pcall(function() return profile:GetHighScoresByKey(steps:GetChartKey()) end)
		if success and type(result) == "table" then scores = result end
	end
	if #scores == 0 and profile.GetHighScoreList then
		local success, list = pcall(function() return profile:GetHighScoreList(steps) end)
		if success and list and list.GetHighScores then scores = list:GetHighScores() end
	end
	local targetRate = Values.Rate or 1
	local best, bestRate, bestDistance
	for _, score in ipairs(scores) do
		if score then
			local ok, scoreRate = pcall(function() return score:GetMusicRate() end)
			scoreRate = ok and scoreRate or nil
			if type(scoreRate) == "number" then
				local distance = math.abs(scoreRate - targetRate)
				if not best or distance < bestDistance - 0.0001 or
					(distance <= 0.0001 and score:GetWifeScore() > best:GetWifeScore()) then
					best, bestRate, bestDistance = score, scoreRate, distance
				end
			end
		end
	end
	return best, bestRate, bestDistance and bestDistance <= 0.0001
end

local function Grade(score)
	if not score then return "--" end
	local grade = score.GetWifeGrade and score:GetWifeGrade() or score:GetGrade()
	return GetGradeString(grade)
end

local function SSRValue(score)
	if not score then return nil end
	if score.GetSkillsetSSR then
		local ok, value = pcall(function() return score:GetSkillsetSSR("Overall") end)
		if ok and type(value) == "number" then return value end
	end
	return nil
end

local t = Def.ActorFrame{
	InitCommand = function(self) self:playcommand("Update") end,
	UpdateCommand = function(self, p)
		Values.Song = (p and p.Song) or GAMESTATE:GetCurrentSong()
		Values.Steps = (p and p.Steps) or GAMESTATE:GetCurrentSteps(PLAYER)
		local options = GAMESTATE:GetSongOptionsObject("ModsLevel_Current")
		Values.Rate = options and options:MusicRate() or 1
		self:PlayCommandsOnChildren("Update")
	end,
	SongUpdateCommand = function(self,p) self:playcommand("Update",p) end,
	StepsUpdateCommand = function(self,p) self:playcommand("Update",p) end,
	RateUpdateCommand = function(self,p) self:playcommand("Update",p) end,
	CurrentStepsChangedMessageCommand = function(self,p) self:playcommand("Update",p) end,
}

t[#t+1] = Def.Quad{ InitCommand=function(self) self:xy(5,5):zoomto(width,height):z(-10):diffuse(COLOR.MainHighlight) end }
t[#t+1] = Def.Quad{ InitCommand=function(self) self:zoomto(width,height):z(0):diffuse(COLOR.MainBackground) end }
t[#t+1] = UIElements.Border(width,height,1)..{ InitCommand=function(self) self:z(1):diffuse(COLOR.MainBorder) end }

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+18,-height/2+15):halign(0):zoom(.48):diffuse(Color.Black):settext("BEST SCORE") end
}
t[#t+1] = LoadFont("DFPGothic 64px")..{
	InitCommand=function(self) self:xy(-width/2+70,2):halign(0.5):zoom(1.15):maxwidth(height-14) end,
	UpdateCommand=function(self)
		local s = BestScore(Values.Song,Values.Steps)
		local grade = s and (s.GetWifeGrade and s:GetWifeGrade() or s:GetGrade())
		self:settext(Grade(s)):diffuse(s and GetGradeColor(grade) or COLOR.TextSub1)
	end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+67,44):halign(0.5):zoom(.55):diffuse(Color.Black) end,
	UpdateCommand=function(self)
		local s, rate, exact = BestScore(Values.Song, Values.Steps)
		self:settext(rate and string.format(exact and "%.2fx" or "(%.2fx)", rate) or "")
	end
}
t[#t+1] = LoadFont("DFPGothic")..{
	InitCommand=function(self) self:xy(width/2-18,2):halign(1):zoom(.55):diffuse(COLOR.TextSub1) end,
	UpdateCommand=function(self)
		local s=BestScore(Values.Song,Values.Steps)
		local ssr = SSRValue(s)
		self:settext(ssr and string.format("%.2f", ssr) or "--")
		self:diffuse(ssr and GetRatingColor(ssr) or COLOR.TextSub1)
	end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+145,-13):halign(0):zoom(.7):diffuse(Color.Black) end,
	UpdateCommand=function(self)
		local s = BestScore(Values.Song, Values.Steps)
		if not s then self:settext("--"); return end
		local percent = s:GetWifeScore() * 100
		self:settext(percent > 99.7 and string.format("%.4f%%", percent) or string.format("%.2f%%", percent))
	end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+145,15):halign(0):zoom(.35):diffuse(Color.Black) end,
	UpdateCommand=function(self) local s=BestScore(Values.Song,Values.Steps); if s then self:settextf("%d | %d | %d | %d | %d | %d",s:GetTapNoteScore("TapNoteScore_W1"),s:GetTapNoteScore("TapNoteScore_W2"),s:GetTapNoteScore("TapNoteScore_W3"),s:GetTapNoteScore("TapNoteScore_W4"),s:GetTapNoteScore("TapNoteScore_W5"),s:GetTapNoteScore("TapNoteScore_Miss")) else self:settext("NO SCORE") end end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+145,33):halign(0):zoom(.4):diffuse(Color.Black) end,
	UpdateCommand=function(self) local s=BestScore(Values.Song,Values.Steps); self:settext(s and string.format("MAX COMBO  %d",s:GetMaxCombo()) or "") end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(width/2-18,-height/2+15):halign(1):zoom(.58) end,
	UpdateCommand=function(self)
		local s=BestScore(Values.Song,Values.Steps)
		if not s then self:settext(""):diffuse(COLOR.TextSub1); return end
		local clearType = getClearType(PLAYER, Values.Steps, s)
		self:settext(getClearTypeShortText(clearType)):diffuse(getClearTypeColor(clearType))
	end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(width/2-18,48):halign(1):zoom(.32):diffuse(Color.Black) end,
	UpdateCommand=function(self) local s=BestScore(Values.Song,Values.Steps); self:settext(s and ("ACHIEVED  "..tostring(s:GetDate())) or "") end
}
return t
