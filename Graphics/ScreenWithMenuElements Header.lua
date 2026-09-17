local height = 20
local top

local t = Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		if top then
			local screenName = top:GetName()
			local title = ""
			if THEME:HasMetric(screenName, "HeaderTitle") then
				title = THEME:GetMetric(screenName, "HeaderTitle")
			end
			if title == nil or title == "" then
				title = Screen.String("HeaderText")
			end
			if title and title ~= "" then
				self:GetChild("HeaderTitle"):settext(title)
			end
		end
	end
}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(-30,45)
		self:halign(0)
		self:zoomto(500,15)
		self:skewx(-0.02)
		self:diffuse(COLOR.MainHighlight)
	end
}

t[#t+1] = LoadFont("DFPGothic 64px")..{
	Name = "HeaderTitle",
	Text = "Welcome Back",
	InitCommand = function (self)
		self:diffuse(COLOR.TextMain)
		self:zoom(0.6)
		self:halign(0)
		self:xy(10,30)
	end,
	UpdateScreenHeaderMessageCommand = function(self,param)
		self:settext(param.Header)
	end
}

return t