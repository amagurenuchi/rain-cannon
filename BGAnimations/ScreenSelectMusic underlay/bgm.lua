local curSong = nil
local start = 0
local delay = 0.02
local startFromPreview = true
local curPath = ""
local sampleStart = 0
local musicLength = 0
local sampleEvent = false


-- SongPreview == 1 (SM STYLE)
-- 		Disable this stuff, loops from SampleStart to SampleStart+SampleLength

-- SongPreview == 2 (current osu!)
-- 		Loops from SampleStart to end of the song.
--		If a player exits midway in a song, play from last point to end of song, then loop from SampleStart.

-- SongPreview == 3 (old osu!)
-- 		Play from SampleStart to end of the song. then Loop from the start of the song to the end.
--		If a player exits midway in a song, play from last point to end of song, then loop from start.


local deltaSum = 0
local function playMusic(self, delta)
	deltaSum = deltaSum + delta

	if deltaSum > delay and sampleEvent then
		local s = SCREENMAN:GetTopScreen()
		if s:GetName() == "ScreenSelectMusic" then
			if s:GetMusicWheel():IsSettled() then
				deltaSum = 0
				if curSong and curPath then
					if startFromPreview then -- When starting from preview point
						startFromPreview = false
						amountOfWait = musicLength - sampleStart
						SOUND:PlayMusicPart(curPath,sampleStart,amountOfWait,2,2,false,true,true)
						self:SetUpdateFunctionInterval(amountOfWait)

					else -- When starting from start of from exit point.
						amountOfWait = musicLength - start

						SOUND:PlayMusicPart(curPath,start,amountOfWait,2,2,true,true,false)
						self:SetUpdateFunctionInterval(math.max(0.02, amountOfWait))
						start = 0
					end
				end
			end
		end
	else
		self:SetUpdateFunctionInterval(0.025)
	end
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:SetUpdateFunction(playMusic)
	end,
	CurrentSongChangedMessageCommand = function(self)
		sampleEvent = false
		SOUND:StopMusic()
		deltaSum = 0
		curSong = GAMESTATE:GetCurrentSong()
		if curSong ~= nil then
			curPath = curSong:GetMusicPath()
			if not curPath then
				SCREENMAN:SystemMessage("Invalid music file path.")
				return
			end
			sampleStart = curSong:GetSampleStart()
			musicLength = curSong:MusicLengthSeconds()
			startFromPreview = start == 0
			self:SetUpdateFunctionInterval(0.002)
		end
	end,
	PlayingSampleMusicMessageCommand = function(self)
		sampleEvent = true
		self:SetUpdateFunctionInterval(0.002)
		SOUND:StopMusic()
	end,
	CurrentRateChangedMessageCommand = function(self, params)
		amountOfWait = amountOfWait / (1 / params.oldRate) / params.rate -- fun math, this works.
		self:SetUpdateFunctionInterval(amountOfWait)
	end,
	PreviewNoteFieldDeletedMessageCommand = function(self)
		sampleEvent = true
		self:SetUpdateFunctionInterval(0.002)
		SOUND:StopMusic()
	end
}

return t