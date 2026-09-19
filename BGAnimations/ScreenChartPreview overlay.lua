local pn = PLAYER_1
local song = GAMESTATE:GetCurrentSong()
local steps = GAMESTATE:GetCurrentSteps(pn)

local bg = color("#10141c")
local panel = color("#202735")
local text = color("#f2f4f8")
local subtext = color("#aeb7c8")
local accent = COLOR and COLOR.MainHighlight or color("#ffb4b4")
local sideW = 190
local topY = 28
local bottomY = SCREEN_HEIGHT - 28
local sideH = bottomY - topY

local function radar(category)
	if not steps or not steps.GetRadarValues then return 0 end
	local ok, values = pcall(function() return steps:GetRadarValues(pn) end)
	if not ok or not values then return 0 end
	local okValue, value = pcall(function() return values:GetValue(category) end)
	return okValue and math.floor(value or 0) or 0
end

local counts = {
	{"TAPS", "RadarCategory_Notes"},
	{"HOLDS", "RadarCategory_Holds"},
	{"ROLLS", "RadarCategory_Rolls"},
	{"MINES", "RadarCategory_Mines"},
	{"LIFTS", "RadarCategory_Lifts"},
	{"FAKES", "RadarCategory_Fakes"},
}

local function closePreview()
	local top = SCREENMAN:GetTopScreen()
	if top and top.Cancel then top:Cancel() end
end

local function bar(vertices, x, y, width, height, c)
	vertices[#vertices+1] = {{x, y-height, 0}, c}
	vertices[#vertices+1] = {{x+width, y-height, 0}, c}
	vertices[#vertices+1] = {{x+width, y, 0}, c}
	vertices[#vertices+1] = {{x, y, 0}, c}
end

local function densityColor(column, columns)
	if columns <= 1 then return accent end
	local value = 0.25 + (columns-column) * (0.65/(columns-1))
	return color(value, value, value)
end

local function drawDensity(self)
	if not steps or not steps.GetCDGraphVectors then return end
	local ok, vectors = pcall(function()
		local options = GAMESTATE:GetSongOptionsObject("ModsLevel_Current")
		local rate = options and options.MusicRate and options:MusicRate() or 1
		return steps:GetCDGraphVectors(math.max(0.05, rate))
	end)
	if not ok or not vectors or not vectors[1] then return end

	local columns = steps:GetNumColumns()
	local rows = #vectors[1]
	local graphH = sideH - 55
	local rowH = graphH / math.max(1, rows)
	local maxNPS = 1
	for _, row in ipairs(vectors[1]) do maxNPS = math.max(maxNPS, row * 2) end
	local graphW = sideW - 30
	local vertices = {}
	for column = 1, columns do
		if vectors[column] then
			for row = 1, rows do
				local value = vectors[column][row] or 0
				if value > 0 then
					bar(vertices, 15, 45 + math.min(row * rowH, graphH), value * 2 * graphW / maxNPS, math.max(1, rowH), densityColor(column, columns))
				end
			end
		end
	end
	self:SetVertices(vertices)
	self:SetDrawState{Mode="DrawMode_Quads", First=1, Num=#vertices}
	local label = self:GetParent():GetChild("MaxNPSText")
	if label then label:settext(string.format("%.1f max NPS", maxNPS/2)) end
end

local t = Def.ActorFrame{
	OnCommand=function(self)
		local top = SCREENMAN:GetTopScreen()
		if not top then return end
		top:AddInputCallback(function(event)
			local deviceButton = event.DeviceInput and event.DeviceInput.button
			if event.type == "InputEventType_FirstPress" and
				(deviceButton == "DeviceButton_space" or event.button == "Back" or event.button == "Start") then
				closePreview()
				return true
			end
			return false
		end)
	end,
}

t[#t+1] = Def.Quad{InitCommand=function(self) self:FullScreen():diffuse(bg) end}
t[#t+1] = Def.Quad{InitCommand=function(self) self:xy(sideW/2, (topY+bottomY)/2):zoomto(sideW, sideH):diffuse(panel):diffusealpha(0.96) end}
t[#t+1] = Def.Quad{InitCommand=function(self) self:xy(SCREEN_WIDTH-sideW/2, (topY+bottomY)/2):zoomto(sideW, sideH):diffuse(panel):diffusealpha(0.96) end}

t[#t+1] = LoadFont("Common Bold") .. {InitCommand=function(self) self:xy(18, topY+24):halign(0):zoom(0.42):diffuse(text):settext("NOTE COUNT") end}
for i, entry in ipairs(counts) do
	local y = topY + 65 + (i-1)*38
	t[#t+1] = LoadFont("Common Normal") .. {InitCommand=function(self) self:xy(18,y):halign(0):zoom(0.34):diffuse(subtext):settext(entry[1]) end}
	t[#t+1] = LoadFont("Common Bold") .. {InitCommand=function(self) self:xy(sideW-18,y):halign(1):zoom(0.38):diffuse(text):settext(tostring(radar(entry[2]))) end}
end

t[#t+1] = LoadFont("Common Bold") .. {Name="DensityTitle",InitCommand=function(self) self:xy(SCREEN_WIDTH-sideW+18,topY+24):halign(0):zoom(0.42):diffuse(text):settext("CHORD DENSITY") end}
t[#t+1] = LoadFont("Common Normal") .. {Name="MaxNPSText",InitCommand=function(self) self:xy(SCREEN_WIDTH-sideW+18,topY+43):halign(0):zoom(0.28):diffuse(subtext):settext("") end}
t[#t+1] = Def.ActorMultiVertex{
	Name="DensityGraph",
	InitCommand=function(self) self:xy(SCREEN_WIDTH-sideW,topY):queuecommand("DrawDensity") end,
	DrawDensityCommand=drawDensity,
}

t[#t+1] = LoadFont("Common Bold") .. {InitCommand=function(self)
		local title = "CHART PREVIEW"
		if song and song.GetDisplayMainTitle then
			local ok, value = pcall(function() return song:GetDisplayMainTitle() end)
			if ok and value then title = value end
		end
		self:xy(SCREEN_CENTER_X, 18):zoom(0.42):diffuse(text):settext(title)
	end}

t[#t+1] = Def.ActorFrame{
	InitCommand=function(self) self:xy(SCREEN_CENTER_X, SCREEN_HEIGHT - 95) end,
	Def.NoteFieldPreview{
		InitCommand=function(self)
			if steps then pcall(function() self:LoadNoteData(steps) end) end
			self:zoom(0.95):draworder(10)
		end,
	},
}

t[#t+1] = LoadFont("Common Normal") .. {InitCommand=function(self) self:xy(SCREEN_CENTER_X, SCREEN_HEIGHT-12):zoom(0.28):diffuse(subtext):settext("SPACE / BACK / START  CLOSE") end}

return t
