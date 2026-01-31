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
EventRegistry:RegisterCallback("AreaPOIPin.MouseOver", function(_, pin, tooltipShown, areaPoiID, name)
    local tooltip = GetAppropriateTooltip()
    if not tooltipShown then
        tooltip:SetOwner(pin, "ANCHOR_CURSOR")
        -- tooltip:AddLine(name)
        tooltip:AddDoubleLine(name, "DEBUG", 1, 1, 1, 1, 0, 0)
    end
    tooltip:AddDoubleLine("areaPoiID", areaPoiID)
    tooltip:Show()
end, myname)

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

do
    SLASH_MYADDONWHATDOESSTUFFLINKDUMP1 = "/mawd_linkdump"
    function SlashCmdList.MYADDONWHATDOESSTUFFLINKDUMP(arg)
        if arg == "" then return print("I need links") end
        local links = {}
        for match in string.gmatch(arg, "(|c.-|h|r)") do
            table.insert(links, match)
        end
        if #links == 0 then return print("I need links") end
        local out = {insert=table.insert}
        out:insert("{")
        for _, link in ipairs(links) do
            local linkOptions, linkType, displayText = LinkOptions(link)
            out:insert(("    [%d] = \"%s\","):format(linkOptions.itemID, displayText:gsub("[%[%]]", "")))
        end
        out:insert("}")
        ns:ShowTextToCopy(unpack(out))
    end

    SLASH_MYADDONWHATDOESSTUFFSETDUMP1 = "/mawd_setdump"
    function SlashCmdList.MYADDONWHATDOESSTUFFSETDUMP(arg)
        local setID = tonumber(arg)
        if not setID then return print("Give me a setID") end
        ns:DumpSetById(setID)
    end
    SLASH_MYADDONWHATDOESSTUFFSETDUMPVARIANTS1 = "/mawd_setdumpv"
    function SlashCmdList.MYADDONWHATDOESSTUFFSETDUMPVARIANTS(arg)
        local setID = tonumber(arg)
        if not setID then return print("Give me a setID") end
        ns:DumpSetById(setID, true)
    end
    SLASH_MYADDONWHATDOESSTUFFSETDUMPLABEL1 = "/mawd_setdumpl"
    function SlashCmdList.MYADDONWHATDOESSTUFFSETDUMPLABEL(arg)
        if arg == "" then return print("Give me a label to find") end
        local origClassID = C_TransmogSets.GetTransmogSetsClassFilter()
        local queue = {}
        for classID = 1, GetNumClasses() do
            table.insert(queue, C_CreatureInfo.GetClassInfo(classID))
        end
        local matchedSets = {}
        local out = {insert=table.insert}
        local function processQueue()
            local classInfo = table.remove(queue, 1)
            print("Scanning", classInfo.classFile)

            local baseSets = C_TransmogSets.GetBaseSets()
            for _, set in ipairs(baseSets) do
                local setInfo = C_TransmogSets.GetSetInfo(set.setID)
                if string.match(setInfo.label or "", arg) then
                    out:insert(("%s set: %d %s (%s)"):format(classInfo.classFile, set.setID, setInfo.name, setInfo.label))
                    setInfo.classFile = setInfo.classFile -- classMask is already there, but this is simpler for me
                    table.insert(matchedSets, setInfo)
                end
            end
            if #queue > 0 then
                C_TransmogSets.SetTransmogSetsClassFilter(queue[1].classID)
                C_Timer.After(0.3, processQueue)
            else
                C_TransmogSets.SetTransmogSetsClassFilter(origClassID)
                local pending = #matchedSets
                for _, setInfo in ipairs(matchedSets) do
                    print("Dumping set items", setInfo.setID)
                    ns:DumpSetById(setInfo.setID, false, function(setOut)
                        tAppendAll(out, setOut)
                        pending = pending - 1
                        print("Done with set", setInfo.setID, #setOut, pending)
                        if pending == 0 then
                            ns:ShowTextToCopy(unpack(out))
                        end
                    end)
                end
            end
        end
        C_TransmogSets.SetTransmogSetsClassFilter(queue[1].classID)
        C_Timer.After(0.3, processQueue)
    end

    function ns:DumpSetById(setID, includeVariants, callback)
        local continuableContainer = ContinuableContainer:Create()

        local setInfo = C_TransmogSets.GetSetInfo(setID)
        local variants = includeVariants and C_TransmogSets.GetVariantSets(setID) or {}

        table.insert(variants, setInfo)
        table.sort(variants, function (a, b) return a.uiOrder < b.uiOrder end)

        -- set this up:
        local items = {}
        for _, variant in ipairs(variants) do
            local setItems = C_Transmog.GetAllSetAppearancesByID(variant.setID)
            for _, itemData in ipairs(setItems) do
                local item = Item:CreateFromItemID(itemData.itemID)
                items[itemData.itemID] = item
                continuableContainer:AddContinuable(item)
            end
        end

        continuableContainer:ContinueOnLoad(function()
            local out = {}
            out.insert = table.insert

            out:insert("{ --" .. setInfo.name)
            for _, variant in ipairs(variants) do
                local setItems = C_Transmog.GetAllSetAppearancesByID(variant.setID)
                out:insert("    -- " .. variant.description)
                for _, itemData in ipairs(setItems) do
                    local item = items[itemData.itemID]
                    out:insert(string.format(
                        "    {itemID=%d, appearanceID=%d}, -- %s (%s)",
                        itemData.itemID, itemData.itemModifiedAppearanceID, item:GetItemName() or UNKNOWN, strlower(gsub(itemData.invType, "INVTYPE_", ""))
                    ))
                end
            end
            out:insert("},")

            if callback then
                callback(out)
            else
                ns:ShowTextToCopy(unpack(out))
            end
        end)
    end
end
