COLOR = {
	MainBackground = color("#FFFFFF"),		-- White
	MainHighlight = color("#FFB4B4"),		-- Pink
	MainBorder = color("#4C4C4C"),			-- Black 70%
	UICaution = "", 						-- Yellow
	UIWarning = "", 						-- Red
	UINew = "", 							-- Blue
	UIAction = "", 							-- Green
	TextMain = color("#4C4C4C"),			-- Black 70%
	TextSub1 = color("#666666"),			-- Black 60%
	TextSub2 = color("#808080"),			-- Black 50%/Grey
	TextMainLight = color("#FFFFFF"),		-- White
	TextSub1Light = color("#b2b2b2"),		-- Black 30%
	TextSub2Light = color("#999999"),		-- Black 40%

	SongLong = HSV(36,0.5,0.75),			-- Orange
	SongMarathon = HSV(342,0.5,0.75),		-- Red
	SongUltraMarathon = HSV(288,0.5,0.75),	-- Purple

	GradeColors = {
		Grade_Tier01 = "#000000",
		Grade_Tier02 = "#66CCFF",
		Grade_Tier03 = "#66CCFF",
		Grade_Tier04 = "#66CCFF",
		Grade_Tier05 = "#EEBB00",
		Grade_Tier06 = "#EEBB00",
		Grade_Tier07 = "#EEBB00",
		Grade_Tier08 = "#66CC66",
		Grade_Tier09 = "#66CC66",
		Grade_Tier10 = "#66CC66",
		Grade_Tier11 = "#DA5757",
		Grade_Tier12 = "#DA5757",
		Grade_Tier13 = "#DA5757",
		Grade_Tier14 = "#5B78BB",
		Grade_Tier15 = "#C97BFF",
		Grade_Tier16 = "#8C6239",
		Grade_Failed = "#CDCDCD",
	},

	ClearTypeColors = {
		ClearType_MFC = "#66CCFF", ClearType_WF = "#DDDDDD", ClearType_SDP = "#CC8800",
		ClearType_PFC = "#EEAA00", ClearType_BF = "#999999", ClearType_SDG = "#448844",
		ClearType_FC = "#66CC66", ClearType_MF = "#CC6666", ClearType_SDCB = "#33CCFF",
		ClearType_Clear = "#33AAFF",
		ClearType_Failed = "#E61E25",
		ClearType_Invalid = "#E61E25", ClearType_Noplay = "#666666", ClearType_None = "#666666",
	},
}

function GetGradeColor(grade)
	local key = tostring(grade)
	return color(COLOR.GradeColors[key] or "#666666")
end

function GetClearTypeColor(clearType)
	return color(COLOR.ClearTypeColors[tostring(clearType)] or "#666666")
end


function GetRatingColor(rating)
	return HSV(((198 - math.min(rating,40)*(324/40))%360), 0.5, 0.75)
end

function GetSongMSDColor(song)
	if not song or not song.GetAllSteps then return color("#4C4C4C") end
	local rate = 1
	local options = GAMESTATE:GetSongOptionsObject('ModsLevel_Current')
	if options and options.MusicRate then rate = options:MusicRate() end
	local total, count = 0, 0
	for _, steps in ipairs(song:GetAllSteps() or {}) do
		if steps and steps.GetMSD then
			local msd = steps:GetMSD(rate, 1)
			if msd and msd == msd and msd >= 0 then
				total = total + msd
				count = count + 1
			end
		end
	end
	return count > 0 and GetRatingColor(total / count) or color("#4C4C4C")
end

function ApplyRawMSDColor(actor, song)
	if not actor then return end
	local c = GetSongMSDColor(song)
	actor:diffuse(c):diffusetopedge(c):diffusebottomedge(c)
		:diffuseleftedge(c):diffuserightedge(c)
		:diffusealpha(1):strokecolor(c):glow(color("#00000000"))
		:shadowlength(0):blend("BlendMode_Normal")
end

function GetSongLengthColor(t)
	if t < PREFSMAN:GetPreference("LongVerSongSeconds") then
		return COLOR.TextMain
	elseif t < PREFSMAN:GetPreference("MarathonVerSongSeconds") then
		return COLOR.SongLong
	elseif t < PREFSMAN:GetPreference("MarathonVerSongSeconds")*2 then
		return COLOR.SongMarathon
	else
		return COLOR.SongUltraMarathon
	end
end
