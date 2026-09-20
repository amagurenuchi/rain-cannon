local screenName = Var("LoadingScreen") or ...
local topScreen
local debugElapsed = 0
local debugEvent = "no mouse click yet"

local function debugInput(event)
    if not event or not event.DeviceInput then return end

    local button = event.DeviceInput.button
    if button == "DeviceButton_left mouse button"
        or button == "DeviceButton_right mouse button"
        or button == "DeviceButton_middle mouse button" then
        debugEvent = string.format(
            "%s %s at (%d, %d) on %s",
            event.type,
            button,
            INPUTFILTER:GetMouseX(),
            INPUTFILTER:GetMouseY(),
            tostring(SCREENMAN:GetTopScreen() and SCREENMAN:GetTopScreen():GetName())
        )
    end
end

assert(type(screenName) == "string", "Screen Name was missing when loading _mouse.lua")
BUTTON:ResetButtonTable(screenName)

local function updateMouse(frame)
    local mouseX = INPUTFILTER:GetMouseX()
    local mouseY = INPUTFILTER:GetMouseY()

    BUTTON:UpdateMouseState()

    debugElapsed = debugElapsed + (1 / (DISPLAY:GetDisplayRefreshRate() or 60))
    if debugElapsed >= 0.25 then
        local debugText = frame:GetChild("MouseDebug")
        if debugText then
            debugText:settext(string.format(
                "Mouse XY: (%d, %d)\n%s",
                mouseX,
                mouseY,
                debugEvent
            ))
        end
        debugElapsed = 0
    end

    local pointer = frame:GetChild("MousePointer")
    if pointer then
        pointer:xy(mouseX, mouseY)
    end

    if TOOLTIP and TOOLTIP.Actor then
        TOOLTIP:SetPosition(mouseX, mouseY)
    end

    return false
end

local t = Def.ActorFrame{
    InitCommand = function(self)
        self:draworder(999999)
    end,
    OnCommand = function(self)
        topScreen = SCREENMAN:GetTopScreen()
        if topScreen then
            topScreen:AddInputCallback(function(event)
                debugInput(event)
                BUTTON.InputCallback(event)
            end)
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

t[#t + 1] = Def.Quad{
    Name = "MousePointer",
    InitCommand = function(self)
        self:draworder(999999):zoomto(6, 6):rotationz(45):diffuse(color("0,0,0,1"))
    end,
}

t[#t + 1] = LoadFont("Common Normal") .. {
    Name = "MouseDebug",
    InitCommand = function(self)
        self:xy(12, 12):halign(0):valign(0):zoom(0.7)
            :diffuse(color("0,0,0,1"))
            :strokecolor(color("0,0,0,1"))
        self:settext("Mouse XY: (0, 0)\nno mouse click yet")
    end,
}

return t
