local mainMaxWidth = 390
local subMaxWidth = 390
local artistMaxWidth = 390

local mainMaxWidthHighScore = 192
local subMaxWidthHighScore = 280
local artistMaxWidthHighScore = 280/0.8

function TextBannerAfterSet(self,param)
	local Title = self:GetChild("Title")
	local Artist = self:GetChild("Artist")
	
	Title:maxwidth(mainMaxWidth/0.7)
	Title:xy(75,-8)
	Title:zoom(0.7)
	
	Artist:zoom(0.5)
	Artist:maxwidth(artistMaxWidth/0.5)
	Artist:xy(75,8)
end
