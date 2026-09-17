local function safeCall(fn, fallback)
	local ok, value = pcall(fn)
	return ok and value or fallback
end

local function countChartsAndPacks()
	local songs = safeCall(function() return SONGMAN:GetAllSongs() end, {}) or {}
	local packs = safeCall(function() return SONGMAN:GetNumSongGroups() end, 0)
	local charts = 0
	for _, song in ipairs(songs) do
		local steps = safeCall(function() return song:GetAllSteps() end, {}) or {}
		charts = charts + #steps
	end
	return charts, packs
end

local function productVersion()
	return safeCall(function() return ProductVersion() end, "Unknown")
end

local function onlineText()
	local online = safeCall(function() return IsNetSMOnline() end, false)
	if not online then
		return "OFFLINE", "Not Available"
	end
	local server = safeCall(function() return GetServerName() end, "Not Available")
	return "ONLINE", (server ~= "" and server or "Not Available")
end

local charts, packs = countChartsAndPacks()
local weekdays = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"}
local themeVersion = "0.0.1"

local t = Def.ActorFrame{}
t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements", "overlay"))

-- Calendar and library summary, deliberately kept in the left half of the screen.
t[#t+1] = Def.ActorFrame{
	InitCommand = function(self) self:xy(34, SCREEN_CENTER_Y - 92) end,
	Def.Quad{
		Name = "CalendarRule",
		InitCommand = function(self) self:halign(0):valign(0):zoomto(280, 1):diffuse(COLOR.MainHighlight) end
	},
	LoadFont("Common Normal")..{
		Name = "DateText",
		InitCommand = function(self) self:halign(0):y(-26):zoom(0.72):diffuse(COLOR.TextMain) end,
		OnCommand = function(self) self:queuecommand("Update"):sleep(1):queuecommand("Update") end,
		UpdateCommand = function(self)
			local now = os.date("*t")
			self:settext(string.format("%04d-%02d-%02d  %02d:%02d:%02d", now.year, now.month, now.day, now.hour, now.min, now.sec))
			self:sleep(1):queuecommand("Update")
		end
	},
	LoadFont("Common Normal")..{
		Text = "TODAY",
		InitCommand = function(self) self:halign(0):y(12):zoom(0.55):diffuse(COLOR.TextSub2) end
	},
	Def.ActorFrame{
		Name = "WeekGrid",
		InitCommand = function(self) self:xy(145, 78) end,
		Def.Quad{
			InitCommand = function(self) self:zoomto(294, 34):diffuse(color("0,0,0,0.10")) end
		},
		Def.Quad{
			Name = "DayHighlight",
			InitCommand = function(self) self:zoomto(40, 34):diffuse(COLOR.MainHighlight):diffusealpha(0.55) end,
			OnCommand = function(self) self:x((os.date("*t").wday - 4) * 40) end
		}
	},
	LoadFont("Common Normal")..{
		Text = string.format("%d charts  /  %d packs", charts, packs),
		InitCommand = function(self) self:halign(0):y(124):zoom(0.6):diffuse(COLOR.TextSub2) end
	}
}

for i, day in ipairs(weekdays) do
	local x = (i - 4) * 40
	t[2][#t[2] + 1] = LoadFont("Common Normal") .. {
		Text = day,
		InitCommand = function(self) self:xy(145 + x, 78):zoom(0.42):diffuse(color("#222222")) end
	}
end

-- Version/theme details and network state sit in the two bottom corners.
t[#t+1] = LoadFont("Common Normal")..{
	Text = string.format("Etterna %s\nRain Cannon %s", productVersion(), themeVersion),
	InitCommand = function(self) self:xy(18, SCREEN_HEIGHT - 30):halign(0):valign(1):zoom(0.48):diffuse(COLOR.TextSub2) end
}
t[#t+1] = LoadFont("Common Normal")..{
	Name = "NetworkInfo",
	InitCommand = function(self) self:xy(SCREEN_WIDTH - 18, SCREEN_HEIGHT - 30):halign(1):valign(1):zoom(0.48):diffuse(COLOR.TextSub2) end,
	OnCommand = function(self)
		local status, server = onlineText()
		self:settext(status .. "\n" .. server)
	end
}

return t
