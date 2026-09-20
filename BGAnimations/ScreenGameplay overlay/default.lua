-- Gameplay HUD
-- The gameplay screen is intentionally quiet, so keep the live information
-- compact and readable over the playfield.

local pss
local player = PLAYER_1

local judges = {
	{ key = "TapNoteScore_W1", name = "MARV", color = color("1,1,1,1") },
	{ key = "TapNoteScore_W2", name = "PERF", color = color("1,0.82,0.15,1") },
	{ key = "TapNoteScore_W3", name = "GREAT", color = color("0.3,1,0.45,1") },
	{ key = "TapNoteScore_W4", name = "GOOD", color = color("0.35,0.7,1,1") },
	{ key = "TapNoteScore_W5", name = "BAD", color = color("1,0.35,0.4,1") },
	{ key = "TapNoteScore_Miss", name = "MISS", color = color("0.65,0.65,0.65,1") },
}

local function stats()
	local stage = STATSMAN:GetCurStageStats()
	pss = stage and stage:GetPlayerStageStats(player) or nil
	return pss
end

local function wifePercent()
	local s = stats()
	if not s then return 0 end

	if s.GetCurWifeScore and s.GetMaxWifeScore then
		local current = s:GetCurWifeScore()
		local maximum = s:GetMaxWifeScore()
		if maximum and maximum > 0 then return current / maximum * 100 end
	end

	if s.GetWifeScore then return s:GetWifeScore() * 100 end
	return 0
end

local function wifeColor(percent)
	if percent >= 99.9935 then return color("1,1,1,1") end
	if percent >= 99.955 then return color("0,0.9,1,1") end
	if percent >= 99.7 then return color("1,0.82,0.15,1") end
	if percent >= 93 then return color("0.35,1,0.45,1") end
	if percent >= 80 then return color("1,0.55,0.7,1") end
	if percent >= 70 then return color("0.4,0.7,1,1") end
	if percent >= 60 then return color("0.75,0.4,1,1") end
	return color("0.7,0.7,0.7,1")
end

local function updateCounters(frame)
	local s = stats()
	for i, judgment in ipairs(judges) do
		local count = 0
		if s and s.GetTapNoteScores then
			count = s:GetTapNoteScores(judgment.key) or 0
		end
		local row = frame:GetChild("Judge" .. i)
		if row then row:GetChild("Count"):settext(tostring(count)) end
	end
end

local t = Def.ActorFrame{
	-- Keep the existing stage-information handoff intact.
	OnCommand = function(self)
		if _G.willowHeartStageInformationShown then
			_G.willowHeartStageInformationShown = false
			return
		end

		local screen = SCREENMAN:GetTopScreen()
		if screen then
			screen:SetNextScreenName("ScreenStageInformation")
			screen:StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,
}

-- Wife% and current combo sit above the receptors, out of the way of notes.
t[#t + 1] = Def.ActorFrame{
	InitCommand = function(self) self:xy(SCREEN_CENTER_X, 34):queuecommand("Update") end,
	UpdateCommand = function(self) self:GetChild("Wife"):playcommand("Update"); self:GetChild("Combo"):playcommand("Update"); self:sleep(0.05):queuecommand("Update") end,
	Def.Quad{ InitCommand = function(self) self:zoomto(150, 52):diffuse(color("0,0,0,0.58")) end },
	LoadFont("Common Normal") .. {
		Name = "Wife",
		InitCommand = function(self) self:y(-5):zoom(0.95):shadowlength(1):settext("0.00%") end,
		UpdateCommand = function(self)
			local percent = wifePercent()
			self:settextf("%.2f%%", percent):diffuse(wifeColor(percent))
		end,
	},
	LoadFont("Common Normal") .. {
		Name = "Combo",
		InitCommand = function(self) self:y(17):zoom(0.3):diffuse(color("0.75,0.75,0.75,1")):settext("COMBO 0") end,
		UpdateCommand = function(self)
			local s = stats()
			local combo = s and s:GetCurrentCombo() or 0
			self:settextf("COMBO %d", combo)
		end,
	},
}

-- Compact W1-Miss counter in the upper-right corner.
local counter = Def.ActorFrame{
	Name = "JudgementCounter",
	InitCommand = function(self) self:xy(SCREEN_WIDTH - 88, 58):queuecommand("Update") end,
	UpdateCommand = function(self) updateCounters(self); self:sleep(0.05):queuecommand("Update") end,
}

for i, judgment in ipairs(judges) do
	counter[#counter + 1] = Def.ActorFrame{
		Name = "Judge" .. i,
		InitCommand = function(self) self:y((i - 1) * 15) end,
		LoadFont("Common Normal") .. { InitCommand = function(self) self:x(-40):halign(0):zoom(0.28):diffuse(judgment.color):settext(judgment.name) end },
		LoadFont("Common Normal") .. { Name = "Count", InitCommand = function(self) self:x(40):halign(1):zoom(0.3):settext("0") end },
	}
end
t[#t + 1] = counter

-- Timing error bar: center is on-time, left is early, right is late.
local errorBar = Def.ActorFrame{
	Name = "ErrorBar",
	InitCommand = function(self) self:xy(SCREEN_CENTER_X, SCREEN_HEIGHT - 62) end,
	JudgmentMessageCommand = function(self, params)
		local offset = params.TapNoteOffset
		if not offset or params.TapNoteScore == "TapNoteScore_Miss" then return end
		local x = math.max(-116, math.min(116, offset * 1000 / 45 * 116))
		for i = 24, 2, -1 do
			local previous = self:GetChild("Marker" .. (i - 1))
			local current = self:GetChild("Marker" .. i)
			if previous and current then current:x(previous:GetX()):diffuse(previous:GetDiffuse()) end
		end
		local marker = self:GetChild("Marker1")
		if marker then marker:x(x):diffuse(offset < 0 and color("1,0.45,0.45,0.9") or color("0.45,0.7,1,0.9")) end
	end,
	Def.Quad{ InitCommand = function(self) self:zoomto(240, 3):diffuse(color("0,0,0,0.7")) end },
	Def.Quad{ InitCommand = function(self) self:zoomto(2, 13):diffuse(color("1,1,1,0.9")) end },
	LoadFont("Common Normal") .. { InitCommand = function(self) self:y(11):zoom(0.24):diffuse(color("0.7,0.7,0.7,1")):settext("EARLY                 ON TIME                 LATE") end },
}

for i = 1, 24 do
	errorBar[#errorBar + 1] = Def.Quad{
		Name = "Marker" .. i,
		InitCommand = function(self) self:zoomto(3, 8):diffuse(color("1,1,1,0")) end,
	}
end
t[#t + 1] = errorBar

return t
