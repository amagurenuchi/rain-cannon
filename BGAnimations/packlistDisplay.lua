local tzoom = 0.5
local pdh = 42 * tzoom
local ygap = 2
local packspaceY = pdh + ygap

local numpacks = 15
local offx = 5
local width = SCREEN_WIDTH * 0.6
local dwidth = width - offx * 2
local height = (numpacks + 2) * packspaceY

local c1x = 10
local c2x = 48
local c6x = dwidth
local c5x = dwidth - 78
local c4x = dwidth - 132
local c3x = dwidth - 188
local c2xc3x = dwidth - 248
local headeroff = packspaceY / 1.5

local hoverAlpha = 0.7

-- Willow Heart's rating palette is the source of truth for downloader data.
local function byFileSize(sizeMB)
	local normalized = math.min(math.max(tonumber(sizeMB) or 0, 0), 2048)
	return GetRatingColor(normalized / 80)
end

-- Five skill bands matching Willow Heart's difficulty progression.
local skillRangeColors = {
	GetRatingColor(8),
	GetRatingColor(13),
	GetRatingColor(18),
	GetRatingColor(23),
	GetRatingColor(28),
}

local function bySkillRange(rating)
	rating = tonumber(rating) or 0
	if rating <= 10 then return skillRangeColors[1]
	elseif rating <= 15 then return skillRangeColors[2]
	elseif rating <= 21 then return skillRangeColors[3]
	elseif rating <= 25 then return skillRangeColors[4]
	end
	return skillRangeColors[5]
end

local translated_info = {
	Name = THEME:GetString("PacklistDisplay", "Name"),
	AverageDiff = THEME:GetString("PacklistDisplay", "AverageDiff"),
	Size = THEME:GetString("PacklistDisplay", "Size"),
	Installed = THEME:GetString("PacklistDisplay", "Installed"),
	Download = THEME:GetString("PacklistDisplay", "Download"),
	Mirror = THEME:GetString("PacklistDisplay", "Mirror"),
	MB = THEME:GetString("PacklistDisplay", "MB"),
	AwaitingRequest = THEME:GetString("PacklistDisplay", "AwaitingRequest"),
	NoPacks = THEME:GetString("PacklistDisplay", "NoPacks"),
	PackPlays = THEME:GetString("PacklistDisplay", "PackPlays"),
	SongCount = THEME:GetString("PacklistDisplay", "SongCount"),
	IsNSFW = THEME:GetString("PacklistDisplay", "IsNSFW"),
}

-- initialize the base pack search
local packlist = PackList:new()
packlist:FilterAndSearch("", {}, true, numpacks)

