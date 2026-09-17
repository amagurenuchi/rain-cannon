local pss = nil
local stageStats = nil
local song = nil
local steps = nil
local rate = 1.0

local function GetEvaluationGrade(score)
	if not score then return "Grade_None" end
	return score.GetWifeGrade and score:GetWifeGrade() or score:GetGrade()
end

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

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:rotationz(0)
	end,
	OnCommand = function(self)
		local screen = SCREENMAN:GetTopScreen()
		stageStats = STATSMAN:GetCurStageStats()
		if stageStats then
			pss = stageStats:GetPlayerStageStats(PLAYER_1)
		end
		song = GAMESTATE:GetCurrentSong()
		steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
		if pss and pss.GetMusicRate then
			rate = pss:GetMusicRate()
		end
	end
}

t[#t+1] = LoadActor("../_mouse.lua", "ScreenEvaluation")
t[#t+1] = StandardDecorationFromFileOptional("Header","Header")

-- Top Song Info Card
local cardW = 880
local cardH = 110
local cardY = 130

t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, cardY)
	end,

	-- Card Shadow
	Def.Quad{
		InitCommand = function(self)
			self:zoomto(cardW, cardH):xy(4, 4):diffuse(COLOR.MainHighlight)
		end
	},
	-- Card Border
	UIElements.Border(cardW, cardH, 1)..{
		InitCommand = function(self)
			self:diffuse(COLOR.MainBorder)
		end
	},
	-- Card Background
	Def.Quad{
		InitCommand = function(self)
			self:zoomto(cardW, cardH):diffuse(COLOR.MainBackground)
		end
	},

	-- Banner Image
	Def.Sprite{
		Name = "EvalBanner",
		InitCommand = function(self)
			self:xy(-cardW/2 + 135, 0)
		end,
		OnCommand = function(self)
			if song and song:HasBanner() then
				self:LoadBackground(song:GetBannerPath())
				self:scaletoclipped(240, 85)
			else
				self:visible(false)
			end
		end
	},

	-- Song Title
	LoadFont("DFPGothic 64px")..{
		InitCommand = function(self)
			self:xy(-cardW/2 + 270, -28):halign(0):zoom(0.45):diffuse(COLOR.TextMain)
		end,
		OnCommand = function(self)
			if song then
				self:settext(song:GetDisplayMainTitle())
			else
				self:settext("No Song Selected")
			end
		end
	},

	-- Subtitle & Artist
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-cardW/2 + 270, 2):halign(0):zoom(0.55):diffuse(COLOR.TextSub1)
		end,
		OnCommand = function(self)
			if song then
				local artist = song:GetDisplayArtist()
				local subtitle = song:GetDisplaySubTitle()
				if subtitle ~= "" then
					self:settext(subtitle .. " - " .. artist)
				else
					self:settext("// " .. artist)
				end
			else
				self:settext("// Unknown Artist")
			end
		end
	},

	-- Pack / Group Name
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-cardW/2 + 270, 26):halign(0):zoom(0.45):diffuse(COLOR.TextSub2)
		end,
		OnCommand = function(self)
			if song then
				self:settext("Pack: " .. song:GetGroupName())
			else
				self:settext("Pack: Standard")
			end
		end
	},

	-- Difficulty Badge Background
	Def.Quad{
		InitCommand = function(self)
			self:xy(cardW/2 - 120, -15):zoomto(140, 34):diffuse(COLOR.MainBorder)
		end,
		OnCommand = function(self)
			if steps then
				self:diffuse(GetRatingColor(steps:GetMeter()))
			end
		end
	},

	-- Difficulty & Meter Text
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(cardW/2 - 120, -15):zoom(0.6):diffuse(COLOR.TextMainLight)
		end,
		OnCommand = function(self)
			if steps then
				self:settextf("%s %d", GetDifficultyName(steps:GetDifficulty()), steps:GetMeter())
			else
				self:settext("EXPERT 15")
			end
		end
	},

	-- Rate Text
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(cardW/2 - 120, 22):zoom(0.5):diffuse(COLOR.TextSub1)
		end,
		OnCommand = function(self)
			self:settextf("%.2fx Rate", rate)
		end
	}
}

-- Left Panel: Grade & Score Card
local leftW = 420
local leftH = 370
local leftX = SCREEN_CENTER_X - 230
local panelY = 400

