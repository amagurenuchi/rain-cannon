local ClearType = {
	[1]="ClearType_MFC", [2]="ClearType_WF", [3]="ClearType_SDP", [4]="ClearType_PFC",
	[5]="ClearType_BF", [6]="ClearType_SDG", [7]="ClearType_FC", [8]="ClearType_MF",
	[9]="ClearType_SDCB", [10]="ClearType_Clear", [11]="ClearType_Failed", [12]="ClearType_Invalid",
	[13]="ClearType_Noplay", [14]="ClearType_None",
}

local ClearTypeLevel = {}
for level, name in ipairs(ClearType) do ClearTypeLevel[name] = level end

function getClearTypeLevel(name) return ClearTypeLevel[name] or 18 end
function getClearTypeText(name) return THEME:GetString("ClearTypes", name) end
function getClearTypeShortText(name)
	return THEME:HasString("ClearTypesShort", name) and THEME:GetString("ClearTypesShort", name) or getClearTypeText(name)
end
function getClearTypeColor(name) return GetClearTypeColor(name) end

local function clearLevel(pn, steps, score)
	if not score or not steps then return 13 end
	if score:GetWifeGrade() == "Grade_Failed" then return 15 end
	local function tapCount(name)
		return score.GetTapNoteScores and score:GetTapNoteScores(name) or score:GetTapNoteScore(name)
	end
	local w1, w2, w3 = tapCount("TapNoteScore_W1"), tapCount("TapNoteScore_W2"), tapCount("TapNoteScore_W3")
	local w4, w5, miss = tapCount("TapNoteScore_W4"), tapCount("TapNoteScore_W5"), tapCount("TapNoteScore_Miss")
	local notes = steps:GetRadarValues(pn):GetValue(GAMESTATE:CountNotesSeparately() and "RadarCategory_Notes" or "RadarCategory_TapsAndHolds")
	local holds = steps:GetRadarValues(pn):GetValue("RadarCategory_Holds") + steps:GetRadarValues(pn):GetValue("RadarCategory_Rolls")
	local held = score.GetHoldNoteScores and score:GetHoldNoteScores("HoldNoteScore_Held") or score:GetHoldNoteScore("HoldNoteScore_Held")
	if w1+w2+w3+w4+w5+miss ~= notes then return 16 end
	if w1 == notes and held == holds then return 1 end
	if w1+w2 == notes and held == holds then return w2 == 1 and 2 or (w2 < 10 and 3 or 4) end
	local bad = w4+w5+miss
	if bad == 0 then return w3 == 1 and 5 or (w3 < 10 and 6 or 7) end
	if bad == 1 then return 8 end
	if bad < 10 then return 9 end
	return 10
end

function getClearType(pn, steps, score) return ClearType[clearLevel(pn, steps, score)] end
