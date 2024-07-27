--[[
    This addon displays a user's currency, showing gains and losses since the play session started. 
    Limited to a few select currencies I care about at the moment. 
    
    Expecting to:
        - make this more dynamic 
        - and configurable.
        - show a larger detailed pane with where the losses occured
        - add an overtime (e.g. gold per hour) feature
        - Graphs?
--]]

-- Slash Commands
SLASH_SQRLCURRENCYTRACKER1 = "/scur"
--SLASH_TRABUFFTRACKER2 = "/tra"

local addonLoaded = false

--[[ Variables-- ]]
local defaults = {
    currencyVisible = true,
    goldVisible = true,
    goldVerbose = true,
    goldInit = false,
    goldGain = 0, 
    goldLoss = 0,
    goldChange = 0,
    goldTotal = 0,
}

-- Surely LUA will let me create an array of structs, or something similiar in an untyped world... 
-- @action figure out arrays or structs (or struct like things) in lua.
--[[
local gold = {
    value = 2778,
    gain = 0, 
    loss = 0, 
    total = 0,
}
]]

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
-- Update the player's current gold value, calculate gains and losses, and update the display
local function updateGold()
    local db = SQRLCurrencyTrackerDB

    -- Get the current gold value
    local money = GetMoney()
    local gold = floor(money / 1e4)

    if money == 0 then
        print("Called before I have money... ")
    end

    -- calculate gain or loss
    if gold < db.goldTotal then
        db.goldLoss = db.goldLoss + (gold - db.goldTotal)
    elseif gold > db.goldTotal then
        db.goldGain = db.goldGain + (gold - db.goldTotal)
    end

    -- Calculate the overall change
    db.goldChange = db.goldGain + db.goldLoss

    -- set the new value of the total gold
    db.goldTotal = gold

    -- Update the display
    GoldTrackerGain:SetText(db.goldGain)
    GoldTrackerLoss:SetText(db.goldLoss)
    local percChange = string.format("%.1f", ((db.goldChange / db.goldTotal)*100))
    GoldTrackerChange:SetText(db.goldChange.."("..percChange.."%)")

    if db.goldChange < 0 then
        GoldTrackerChange:SetTextColor(1,0,0)
    else
        GoldTrackerChange:SetTextColor(0,1,0)
    end

    GoldTrackerTotal:SetText(db.goldTotal)


end

-- Initialize the gold total, and reset the gain / loss data
local function initGold()
    
    print("Initializing gold")

    local db = SQRLCurrencyTrackerDB

    db.goldGain = 0
    db.goldLoss = 0
    db.goldChange = 0
    db.goldTotal = floor(GetMoney() / 1e4)
    db.goldInit = true

    updateGold()

end

--[[ Event handlers ]]
-- The standard handler
function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

-- ADDON_LOADED - Initial setup when loaded.
function f:ADDON_LOADED(event, addOnName)
    -- Initialize variables
    if addOnName == "SQRL-CurrencyTracker" then
        print("Initializing SQRL Currency Tracker")
        SQRLCurrencyTrackerDB = SQRLCurrencyTrackerDB or {} -- initialize the saved variables table if this is the first time.
        self.db = SQRLCurrencyTrackerDB
        for k, v in pairs(defaults) do -- Copy the defauls table and any new options
            if self.db[k] == nil then 
                self.db[k] = v
            end
        end

        --[[ Moving this chunk to the player load event. I don't think money is available beofer then... 
        if (self.db.goldInit == false) then
            initGold()
        else
            updateGold()
        end
        ]]
        -- Initialize the currency frame background 
        CurrencyTracker:SetBackdrop(backdropInfo)
        CurrencyTracker:SetBackdropColor("0.1", "0.1", "0.1")

        -- Initialize currency colors
        CurrencyTrackerBronzeGain:SetTextColor(0,1,0)
        CurrencyTrackerBronzeLoss:SetTextColor(1,0,0)


        -- initialize the gold frame background
        GoldTracker:SetBackdrop(backdropInfo)
        GoldTracker:SetBackdropColor("0.1", "0.1", "0.1")

        -- Initilize gold colors
        GoldTrackerGain:SetTextColor(0,1,0)
        GoldTrackerLoss:SetTextColor(1,0,0)
        GoldTrackerChange:SetTextColor(1,1,1)
    end
end

-- Whenever the player aura updates, query the Timerunner's Advantage buff
function f:CURRENCY_DISPLAY_UPDATE(event, currencyType, quantity, quantityChange, quantityGainSource, destroyReason)
    if currencyType == bronze.value then
        if quantityChange > 0 then
            bronze.gain = bronze.gain + quantityChange
        else   
            bronze.loss = bronze.loss + quantityChange
        end
        bronze.total = quantity
        CurrencyTrackerBronzeGain:SetText(bronze.gain)
        CurrencyTrackerBronzeLoss:SetText(bronze.loss)
        CurrencyTrackerBronzeTotal:SetText(bronze.total)
    else
        print ("I'm in the currency change field for some reason...")
        --print("Gained "..currencyType.." "..quantity) --.." "..quantityChange)  
    end
end

-- Whenever the player's gold amount changes
function f:PLAYER_MONEY(event)
    updateGold()
end

-- When the player enters the world (maybe this is why money isn't immediately available?)
function f:PLAYER_ENTERING_WORLD(event, isLogin, isReload)

    local db = SQRLCurrencyTrackerDB

    if (db.goldInit == false) then
        initGold()
    else
        updateGold()
    end
end

-- Event Registration
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
f:SetScript("OnEvent", f.OnEvent)

-- Slash command handling
SlashCmdList.SQRLCURRENCYTRACKER = function(msg, editBox)
    if msg == "about" then 
        print("This addon tracks the current state of your \"Time Runner's Advantage\" buff in the Pandaria Remix event.")
        print("The main frame shows each of the stats from the buff. This frame is movable by dragging it around the screen.")
        print("A \"gains\" window is attached to the right side of the buff frame. It's a fun way to track how much your stats have improved this play session.")
        print("Use /tra for more options.")

    elseif msg == "toggle gold" then
        SQRLCurrencyTrackerDB.goldVisible = not SQRLCurrencyTrackerDB.goldVisible
        if SQRLCurrencyTrackerDB.goldVisible == true then
            GoldTracker:Show()
        else
            GoldTracker:Hide()
        end 
    elseif msg == "toggle cur" then
        SQRLCurrencyTrackerDB.currencyVisible = not SQRLCurrencyTrackerDB.currencyVisible
        if SQRLCurrencyTrackerDB.currencyVisible == true then
            CurrencyTracker:Show()
        else
            CurrencyTracker:Hide()
        end 
    elseif msg == "reset" then 
        SQRLCurrencyTrackerDB.goldInit = false
        initGold()
    else
        print("SQRL Currency Tracker usage info coming soon... ")
    end
end






