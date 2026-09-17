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


if not getClearType then
	function getClearType(pn, steps, score)
		if not score then return "ClearType_Noplay" end
		if score:GetWifeGrade() == "Grade_Failed" then return "ClearType_Failed" end
		if score.FullComboOfScore and score:FullComboOfScore("TapNoteScore_W1") then return "ClearType_MFC" end
		if score.FullComboOfScore and score:FullComboOfScore("TapNoteScore_W2") then return "ClearType_PFC" end
		if score.FullComboOfScore and score:FullComboOfScore("TapNoteScore_W3") then return "ClearType_FC" end
		return "ClearType_Clear"
	end
	function getClearTypeShortText(name)
		local short = { ClearType_MFC="Marv F-Combo", ClearType_PFC="Perf F-Combo", ClearType_FC="F-Combo", ClearType_Failed="Failed", ClearType_Noplay="No Play" }
		return short[name] or tostring(name):gsub("ClearType_", "")
	end
	function getClearTypeText(name) return getClearTypeShortText(name) end
	function getClearTypeColor(name) return GetClearTypeColor(name) end
end


if not GetGradeString then
	local labels = GRADE_LABELS or {
		Grade_Tier01 = "AAAAA", Grade_Tier02 = "AAAA:", Grade_Tier03 = "AAAA.", Grade_Tier04 = "AAAA",
		Grade_Tier05 = "AAA:", Grade_Tier06 = "AAA.", Grade_Tier07 = "AAA",
		Grade_Tier08 = "AA:", Grade_Tier09 = "AA.", Grade_Tier10 = "AA",
		Grade_Tier11 = "A:", Grade_Tier12 = "A.", Grade_Tier13 = "A",
		Grade_Tier14 = "B", Grade_Tier15 = "C", Grade_Tier16 = "D",
		Grade_Failed = "F", Grade_None = "--",
	}
	function GetGradeString(grade)
		if not grade then return "N/A" end
		return labels[tostring(grade)] or "CLEARED"
	end
end

function GetRatingColor(rating)
	return HSV(((198 - math.floor(rating,40)*(324/40))%360), 0.5, 0.75)
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