local o = Def.ActorFrame {
	Name = "PacklistDisplay",
	InitCommand = function(self)
		self:xy(0, 0)
	end,
	BeginCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(function(event)
			if isOver(self:GetChild("BG")) then
				if event.type == "InputEventType_FirstPress" then
					if not packlist:IsAwaitingRequest() then
						if event.DeviceInput.button == "DeviceButton_mousewheel up" then
							packlist:PrevPage()
						elseif event.DeviceInput.button == "DeviceButton_mousewheel down" then
							packlist:NextPage()
						end
						self:queuecommand("Update")
					end
				end
			end
		end)
		self:queuecommand("PackTableRefresh")
	end,
	InvokePackSearchMessageCommand = function(self, params)
		packlist:FilterAndSearch(params.name, params.tags, params.tagsMatchAny, numpacks)
		self:queuecommand("Update")
	end,
	PackTableRefreshCommand = function(self)
		self:queuecommand("Update")
	end,
	UpdateCommand = function(self)

	end,
	DFRFinishedMessageCommand = function(self)
		self:queuecommand("Update")
	end,
	PackListRequestFinishedMessageCommand = function(self, params)
		self:queuecommand("Update")
	end,
	NextPageCommand = function(self)
		self:queuecommand("Update")
	end,
	PrevPageCommand = function(self)
		self:queuecommand("Update")
	end,

	-- Base Card Background Container
	Def.Quad {
		Name = "BG",
		InitCommand = function(self)
			self:zoomto(width, height - headeroff)
			self:halign(0):valign(0)
			self:diffuse(color("#FAF7F9"))
			self:diffusealpha(0.95)
		end
	},
	-- Table Header Accent Strip
	Def.Quad {
		Name = "HeaderAccentLine",
		InitCommand = function(self)
			self:xy(offx, headeroff)
			self:zoomto(dwidth, 3)
			self:halign(0):valign(0)
			self:diffuse(COLOR.MainHighlight)
		end
	},
	-- Table Header Bar
	Def.Quad {
		Name = "HeaderBG",
		InitCommand = function(self)
			self:xy(offx, headeroff + 3)
			self:zoomto(dwidth, pdh)
			self:halign(0):valign(0)
			self:diffuse(color("#6A5A75"))
		end
	},
	LoadFont("Common Normal") .. {
		Name = "TotalPacks",
		InitCommand = function(self)
			self:xy(c1x, headeroff + 3 + pdh/2)
			self:zoom(tzoom)
			self:halign(0):valign(0.5)
			self:diffuse(COLOR.TextMainLight)
		end,
		UpdateCommand = function(self)
			self:settext(packlist:GetTotalResults())
		end
	},
	UIElements.TextToolTip(1, 1, "Common Normal") .. {
		Name = "NameHeader",
		InitCommand = function(self)
			self:xy(c2x, headeroff + 3 + pdh/2)
			self:zoom(tzoom)
			self:halign(0):valign(0.5)
			self:diffuse(COLOR.TextMainLight)
			self:settext(translated_info["Name"])
		end,
		MouseOverCommand = function(self)
			self:diffuse(COLOR.MainHighlight)
		end,
		MouseOutCommand = function(self)
			self:diffuse(COLOR.TextMainLight)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" then
				packlist:SortByName()
				self:GetParent():queuecommand("Update")
			end
		end
	},
	UIElements.TextToolTip(1, 1, "Common Normal") .. {
		Name = "AverageDiffHeader",
		InitCommand = function(self)
			self:xy(c2xc3x, headeroff + 3 + pdh/2)
			self:zoom(tzoom)
			self:halign(1):valign(0.5)
			self:diffuse(COLOR.TextMainLight)
			self:settext(translated_info["AverageDiff"])
		end,
		MouseOverCommand = function(self)
			self:diffuse(COLOR.MainHighlight)
		end,
		MouseOutCommand = function(self)
			self:diffuse(COLOR.TextMainLight)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" then
				packlist:SortByOverall()
				self:GetParent():queuecommand("Update")
			end
		end
	},
	UIElements.TextToolTip(1, 1, "Common Normal") .. {
		Name = "SizeHeader",
		InitCommand = function(self)
			self:xy(c3x, headeroff + 3 + pdh/2)
			self:zoom(tzoom)
			self:halign(1):valign(0.5)
			self:diffuse(COLOR.TextMainLight)
			self:settext(translated_info["Size"])
		end,
		MouseOverCommand = function(self)
			self:diffuse(COLOR.MainHighlight)
		end,
		MouseOutCommand = function(self)
			self:diffuse(COLOR.TextMainLight)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" then
				packlist:SortBySize()
				self:GetParent():queuecommand("Update")
			end
		end
	},
	UIElements.TextToolTip(1, 1, "Common Normal") .. {
		Name = "PlaysHeader",
		InitCommand = function(self)
			self:xy(c4x, headeroff + 3 + pdh/2)
			self:zoom(tzoom)
			self:halign(1):valign(0.5)
			self:diffuse(COLOR.TextMainLight)
			self:settext(translated_info["PackPlays"])
		end,
		MouseOverCommand = function(self)
			self:diffuse(COLOR.MainHighlight)
		end,
		MouseOutCommand = function(self)
			self:diffuse(COLOR.TextMainLight)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" then
				packlist:SortByPlays()
				self:GetParent():queuecommand("Update")
			end
		end
	},
	UIElements.TextToolTip(1, 1, "Common Normal") .. {
		Name = "SongCountHeader",
		InitCommand = function(self)
			self:xy(c5x, headeroff + 3 + pdh/2)
			self:zoom(tzoom)
			self:halign(1):valign(0.5)
			self:diffuse(COLOR.TextMainLight)
			self:settext(translated_info["SongCount"])
		end,
		MouseOverCommand = function(self)
			self:diffuse(COLOR.MainHighlight)
		end,
		MouseOutCommand = function(self)
			self:diffuse(COLOR.TextMainLight)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" then
				packlist:SortBySongs()
				self:GetParent():queuecommand("Update")
			end
		end
	},
	LoadFont("Common Large") .. {
		Name = "AwaitingOrNoResults",
		InitCommand = function(self)
			self:xy(width/2, height/2)
			self:zoom(tzoom)
			self:diffuse(COLOR.TextMain)
			self:maxwidth(width / tzoom)
		end,
		UpdateCommand = function(self)
			if packlist:IsAwaitingRequest() then
				self:settext(translated_info["AwaitingRequest"])
				self:visible(true)
			else
				if packlist:GetTotalResults() == 0 then
					self:visible(true)
					self:settext(translated_info["NoPacks"])
				else
					self:visible(false)
				end
			end
		end,
	},
}

