local transitioned = false

local function GoNext()
	if not transitioned then
		transitioned = true
		local screen = SCREENMAN:GetTopScreen()
		if screen then
			screen:StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
end

local function InputHandler(event)
	if not event or not event.type then return end
	if event.type == "InputEventType_FirstPress" then
		GoNext()
	end
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:rotationz(0)
	end,
	OnCommand = function(self)
		local screen = SCREENMAN:GetTopScreen()
		if screen then
			screen:AddInputCallback(InputHandler)
		end
		-- Explicit Lua timer to guarantee screen auto-transitions after 2.5 seconds
		self:sleep(2.5):queuecommand("AutoNext")
	end,
	AutoNextCommand = function(self)
		GoNext()
	end
}


-- Central Logo / Theme Branding
local logoY = SCREEN_CENTER_Y - 30

-- Highlight Accent Quad
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X - 10, logoY + 12)
		self:zoomto(360, 20)
		self:skewx(-0.2)
		self:diffuse(COLOR.MainHighlight)
		self:diffusealpha(0):sleep(0.1):smooth(0.4):diffusealpha(1)
	end
}

-- Title Text
t[#t+1] = LoadFont("DFPGothic 64px")..{
	Text = "WILLOW HEART",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, logoY)
		self:diffuse(COLOR.TextMain)
		self:zoom(0.85)
		self:diffusealpha(0):sleep(0.1):smooth(0.4):diffusealpha(1)
	end
}

-- Subtitle / Theme Badge
t[#t+1] = LoadFont("Common Normal")..{
	Text = "ETTERNA THEME",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, logoY + 38)
		self:diffuse(COLOR.TextSub2)
		self:zoom(0.5)
		self:diffusealpha(0):sleep(0.2):smooth(0.4):diffusealpha(1)
	end
}

-- Animated Dots (Accelerate & Decelerate Left to Right)
local numDots = 6
local startX = SCREEN_CENTER_X - 150
local midX   = SCREEN_CENTER_X
local endX   = SCREEN_CENTER_X + 150
local dotY   = SCREEN_CENTER_Y + 70
local travelTime = 1.0

local dotsContainer = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(0, 0)
	end
}

-- Dot Track Background Line
dotsContainer[#dotsContainer+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, dotY)
		self:zoomto(320, 2)
		self:diffuse(COLOR.MainBorder)
		self:diffusealpha(0.2)
	end
}

for i = 1, numDots do
	local delay = (i - 1) * 0.16
	dotsContainer[#dotsContainer+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(startX, dotY)
			self:zoom(6)
			self:diffuse(COLOR.MainHighlight)
			self:diffusealpha(0)
		end,
		OnCommand = function(self)
			self:sleep(delay):queuecommand("AnimLoop")
		end,
		AnimLoopCommand = function(self)
			self:xy(startX, dotY)
				:diffusealpha(0)
				:zoom(4)
				:accelerate(travelTime * 0.5)
				:x(midX)
				:diffusealpha(0.95)
				:zoom(8)
				:decelerate(travelTime * 0.5)
				:x(endX)
				:diffusealpha(0)
				:zoom(4)
				:sleep(0.1)
				:queuecommand("AnimLoop")
		end
	}
end

t[#t+1] = dotsContainer

-- Click anywhere to dismiss Init screen
t[#t+1] = UIElements.QuadButton(1, 1)..{
	InitCommand = function(self)
		self:FullScreen():diffusealpha(0)
	end,
	MouseClickCommand = function(self)
		GoNext()
	end
}

t[#t+1] = LoadActor("../_mouse.lua", "ScreenInit")

return t
