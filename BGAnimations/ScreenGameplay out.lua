-- Gameplay exit transition.
-- Cover the playfield before the next screen is shown.

return Def.ActorFrame{
	Def.Quad{
		InitCommand = function(self)
			self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
				:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
				:diffuse(color("0,0,0,0"))
		end,
		OnCommand = function(self)
			self:accelerate(0.22):diffusealpha(1)
		end,
	},
}
