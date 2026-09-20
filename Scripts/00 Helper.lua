
PLAYER = PLAYER_1

GRADE_LABELS = {
	Grade_Tier01 = "AAAAA", Grade_Tier02 = "AAAA:", Grade_Tier03 = "AAAA.", Grade_Tier04 = "AAAA",
	Grade_Tier05 = "AAA:", Grade_Tier06 = "AAA.", Grade_Tier07 = "AAA",
	Grade_Tier08 = "AA:", Grade_Tier09 = "AA.", Grade_Tier10 = "AA",
	Grade_Tier11 = "A:", Grade_Tier12 = "A.", Grade_Tier13 = "A",
	Grade_Tier14 = "B", Grade_Tier15 = "C", Grade_Tier16 = "D",
	Grade_Failed = "F", Grade_None = "-",
}

function GetGradeString(grade)
	if not grade then return "N/A" end
	return GRADE_LABELS[tostring(grade)] or "CLEARED"
end

function GetDifficultyName(diff)
	if not diff then return "NORMAL" end
	local str = ToEnumShortString(diff)
	if str == "Beginner" then return "BEGINNER"
	elseif str == "Easy" then return "EASY"
	elseif str == "Medium" then return "NORMAL"
	elseif str == "Hard" then return "HARD"
	elseif str == "Challenge" then return "INSANE"
	elseif str == "Edit" then return "EDIT"
	else return string.upper(str) end
end

function Actor.PlayCommandsOnChildren(self, cmd, params)
    return self:RunCommandsOnChildren(function(self) self:playcommand(cmd, params) end)
end

function Actor.QueueCommandsOnChildren(self, cmd)
    return self:RunCommandsOnChildren(function(self) self:queuecommand(cmd) end)
end

function GetCommonBPM(bpms, lastBeat)
	local BPMtable = {}
	local curBPM = math.round(bpms[1][2])
	local curBeat = bpms[1][1]
	for _,v in ipairs(bpms) do
		if BPMtable[tostring(curBPM)] == nil then
			BPMtable[tostring(curBPM)] = (v[1] - curBeat)/curBPM
		else
			BPMtable[tostring(curBPM)] = BPMtable[tostring(curBPM)] + (v[1] - curBeat)/curBPM
		end
		curBPM = math.round(v[2])
		curBeat = v[1]
	end

	if BPMtable[tostring(curBPM)] == nil then
		BPMtable[tostring(curBPM)] = (lastBeat - curBeat)/curBPM
	else
		BPMtable[tostring(curBPM)] = BPMtable[tostring(curBPM)] + (lastBeat - curBeat)/curBPM
	end

	local maxBPM = 0
	local maxDur = 0
	for k,v in pairs(BPMtable) do
		if v > maxDur then
			maxDur = v
			maxBPM = tonumber(k)
		end
	end
	return maxBPM * GAMESTATE:GetSongOptionsObject('ModsLevel_Current'):MusicRate()
end
