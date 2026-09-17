local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:FullScreen()
		self:diffuse(COLOR.MainBackground)
	end
}

t[#t+1] = LoadActor("../_songbg.lua")


local intervals = {22, 31.5, 44, 63, 88, 125, 177, 250, 355, 500, 710, 1000, 1420, 2000, 2840, 4000, 5680}

if audioVisualizer then
	t[#t+1] = audioVisualizer:new{
		x = 0,
		y = SCREEN_HEIGHT,
		maxHeight = SCREEN_HEIGHT/2,
		width = SCREEN_WIDTH,
		freqIntervals = audioVisualizer.multiplyIntervals(intervals, 5),
		color = color("#FFFFFF"),
		spacing = -15,
		onBarUpdate = function(self)
			local rand = math.random()
			self:diffuse(HSVA(rand*360, 0.5, 0.9, 0.2))
			self:fadetop(1)
		end
	}
end

return t
