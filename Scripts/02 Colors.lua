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
}

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