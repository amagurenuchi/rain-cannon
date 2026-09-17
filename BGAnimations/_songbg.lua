local Magnitude = 0.03
local MaxDistX = SCREEN_WIDTH*Magnitude
local MaxDistY = SCREEN_HEIGHT*Magnitude

local Opacity = 0.2

local function GetPosX()
	local offset = Magnitude*(INPUTFILTER:GetMouseX()-SCREEN_CENTER_X)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),MaxDistX)
		end
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),MaxDistX)
		end
	end
	if neg then
		return SCREEN_CENTER_X+offset
	else 
		return SCREEN_CENTER_X-offset
	end
end

local function GetPosY()
	local offset = Magnitude*(INPUTFILTER:GetMouseY()-SCREEN_CENTER_Y)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),MaxDistY)
		end
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),MaxDistY)
		end
	end
	if neg then
		return SCREEN_CENTER_Y+offset
	else 
		return SCREEN_CENTER_Y-offset
	end
end

local t = Def.ActorFrame{}


t[#t+1] = Def.ActorFrame{
	Name="MouseXY",
	Def.Sprite {
		OnCommand=function(self)
			self:smooth(0.5):diffusealpha(0):queuecommand("ModifySongBackground")
		end,
		CurrentSongChangedMessageCommand=function(self)
			self:stoptweening():smooth(0.5):diffusealpha(0):queuecommand("ModifySongBackground")
		end,
		ModifySongBackgroundCommand=function(self)
			self:finishtweening()
			if GAMESTATE:GetCurrentSong() then
				local song = GAMESTATE:GetCurrentSong()
				if song:HasBackground() then
					self:visible(true)
					self:LoadBackground(song:GetBackgroundPath())

					self:scaletocover(0-MaxDistY/2,0-MaxDistY/2,SCREEN_WIDTH+MaxDistX/2,SCREEN_BOTTOM+MaxDistY/2)

					self:smooth(0.5)
					self:diffusealpha(Opacity)
				end
			else
				self:visible(false)
			end
		end,
		OffCommand=function(self)
			self:smooth(0.5):diffusealpha(0)
		end	
	}
}


local function Update(self)
    self:GetChild("MouseXY"):xy(GetPosX()-SCREEN_CENTER_X,GetPosY()-SCREEN_CENTER_Y)
end

t.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end

return t
