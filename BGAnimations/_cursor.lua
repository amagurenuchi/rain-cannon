-- Mouse controller and pointer.
-- This actor must be loaded by a screen overlay so its input callback is
-- attached to the screen that owns the registered QuadButtons.

local screenName = Var("LoadingScreen") or ...
local maxRipples = 20
local rippleIndex = 0

BUTTON:ResetButtonTable(screenName)

local function updateMouse(frame)
    local x = INPUTFILTER:GetMouseX()
    local y = INPUTFILTER:GetMouseY()

    -- TOOLTIP is also the canonical pointer owner in the fallback theme.
    -- Keep its tooltip actor positioned independently of the pointer graphic.
    if TOOLTIP and TOOLTIP.Actor then
        TOOLTIP:SetPosition(x, y)
    end

    BUTTON:UpdateMouseState()
    local pointer = frame:GetChild("CursorPointer")
    if pointer then
        pointer:xy(x, y)
    end
    return false
end

local function ripple(index)
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

        self:SetUpdateFunction(updateMouse)
        local refreshRate = DISPLAY:GetDisplayRefreshRate()
        if refreshRate and refreshRate > 0 then
            self:SetUpdateFunctionInterval(1 / refreshRate)
        end
    end,
    OffCommand = function(self)
        self:SetUpdateFunction(nil)
        BUTTON:ResetButtonTable(screenName)
        if TOOLTIP and TOOLTIP.Actor then
            TOOLTIP:Hide()
        end
    end,
    CancelCommand = function(self)
        self:playcommand("Off")
    end,
}

for index = 0, maxRipples do
    t[#t + 1] = ripple(index)
end

t[#t + 1] = Def.Quad{
    Name = "CursorPointer",
    InitCommand = function(self)
        self:zoomto(6, 6):rotationz(45):diffuse(color("0,0,0,1"))
    end,
    MouseLeftClickMessageCommand = function()
        rippleIndex = (rippleIndex + 1) % maxRipples
    end,
}

return t
