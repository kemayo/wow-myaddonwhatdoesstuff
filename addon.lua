local myname, ns = ...

local debugf = tekDebug and tekDebug:GetFrame("Kemayo")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

-- events
local f = CreateFrame("frame")
f:SetScript("OnEvent", function(self, event, ...) if ns[event] then return ns[event](ns, event, ...) end end)
function ns:RegisterEvent(...) for i=1,select("#", ...) do f:RegisterEvent((select(i, ...))) end end
function ns:UnregisterEvent(...) for i=1,select("#", ...) do f:UnregisterEvent((select(i, ...))) end end


local window
function ns:ShowTextToCopy(...)
    local output = string.join('\n', tostringall(...))
    local TextDump = LibStub("LibTextDump-1.0", true)
    if TextDump then
        if not window then
            window = TextDump:New(myname, 420, 280)
        end
        -- window:Clear()
        window:AddLine(output)
        window:Display()
    else
        print(output)
    end
end


-- Utility function for item links
-- this mapping came from Blizzard_Reports.lua
local fields = {
   "itemID", "enchantID", "gemID1", "gemID2", "gemID3",
   "gemID4", "suffixID", "uniqueID", "linkLevel", "specializationID",
   "upgradeTypeID", "instanceDifficultyID", "numBonusIDs", -- [:bonusID1:bonusID2:...]
   --[:upgradeValue1:upgradeValue2:...]:relic1NumBonusIDs[:relic1BonusID1:relic1BonusID2:...]:relic2NumBonusIDs[:relic2BonusID1:relic2BonusID2:...]:relic3NumBonusIDs[:relic3BonusID1:relic3BonusID2:...]
}
local function LinkOptions(link)
    local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
    local splitOptions = {LinkUtil.SplitLinkOptions(linkOptions)}
    local options = {}
    for i, field in ipairs(fields) do
        options[field] = tonumber(splitOptions[i])
    end
    local numBonusIDs = tonumber(options.numBonusIDs)
    if numBonusIDs and numBonusIDs > 0 then
        local b = {}
        for i=1, numBonusIDs, 1 do
            local bonusID = tonumber(splitOptions[#fields + i])
            table.insert(b, bonusID)
            options["bonusID"..i] = bonusID
        end
        options.bonusIDs = b
    end
    --TODO: support the rest of the fields if they ever become relevant
    return options, linkType, displayText
end


-- Tweak buff position a bit
-- ConsolidatedBuffs:ClearAllPoints()
-- ConsolidatedBuffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -190, -45)
-- ConsolidatedBuffs.SetPoint = function() end
-- BuffFrame:ClearAllPoints()
-- BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -190, -45)

-- Helpful Bankstack test...

local is_cloth = function(itemid, bag, slot) return select(7, GetItemInfo(itemid)) == "Cloth" end
StackCloth = BankStack.CommandDecorator(function(from, to)
    BankStack.Stack(from, to, is_cloth)
    BankStack.Fill(from, to, false, is_cloth)
end, "bags bank", 2)

-- Horrifying checkboxes

-- local options = {
--   type = "group",
--   name = "Testing of toggle",
--   get = function(info) return true end,
--   set = function(info, value) end,
--   args = {},
-- }
-- for i=1,1000 do
--   options.args["toggle" .. i] = {
--     type = "toggle",
--     name = "Toggle #" .. i,
--     width = "full",
--   }
-- end

-- LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ToggleTest", options)
-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ToggleTest", "ToggleTest")

-- DressUpModel customrace bug:

-- local model = CreateFrame("DressUpModel", nil, UIParent)
-- model:SetSize(300, 500)
-- model:SetPoint("CENTER")
-- model:SetKeepModelOnHide(true)
-- model:Show()

-- -- model:SetBarberShopAlternateForm()
-- -- model:SetUnit("player")
-- model:SetUnit("none")
-- model:SetCustomRace(1, 1) -- human female
-- model:TryOn("item:128365") -- a distinctive hat


-- local model = CreateFrame("DressUpModel", "MAWDSModel", UIParent)
-- model:SetSize(300, 500)
-- model:SetPoint("CENTER")
-- model:SetKeepModelOnHide(true)
-- model:Show()

-- -- model:SetBarberShopAlternateForm()
-- model:SetUnit("player")
-- -- model:SetUnit("none")
-- model:SetScript("OnUpdate", function()
--   if IsUnitModelReadyForUI("player") then
--     model:RefreshUnit()
--     -- model:Undress()
--     model:UndressSlot()
--     model:TryOn("item:128365") -- a distinctive hat
--     model:SetScript("OnUpdate", nil)
--   end
-- end)


