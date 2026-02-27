local myname, ns = ...

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