local function makePackDisplay(i)
	local packinfo
	local installed
	local o = Def.ActorFrame {
		Name = "Pack"..i,
		InitCommand = function(self)
			self:y(packspaceY * i + headeroff + 3)
		end,
		UpdateCommand = function(self)
			if packlist:IsAwaitingRequest() then
				self:visible(false)
				return
			end

			packinfo = packlist:GetPacks()[i]
			if packinfo then
				installed = SONGMAN:DoesSongGroupExist(packinfo:GetName())
				self:queuecommand("Display")
				self:visible(true)
			else
				self:visible(false)
			end
		end,
		Def.Quad {
			Name = "BG",
			InitCommand = function(self)
				self:x(offx)
				self:zoomto(dwidth, pdh)
				self:halign(0):valign(0)
			end,
			DisplayCommand = function(self)
				if installed then
					self:diffuse(color("#F0E6EE"))
					self:diffusealpha(0.85)
				else
					if i % 2 == 0 then
						self:diffuse(color("#FBF7F9"))
					else
						self:diffuse(color("#FFFFFF"))
					end
					self:diffusealpha(0.95)
				end
			end
		},
		LoadFont("Common normal") .. {
			Name = "PackIndex",
			InitCommand = function(self)
				self:x(c1x)
				self:y(pdh/2)
				self:zoom(tzoom)
				self:halign(0):valign(0.5)
				self:diffuse(COLOR.TextSub1)
			end,
			DisplayCommand = function(self)
				self:settextf("%i.", i + ((packlist:GetCurrentPage()-1) * numpacks))
			end
		},
		UIElements.TextToolTip(1, 1, "Common normal") .. {
			Name = "PackName",
			InitCommand = function(self)
				self:x(c2x)
				self:y(pdh/2)
				self:zoom(tzoom)

				 -- x of left aligned col 2 minus x of right aligned col 3 minus roughly how wide column 3 is plus margin
				self:maxwidth((c2xc3x - c2x - 8) / tzoom)
				self:halign(0):valign(0.5)
			end,
			DisplayCommand = function(self)
				self:settext(packinfo:GetName())
				self:diffuse(GetRatingColor(packinfo:GetAvgDifficulty()))
			end,
			MouseOverCommand = function(self)
				self:diffusealpha(hoverAlpha)
			end,
			MouseOutCommand = function(self)
				self:diffusealpha(1)
			end,
			MouseDownCommand = function(self, params)
				if not packinfo then return end
				if params.event == "DeviceButton_left mouse button" then
					DLMAN:ShowPackPage(packinfo:GetID())
				end
			end
		},
		LoadFont("Common normal") .. {
			Name = "PackAverageDiff",
			InitCommand = function(self)
				self:x(c2xc3x)
				self:y(pdh/2)
				self:zoom(tzoom)
				self:halign(1):valign(0.5)
			end,
			DisplayCommand = function(self)
				local avgdiff = packinfo:GetAvgDifficulty()
				self:settextf("%0.2f", avgdiff)
				self:diffuse(bySkillRange(avgdiff))
			end
		},
		LoadFont("Common normal") .. {
			Name = "PackSize",
			InitCommand = function(self)
				self:x(c3x):y(pdh/2):zoom(tzoom):halign(1):valign(0.5)
			end,
			DisplayCommand = function(self)
				local psize = packinfo:GetSize() / 1024 / 1024
				self:settextf("%i%s", psize, translated_info["MB"])
				self:diffuse(byFileSize(psize))
			end
		},
		LoadFont("Common normal") .. {
			Name = "PackPlays",
			InitCommand = function(self)
				self:x(c4x):y(pdh/2):zoom(tzoom):halign(1):valign(0.5)
				self:diffuse(COLOR.TextMain)
			end,
			DisplayCommand = function(self)
				self:settextf("%d", packinfo:GetPlayCount())
			end
		},
		LoadFont("Common normal") .. {
			Name = "PackSongs",
			InitCommand = function(self)
				self:x(c5x):y(pdh/2):zoom(tzoom):halign(1):valign(0.5)
				self:diffuse(COLOR.TextMain)
			end,
			DisplayCommand = function(self)
				self:settextf("%d", packinfo:GetSongCount())
			end
		},
		-- Action Button / Pill for Download or Installed
		Def.Quad {
			Name = "DownloadButtonBG",
			InitCommand = function(self)
				self:x(c6x)
				self:y(2)
				self:zoomto(65, pdh - 4)
				self:halign(1):valign(0)
			end,
			DisplayCommand = function(self)
				if installed then
					self:diffuse(color("#E0D6DF"))
					self:diffusealpha(0.6)
				else
					self:diffuse(COLOR.MainHighlight)
					self:diffusealpha(0.85)
				end
			end
		},
		UIElements.TextToolTip(1, 1, "Common normal") .. {
			Name = "PackDownload",
			InitCommand = function(self)
				self:x(c6x - 32.5)
				self:y(pdh/2)
				self:zoom(tzoom)
				self:halign(0.5):valign(0.5)
			end,
			DisplayCommand = function(self)
				if installed then
					self:settext(translated_info["Installed"])
					self:diffuse(COLOR.TextSub1)
				else
					self:settext(translated_info["Download"])
					self:diffuse(COLOR.TextMain)
				end
			end,
			MouseOverCommand = function(self)
				if not packinfo then return end
				local bg = self:GetParent():GetChild("DownloadButtonBG")
				if bg and not installed then
					bg:diffusealpha(1.0)
				end
				self:diffusealpha(hoverAlpha)
				if packinfo:IsNSFW() and not installed then
					TOOLTIP:SetText(translated_info["IsNSFW"])
					TOOLTIP:Show()
				end
			end,
			MouseOutCommand = function(self)
				local bg = self:GetParent():GetChild("DownloadButtonBG")
				if bg and not installed then
					bg:diffusealpha(0.85)
				end
				self:diffusealpha(1)
				TOOLTIP:Hide()
			end,
			MouseDownCommand = function(self, params)
				if not packinfo then return end
				if params.event == "DeviceButton_left mouse button" then
					if packinfo:GetSize() > 2000000000 then
						packinfo:DownloadExternally()
					else
						packinfo:DownloadAndInstall(false)
					end
				end
			end
		},
	}
	return o
end

for i = 1, numpacks do
	o[#o + 1] = makePackDisplay(i)
end

return o