t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(leftX, panelY)
	end,

	-- Card Shadow
	Def.Quad{
		InitCommand = function(self)
			self:zoomto(leftW, leftH):xy(4, 4):diffuse(COLOR.MainHighlight)
		end
	},
	-- Card Border
	UIElements.Border(leftW, leftH, 1)..{
		InitCommand = function(self)
			self:diffuse(COLOR.MainBorder)
		end
	},
	-- Card Background
	Def.Quad{
		InitCommand = function(self)
			self:zoomto(leftW, leftH):diffuse(COLOR.MainBackground)
		end
	},

	-- Title Bar
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(0, -leftH/2 + 25):zoom(0.6):diffuse(COLOR.TextSub2)
			self:settext("GRADE & SCORE")
		end
	},

	-- Grade Text
	LoadFont("DFPGothic 64px")..{
		InitCommand = function(self)
			self:xy(0, -40):zoom(1.4)
		end,
		OnCommand = function(self)
			local grade = GetEvaluationGrade(pss)
			self:settext(GetGradeString(grade))
			self:diffuse(GetGradeColor(grade))
		end
	},

	-- Wifescore Percentage
	LoadFont("DFPGothic 64px")..{
		InitCommand = function(self)
			self:xy(0, 45):zoom(0.65):diffuse(COLOR.TextMain)
		end,
		OnCommand = function(self)
			local wife = 0.9845
			if pss and pss.GetWifeScore then
				wife = pss:GetWifeScore()
			elseif pss and pss.GetPercentScore then
				wife = pss:GetPercentScore()
			end
			local percent = wife * 100
			self:settextf(percent >= 99.7 and "%.4f%%" or "%.2f%%", percent)
		end
	},
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(0, 72):zoom(0.45):diffuse(COLOR.TextSub2)
			self:settext("WIFESCORE")
		end
	},

	-- Max Combo
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(0, 115):zoom(0.6):diffuse(COLOR.TextSub1)
		end,
		OnCommand = function(self)
			local combo = 0
			if pss and pss.MaxCombo then
				combo = pss:MaxCombo()
			end
			self:settextf("Max Combo: %d", combo)
		end
	},

	-- Clear Type Badge
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(0, 142):zoom(0.5):diffuse(COLOR.MainHighlight)
		end,
		OnCommand = function(self)
			local clearType = getClearType(PLAYER, steps, pss)
			local status = getClearTypeText(clearType)
			self:settext(status):diffuse(getClearTypeColor(clearType))
		end
	}
}


-- Right Panel: Judgments Breakdown Card
local rightW = 420
local rightH = 370
local rightX = SCREEN_CENTER_X + 230

local judgments = {
	{ name = "Marvelous", scoreKey = "TapNoteScore_W1", color = color("#77CCFF") },
	{ name = "Perfect",   scoreKey = "TapNoteScore_W2", color = color("#FFDD44") },
	{ name = "Great",     scoreKey = "TapNoteScore_W3", color = color("#55EE77") },
	{ name = "Good",      scoreKey = "TapNoteScore_W4", color = color("#AA66FF") },
	{ name = "Bad",       scoreKey = "TapNoteScore_W5", color = color("#FF8833") },
	{ name = "Miss",      scoreKey = "TapNoteScore_Miss", color = color("#FF4444") },
}

local rightFrame = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(rightX, panelY)
	end,

	-- Card Shadow
	Def.Quad{
		InitCommand = function(self)
			self:zoomto(rightW, rightH):xy(4, 4):diffuse(COLOR.MainHighlight)
		end
	},
	-- Card Border
	UIElements.Border(rightW, rightH, 1)..{
		InitCommand = function(self)
			self:diffuse(COLOR.MainBorder)
		end
	},
	-- Card Background
	Def.Quad{
		InitCommand = function(self)
			self:zoomto(rightW, rightH):diffuse(COLOR.MainBackground)
		end
	},

	-- Title Bar
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(0, -rightH/2 + 25):zoom(0.6):diffuse(COLOR.TextSub2)
			self:settext("JUDGMENT BREAKDOWN")
		end
	}
}

-- Judgment Rows
for i, jg in ipairs(judgments) do
	local rowY = -rightH/2 + 55 + (i * 32)
	rightFrame[#rightFrame+1] = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(0, rowY)
		end,

		-- Judgment Name
		LoadFont("Common Normal")..{
			InitCommand = function(self)
				self:xy(-rightW/2 + 35, 0):halign(0):zoom(0.55):diffuse(jg.color)
				self:settext(jg.name)
			end
		},

		-- Judgment Count
		LoadFont("Common Normal")..{
			InitCommand = function(self)
				self:xy(rightW/2 - 35, 0):halign(1):zoom(0.6):diffuse(COLOR.TextMain)
			end,
			OnCommand = function(self)
				local count = 0
				if pss and pss.GetTapNoteScores then
					count = pss:GetTapNoteScores(jg.scoreKey)
				end
				self:settext(tostring(count))
			end
		}
	}
