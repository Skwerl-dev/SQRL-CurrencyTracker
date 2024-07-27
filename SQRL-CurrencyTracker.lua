--[[
    This addon tracks the details of the "Timerunner's Advantage" buff from WoW Pandaria Remix time limited event. 
    The buff details are trakced in a small movable frame. And optional "gains" frame, anchored to the main buff frame
    shows the gains in each stat since login / reset.
--]]

-- Slash Commands
--SLASH_TRABUFFTRACKER1 = "/TRABuffTracker"
--SLASH_TRABUFFTRACKER2 = "/tra"

--[[ Variables-- ]]
--[[
local defaults = {
    buffVisible = true,
    gainsVisible = true,
}

-- Track how much the cloak has been updated this session
local statGains = {
    initial = false, -- If the buff stats haven't initialized yet, don't do math.
    int = 0,
    stam = 0,
    crit = 0,
    haste = 0,
    leech = 0,
    mastery = 0,
    speed = 0,
    vers = 0,
    exp = 0,
}
--]]
local bronze = {
    name = "Bronze",
    value = 2778,
    gain = 0, 
    loss = 0, 
    total = 0,
}

-- Basic frame backdrop with a minimal border setup. 
local backdropInfo =
{
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
 	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 	tile = true,
 	tileEdge = true,
 	tileSize = 8,
 	edgeSize = 8,
 	insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

-- Local Frames
local f = CreateFrame("Frame")

--[[ Helper Functions ]]

--[[
-- Fine the Timerunner's Advantage buff, extract the current values, and calculate any gains this session 
local function updateTRABuff()
    -- Find the aura by name
    local traBuff = C_UnitAuras.GetAuraDataBySpellName("player", "Timerunner's Advantage")

    -- If the buff exists, update the main stat window and recalculate gains
    if traBuff ~= nil then
        -- Only update the gains if the stats have already been initialized. 
        if statGains.initial == false then 
            statGains.int = traBuff.points[1]
            statGains.stam = traBuff.points[2]
            statGains.crit = traBuff.points[3]
            statGains.haste = traBuff.points[4]
            statGains.leech = traBuff.points[5]
            statGains.mastery = traBuff.points[6]
            statGains.speed = traBuff.points[7]
            statGains.vers = traBuff.points[8]
            statGains.exp = traBuff.points[9]
            statGains.initial = true
        end 
        -- Update the main stats
        TRABuffTrackerInt:SetText(traBuff.points[1])
        TRABuffTrackerStam:SetText(traBuff.points[2])
        TRABuffTrackerCrit:SetText(traBuff.points[3])
        TRABuffTrackerHaste:SetText(traBuff.points[4])
        TRABuffTrackerLeech:SetText(traBuff.points[5])
        TRABuffTrackerMastery:SetText(traBuff.points[6])
        TRABuffTrackerSpeed:SetText(traBuff.points[7])
        TRABuffTrackerVers:SetText(traBuff.points[8])
        TRABuffTrackerExp:SetText(traBuff.points[9])
        
        -- Update the gains
        TRAGainsInt:SetText(traBuff.points[1]-statGains.int)
        TRAGainsStam:SetText(traBuff.points[2]-statGains.stam)
        TRAGainsCrit:SetText(traBuff.points[3]-statGains.crit)
        TRAGainsHaste:SetText(traBuff.points[4]-statGains.haste)
        TRAGainsLeech:SetText(traBuff.points[5]-statGains.leech)
        TRAGainsMastery:SetText(traBuff.points[6]-statGains.mastery)
        TRAGainsSpeed:SetText(traBuff.points[7]-statGains.speed)
        TRAGainsVers:SetText(traBuff.points[8]-statGains.vers)
        TRAGainsExp:SetText(traBuff.points[9]-statGains.exp)
    end

end
--]]

--[[ Event handlers ]]
-- The standard handler
function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

-- ADDON_LOADED - Initial setup when loaded.
function f:ADDON_LOADED(event, addOnName)
    -- Initialize variables
    --[[
    if addOnName == "TRABuffTracker" then
        TRABuffTrackerDB = TRABuffTrackerDB or {} -- initialize the saved variables table if this is the first time.
        self.db = TRABuffTrackerDB
        for k, v in pairs(defaults) do -- Copy the defauls table and any new options
            if self.db[k] == nil then 
                self.db[k] = v
            end
        end
        ]]
        -- Initialize the frame background 
        CurrencyTracker:SetBackdrop(backdropInfo)
        CurrencyTracker:SetBackdropColor("0.1", "0.1", "0.1")

        --[[
        -- Initialize the gains frame
        TRAGains:SetBackdrop(backdropInfo)
        TRAGains:SetBackdropColor("0.1", "0.1", "0.1")

        -- Initialize the color options for the TRA Buff
        -- Label side
        TRABuffTrackerIntStr:SetTextColor(0,1,0)
        TRABuffTrackerStamStr:SetTextColor(0,1,0)
        TRABuffTrackerCritStr:SetTextColor(0,1,0)
        TRABuffTrackerHasteStr:SetTextColor(0,1,0)
        TRABuffTrackerLeechStr:SetTextColor(0,1,0)
        TRABuffTrackerMasteryStr:SetTextColor(0,1,0)
        TRABuffTrackerSpeedStr:SetTextColor(0,1,0)
        TRABuffTrackerVersStr:SetTextColor(0,1,0)
        TRABuffTrackerExpStr:SetTextColor(1,1,0)
        -- Variable side
        TRABuffTrackerInt:SetTextColor(0,1,0)
        TRABuffTrackerStam:SetTextColor(0,1,0)
        TRABuffTrackerCrit:SetTextColor(0,1,0)
        TRABuffTrackerHaste:SetTextColor(0,1,0)
        TRABuffTrackerLeech:SetTextColor(0,1,0)
        TRABuffTrackerMastery:SetTextColor(0,1,0)
        TRABuffTrackerSpeed:SetTextColor(0,1,0)
        TRABuffTrackerVers:SetTextColor(0,1,0)
        TRABuffTrackerExp:SetTextColor(1,1,0)
        
    end
    ]]
end

-- Whenever the player aura updates, query the Timerunner's Advantage buff
function f:CURRENCY_DISPLAY_UPDATE(event, currencyType, quantity, quantityChange, quantityGainSource, destroyReason)
    if currencyType == bronze.value then
        print("Gained bronze "..quantity.." "..quantityChange)
        if quantityChange > 0 then
            bronze.gain = bronze.gain + quantityChange
        else   
            bronze.loss = bronze.loss + quantityChange
        end
        bronze.total = quantity
        CurrencyTrackerCur1Gain:SetText(bronze.gain)
        CurrencyTrackerCur1Loss:SetText(bronze.loss)
        CurrencyTrackerCur1Total:SetText(bronze.total)
    end
end

-- Event Registration
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
f:SetScript("OnEvent", f.OnEvent)

--[[
-- Slash command handling
SlashCmdList.TRABUFFTRACKER = function(msg, editBox)
    if msg == "about" then 
        print("This addon tracks the current state of your \"Time Runner's Advantage\" buff in the Pandaria Remix event.")
        print("The main frame shows each of the stats from the buff. This frame is movable by dragging it around the screen.")
        print("A \"gains\" window is attached to the right side of the buff frame. It's a fun way to track how much your stats have improved this play session.")
        print("Use /tra for more options.")
    elseif msg == "gains" then
        TRABuffTrackerDB.gainsVisible = not TRABuffTrackerDB.gainsVisible
        if TRABuffTrackerDB.gainsVisible == true then
            TRAGains:Show()  
        else
            TRAGains:Hide()
        end    
    elseif msg == "toggle" then
        TRABuffTrackerDB.buffVisible = not TRABuffTrackerDB.buffVisible
        -- Set the gains frame to the visibility of the stats frame to keep them in sync
        -- @action - actually, leaving the gains alone might be neat. Leaving it in now as a valid config. 
        -- TRABuffTrackerDB.gainsVisible = TRABuffTrackerDB.buffVisible
        if TRABuffTrackerDB.buffVisible == true then
            TRABuffTracker:Show()
        else
            TRABuffTracker:Hide()
        end  
    elseif msg == "reset" then 
        statGains.initial = false
        updateTRABuff()
    else
        print("TRA Buff Tracker Usage:")
        print("     about - useful information about this addon")
        print("     gains - toggles the visibility of the gains frame")
        print("     reset - sets the gains trackers back to 0 to restart the count")
        print("     toggle - toggles the display of the TRA Buff Tracker main frame")
    end
end
]]






