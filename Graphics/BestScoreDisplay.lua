local Values = { Song = nil, Steps = nil }
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
	local best
	for _, score in ipairs(scores) do
		if score and (not best or score:GetWifeScore() > best:GetWifeScore()) then best = score end
	end
	return best
end

local function Grade(score)
	if not score then return "--" end
	local grade = score.GetWifeGrade and score:GetWifeGrade() or score:GetGrade()
	return GetGradeString(grade)
end

local t = Def.ActorFrame{
	InitCommand = function(self) self:playcommand("Update") end,
	UpdateCommand = function(self, p)
		Values.Song = (p and p.Song) or GAMESTATE:GetCurrentSong()
		Values.Steps = (p and p.Steps) or GAMESTATE:GetCurrentSteps(PLAYER)
		self:PlayCommandsOnChildren("Update")
	end,
	SongUpdateCommand = function(self,p) self:playcommand("Update",p) end,
	StepsUpdateCommand = function(self,p) self:playcommand("Update",p) end,
	CurrentStepsChangedMessageCommand = function(self,p) self:playcommand("Update",p) end,
}

t[#t+1] = Def.Quad{ InitCommand=function(self) self:xy(5,5):zoomto(width,height):z(-10):diffuse(COLOR.MainHighlight) end }
t[#t+1] = Def.Quad{ InitCommand=function(self) self:zoomto(width,height):z(0):diffuse(COLOR.MainBackground) end }
t[#t+1] = UIElements.Border(width,height,1)..{ InitCommand=function(self) self:z(1):diffuse(COLOR.MainBorder) end }

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+18,-height/2+15):halign(0):zoom(.48):diffuse(Color.Black):settext("BEST SCORE") end
}
t[#t+1] = LoadFont("DFPGothic 64px")..{
	InitCommand=function(self) self:xy(-width/2+22,2):halign(0.5):zoom(1.15) end,
	UpdateCommand=function(self)
		local s = BestScore(Values.Song,Values.Steps)
		local grade = s and (s.GetWifeGrade and s:GetWifeGrade() or s:GetGrade())
		self:settext(Grade(s)):diffuse(s and GetGradeColor(grade) or COLOR.TextSub1)
	end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+82,-5):halign(0):zoom(.7):diffuse(Color.Black) end,
	UpdateCommand=function(self)
		local s = BestScore(Values.Song, Values.Steps)
		if not s then self:settext("--"); return end
		local percent = s:GetWifeScore() * 100
		self:settext(percent > 99.7 and string.format("%.4f%%", percent) or string.format("%.2f%%", percent))
	end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+82,23):halign(0):zoom(.35):diffuse(Color.Black) end,
	UpdateCommand=function(self) local s=BestScore(Values.Song,Values.Steps); if s then self:settextf("%d | %d | %d | %d | %d | %d",s:GetTapNoteScore("TapNoteScore_W1"),s:GetTapNoteScore("TapNoteScore_W2"),s:GetTapNoteScore("TapNoteScore_W3"),s:GetTapNoteScore("TapNoteScore_W4"),s:GetTapNoteScore("TapNoteScore_W5"),s:GetTapNoteScore("TapNoteScore_Miss")) else self:settext("NO SCORE") end end
}
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(-width/2+82,41):halign(0):zoom(.4):diffuse(Color.Black) end,
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