end

-- Divider Line
rightFrame[#rightFrame+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(0, 95):zoomto(rightW - 50, 1):diffuse(COLOR.MainBorder):diffusealpha(0.3)
	end
}

-- Holds & Mines Row
rightFrame[#rightFrame+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(0, 125)
	end,

	-- Holds Info
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-rightW/2 + 35, 0):halign(0):zoom(0.48):diffuse(COLOR.TextSub1)
		end,
		OnCommand = function(self)
			local held = 0
			local letgo = 0
			if pss and pss.GetHoldNoteScores then
				held = pss:GetHoldNoteScores('HoldNoteScore_Held')
				letgo = pss:GetHoldNoteScores('HoldNoteScore_LetGo')
			end
			self:settextf("Holds: %d OK / %d NG", held, letgo)
		end
	},

	-- Mines Info
	LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(rightW/2 - 35, 0):halign(1):zoom(0.48):diffuse(COLOR.TextSub1)
		end,
		OnCommand = function(self)
			local mines = 0
			if pss and pss.GetTapNoteScores then
				mines = pss:GetTapNoteScores('TapNoteScore_HitMine')
			end
			self:settextf("Mines Hit: %d", mines)
		end
	}
}

t[#t+1] = rightFrame


-- Bottom Navigation Bar & Interactive QuadButtons
local btnW = 200
local btnH = 45
local btnY = SCREEN_HEIGHT - 55

-- Song Select Button (Back)
t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X - 130, btnY)
	end,

	Def.Quad{
		Name = "BtnBg",
		InitCommand = function(self)
			self:zoomto(btnW, btnH):diffuse(COLOR.MainBackground)
		end
	},
	UIElements.Border(btnW, btnH, 1)..{
		InitCommand = function(self)
			self:diffuse(COLOR.MainBorder)
		end
	},
	LoadFont("Common Normal")..{
		Name = "BtnText",
		InitCommand = function(self)
			self:zoom(0.6):diffuse(COLOR.TextMain):settext("◄  SONG SELECT")
		end
	},

	UIElements.QuadButton(1, 1)..{
		InitCommand = function(self)
			self:zoomto(btnW, btnH):diffusealpha(0)
		end,
		MouseOverCommand = function(self)
			local parent = self:GetParent()
			parent:GetChild("BtnBg"):diffuse(COLOR.MainHighlight)
			parent:GetChild("BtnText"):diffuse(COLOR.TextMainLight)
		end,
		MouseOutCommand = function(self)
			local parent = self:GetParent()
			parent:GetChild("BtnBg"):diffuse(COLOR.MainBackground)
			parent:GetChild("BtnText"):diffuse(COLOR.TextMain)
		end,
		MouseClickCommand = function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMusic"):StartTransitioningScreen("SM_GoToNextScreen")
		end
	}
}

-- Continue Button (Next Screen)
t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X + 130, btnY)
	end,

	Def.Quad{
		Name = "BtnBg",
		InitCommand = function(self)
			self:zoomto(btnW, btnH):diffuse(COLOR.MainHighlight)
		end
	},
	UIElements.Border(btnW, btnH, 1)..{
		InitCommand = function(self)
			self:diffuse(COLOR.MainBorder)
		end
	},
	LoadFont("Common Normal")..{
		Name = "BtnText",
		InitCommand = function(self)
			self:zoom(0.6):diffuse(COLOR.TextMainLight):settext("CONTINUE  ➔")
		end
	},

	UIElements.QuadButton(1, 1)..{
		InitCommand = function(self)
			self:zoomto(btnW, btnH):diffusealpha(0)
		end,
		MouseOverCommand = function(self)
			local parent = self:GetParent()
			parent:GetChild("BtnBg"):diffuse(COLOR.MainBorder)
			parent:GetChild("BtnText"):diffuse(COLOR.TextMainLight)
		end,
		MouseOutCommand = function(self)
			local parent = self:GetParent()
			parent:GetChild("BtnBg"):diffuse(COLOR.MainHighlight)
			parent:GetChild("BtnText"):diffuse(COLOR.TextMainLight)
		end,
		MouseClickCommand = function(self)
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	}
}

return t
