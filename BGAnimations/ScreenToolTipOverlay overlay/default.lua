local function UpdateLoop()
    local mouseX = INPUTFILTER:GetMouseX()
    local mouseY = INPUTFILTER:GetMouseY()
    if TOOLTIP.Actor then
        pcall(TOOLTIP.SetPosition, TOOLTIP, mouseX, mouseY)
    end
    BUTTON:UpdateMouseState()

    return false
end

local t = Def.ActorFrame{
    InitCommand = function(self)
        self:SetUpdateFunction(UpdateLoop):SetUpdateFunctionInterval(0.01)
    end,
}

t[#t+1] = TOOLTIP:New()


return t;
