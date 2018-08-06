--[[

]]

-- Set the object
ABC = {};

-- Define different colors for different events
ABC.outOfRange = CreateColor(1,0,0);        -- Red
ABC.notEnoughMana = CreateColor(0,0,1);        -- Blue
ABC.notUsable = CreateColor(0,1,0);            -- Green
ABC.opacity = 0.5;
ABC.debugMode = false;
ABC.lastState = {};

-- Make the frame
ABC.frame = CreateFrame("Frame");

-- Run on update to figure out what color the actionButton should be
function ABC:OnUpdate(actionButton)
    if not actionButton then self:Debug('OnUpdate no actionButton'); return false; end
    
    -- self:Debug('OnUpdate', actionButton, actionButton:GetName());
    
    local actionButtonSlot = ActionButton_GetPagedID(actionButton);
    local inRange = IsActionInRange(actionButtonSlot);
    local isUsable, notEnoughMana = IsUsableAction(actionButtonSlot);
    
    -- Test with actionButtonSlot 1
    --if self.debugMode and actionButtonSlot ~= 1 then return nil; end
    
    
    -- Out of Range
    if inRange == false then
        self:Debug("outOfRange", actionButtonSlot, inRange);
        self:UpdateSlot(actionButton, self.outOfRange);
        
    -- Not enough mana/rage/energy111
    elseif notEnoughMana then
        -- self:Debug("notEnoughMana", actionButtonSlot, inRange);
        self:UpdateSlot(actionButton, self.notEnoughMana);
    
    -- Not usable, debugging atm
    elseif not isUsable and self.debugMode then
        self:UpdateSlot(actionButton, self.notEnoughMana);
        self:Debug("notUseable", actionButtonSlot);
        -- self:UpdateSlot(actionButton);
        
    -- Reset the action bar
    else
        self:Debug("else", actionButtonSlot, inRange, isUsable, notEnoughMana);
        self:UpdateSlot(actionButton);
    end
end

-- Update the icon on actionButton to CreateColor()
function ABC:UpdateSlot(actionButton, color)
    if not actionButton then return false; end
    
    -- Frame name of the Icon
    local actionButtonIcon = actionButton:GetName() .. "Icon"
    
    -- Logging
    if not self.lastState[actionButtonIcon] then 
        self.lastState[actionButtonIcon] = {
            color = nil,
            updated = 0, 
        }; 
    end
    
    -- Are we due for an update?
    if self.lastState[actionButtonIcon].updated + 0.1 > GetTime() then return false; end
    
    
    -- We have a color and valid icon frame that isn't the same as before
    if color and _G[actionButtonIcon]
        and self.lastState[actionButtonIcon].color ~= color then
        
        
        -- Set the VertexColor of the frame
        _G[actionButtonIcon]:SetVertexColor(color:GetRGB(), self.opacity);
        
        -- Log the color and time
        self.lastState[actionButtonIcon].color = color;
        self.lastState[actionButtonIcon].updated = GetTime();
        
    -- No color so reset the frame
    else
        ActionButton_UpdateUsable(actionButton);
        
        -- Log the color and time
        self.lastState[actionButtonIcon].color = nil;
        self.lastState[actionButtonIcon].updated = GetTime();
    end
end


-- Useful methods
function ABC:Print(...)
    return Print(self, DEFAULT_CHAT_FRAME, ...)
end

function ABC:Debug(...)
    if self.debugMode then
        print('|cFFFF0000ABCD:|r ', ...);
    end
end


-- Hook both action bar types
--     Note: This is very, very noisey, there has to be a better way
--          Possibly look into tracing the functions back to events.
hooksecurefunc("ActionButton_OnUpdate", function(...) ABC:OnUpdate(...); end);
hooksecurefunc("MultiActionBar_Update", function(...) ABC:OnUpdate(...); end);