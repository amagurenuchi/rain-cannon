-- Custom mouse cursor rendering, adapted from the sibling themes.
-- This file owns exactly one persistent pointer: the diamond below.

local maxRipples = 20
local rippleIndex = 0
local screenName = Var("LoadingScreen") or ...
BUTTON:ResetButtonTable(screenName)

local function cursorRipple(index)
    return LoadActor(THEME:GetPathG("", "_circle (doubleres)")) .. {
        Name = "CursorRipple" .. index,
        InitCommand = function(self)
            self:visible(false):diffuse(color("0,0,0,1"))
        end,
        MouseLeftClickMessageCommand = function(self)
            if index == rippleIndex then
                self:finishtweening()
                self:xy(INPUTFILTER:GetMouseX(), INPUTFILTER:GetMouseY())
                self:visible(true):zoom(0)
                self:decelerate(0.5):zoom(1)
                self:visible(false)
            end
        end,
    }
end

local t = Def.ActorFrame{
    Name = "Cursor",
    InitCommand = function(self)
        self:draworder(999999)
    end,
    OnCommand = function(self)
        local topScreen = SCREENMAN:GetTopScreen()
        if topScreen then
            topScreen:AddInputCallback(BUTTON.InputCallback)
        end
        self:SetUpdateFunction(function(frame)
            BUTTON:UpdateMouseState()
            -- Use the fallback tooltip pointer, enlarged for visibility.
            if TOOLTIP and TOOLTIP.Pointer then
                TOOLTIP.Pointer
                    :xy(INPUTFILTER:GetMouseX(), INPUTFILTER:GetMouseY())
                    :zoomto(10, 10)
                    :rotationz(45)
                    :visible(true)
            end
            frame:GetChild("CursorPointer")
                :xy(INPUTFILTER:GetMouseX(), INPUTFILTER:GetMouseY())
            return false
        end)
        local refreshRate = DISPLAY:GetDisplayRefreshRate()
        if refreshRate and refreshRate > 0 then
            self:SetUpdateFunctionInterval(1 / refreshRate)
        end
    end,
    OffCommand = function(self)
        self:SetUpdateFunction(nil)
        BUTTON:ResetButtonTable(screenName)
    end,
}

for index = 0, maxRipples do
    t[#t + 1] = cursorRipple(index)
end

t[#t + 1] = Def.Quad{
    Name = "CursorPointer",
    InitCommand = function(self)
        self:zoomto(6, 6)
            :rotationz(45)
            :diffuse(color("0,0,0,1"))
    end,
    MouseLeftClickMessageCommand = function()
        rippleIndex = (rippleIndex + 1) % maxRipples
    end,
}

return t