-- some debug stuff that should really be in idTip
do
    local label
    EventRegistry:RegisterCallback("AreaPOIPin.MouseOver", function(_, pin, tooltipShown, areaPoiID, name)
        if tooltipShown then
            local tooltip = GetAppropriateTooltip()
            tooltip:AddDoubleLine("areaPoiID", areaPoiID)
            tooltip:Show()
        else
            if not label then
                for provider in pairs(WorldMapFrame.dataProviders) do
                    if provider.Label and provider.Label.GetHighestPriorityLabelInfo then
                        label = provider.Label:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        -- label:SetTextColor(1, 0, 0)
                        label:SetPoint("TOP")
                        break
                    end
                end
                if label then
                    WorldMapFrame:RegisterCallback("ClearAreaLabel", function()
                        label:Hide()
                    end, label)
                end
            end
            if label then
                label:SetText(("areaPoiID: %d"):format(areaPoiID))
                label:Show()
            end
        end
    end, myname)
end

-- faction IDs
if ReputationUtil and ReputationUtil.TryAppendAccountReputationLineToTooltip then
    -- Midnight
    hooksecurefunc(ReputationUtil, "TryAppendAccountReputationLineToTooltip", function(tooltip, factionID)
        tooltip:AddDoubleLine("factionID", factionID or UNKNOWN)
        tooltip:Show()
    end)
    local label
    EventRegistry:RegisterCallback("JourneysFrameMixin.FactionChanged", function(_, factionID)
        if not label then
            label = EncounterJournalInstanceSelect:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            label:SetPoint("TOPLEFT", 8, -8)
            EventRegistry:RegisterCallback("EncounterJournal.TabSet", function()
                label:Hide()
            end)
        end
        label:SetFormattedText("factionID: %d", factionID or 0)
        label:Show()
    end)
elseif ReputationFrame and ReputationFrame.ScrollBox then
    local hooked = {}
    local function addToTooltip(self)
        local tooltip = C_Reputation.IsFactionParagon(self.elementData.factionID) and EmbeddedItemTooltip or GameTooltip
        tooltip:AddDoubleLine("factionID", self.elementData.factionID or UNKNOWN)
        tooltip:Show()
    end
    ReputationFrame.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnInitializedFrame, function(_, frame, elementData)
        if frame.ShowTooltipForReputationType and not hooked[frame] then
            hooksecurefunc(frame, "ShowTooltipForReputationType", addToTooltip)
            hooked[frame] = true
        end
    end, myname)
end

-- Trait trees

do
    local lastTree, lastConfig
    EventRegistry:RegisterCallback("GenericTraitFrame.SetTreeID", function(_, treeid, configid)
        lastTree = treeid
        lastConfig = configid
    end)
    EventRegistry:RegisterCallback("TalentDisplay.TooltipCreated", function(_, button, tooltip)
        if lastTree then
            tooltip:AddDoubleLine("treeID", lastTree)
        end
        if lastConfig then
            tooltip:AddDoubleLine("configID", lastConfig)
        end
        if button.GetNodeID and button:GetNodeID() then
            tooltip:AddDoubleLine("nodeID", button:GetNodeID())
        end
        if button.GetEntryID and button:GetEntryID() then
            tooltip:AddDoubleLine("entryID", button:GetEntryID())
        end
        -- idtip does give me this
        -- if button:GetSpellID() then
        --     tooltip:AddDoubleLine("spellID", button:GetSpellID())
        -- end
        tooltip:Show()
    end)
end

-- bonus IDs
if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        local primaryInfo = tooltip:GetPrimaryTooltipInfo()
        if issecretvalue(primaryInfo and primaryInfo.tooltipData and primaryInfo.tooltipData.type and primaryInfo.tooltipData.type) then
            return
        end
        local itemLink, _
        if tooltip.GetItem then
            _, itemLink = tooltip:GetItem()
        elseif tooltip.GetPrimaryTooltipData then
            local data = tooltip:GetPrimaryTooltipData()
            if data and data.guid and data.type == Enum.TooltipDataType.Item then
                itemLink = C_Item.GetItemLinkByGUID(data.guid)
            end
        end
        if not itemLink then return end
        local options = LinkOptions(itemLink)
        if options.bonusIDs then
            tooltip:AddDoubleLine("BonusIDs", table.concat(options.bonusIDs, ", "))
            tooltip:Show()
        end
    end)
end


-- Set IDs in the appearances list
EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections", function()
    if WardrobeCollectionFrame.SetsCollectionFrame.ScrollFrame then return end -- pre-DF
    hooksecurefunc(WardrobeSetsScrollFrameButtonIconFrameMixin, "DisplaySetTooltip", function(self)
        local setID = self:GetParent().setID
        if setID then
            GameTooltip:AddDoubleLine("main setID", setID)
            local variants = C_TransmogSets.GetVariantSets(setID)
            if variants and #variants > 0 then
                table.insert(variants, C_TransmogSets.GetSetInfo(setID))
                table.sort(variants, function (a, b) return a.uiOrder < b.uiOrder end)
                for _, variant in ipairs(variants) do
                    GameTooltip:AddDoubleLine(
                        variant.description, variant.setID,
                        variant.collected and 0 or 1, variant.collected and 1 or 0, 0,
                        variant.collected and 0 or 1, variant.collected and 1 or 0, 0
                    )
                end
            end
            GameTooltip:Show()
        end
    end)
end)
