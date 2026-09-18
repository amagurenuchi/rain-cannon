-- Uses Etterna's dedicated SelectMusic out-transition hook.

local translated_info = {
	PressStart = THEME:GetString("ScreenSelectMusic", "PressStartForOptions"),
	EnteringOptions = THEME:GetString("ScreenSelectMusic", "EnteringOptions"),
}

local t = Def.ActorFrame{}

t[#t + 1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
	end,
	OnCommand = function(self)
		self:diffuse(color("0,0,0,0")):sleep(0.1):linear(0.1):diffusealpha(1)
	end,
}

	t[#t + 1] = Def.ActorFrame{
	InitCommand = function(self)
		self:diffusealpha(0)
	end,
	ShowPressStartForOptionsCommand = function(self)
		self:zoom(0.9):smooth(0.2):diffusealpha(1):zoom(1)
	end,
	ShowEnteringOptionsCommand = function(self)
	end,
	HidePressStartForOptionsCommand = function(self)
		self:decelerate(0.15):diffusealpha(0)
	end,
	Def.Quad{
		InitCommand = function(self)
			self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			self:zoomto(SCREEN_WIDTH, 80)
			self:diffusetopedge(Brightness(COLOR.MainHighlight, 0.45))
			self:diffusebottomedge(Brightness(COLOR.MainBackground, 0.15))
		end,
	},
	LoadFont("DFPGothic 64px")..{
		InitCommand = function(self)
			self:Center():diffusebottomedge(0.7, 0.7, 0.7, 1):shadowlength(1.5)
		end,
		ShowPressStartForOptionsCommand = function(self)
			self:settext(translated_info.PressStart):diffusealpha(0):zoom(0.15)
			self:decelerate(0.2):zoom(0.55):diffusealpha(1)
		end,
		ShowEnteringOptionsCommand = function(self)
			self:finishtweening():settext(translated_info.EnteringOptions)
		end,
		HidePressStartForOptionsCommand = function(self)
			self:decelerate(0.15):diffusealpha(0)
		end,
	},
}

return t
