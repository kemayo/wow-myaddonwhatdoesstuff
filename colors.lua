local myname, ns = ...

local ROW_HEIGHT = 20
local SWATCH_SIZE = 16

local frame

local function InitRow(row, colorInfo)
    if not row.created then
        row.created = true
        row.Swatch = row:CreateTexture(nil, "ARTWORK")
        row.Swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
        row.Swatch:SetPoint("LEFT", 2, 0)
        row.Swatch:SetColorTexture(1, 1, 1, 1)
        -- something opaque behind the swatch, so alpha is visible
        row.Backdrop = row:CreateTexture(nil, "BACKGROUND")
        row.Backdrop:SetPoint("TOPLEFT", row.Swatch, -1, 1)
        row.Backdrop:SetPoint("BOTTOMRIGHT", row.Swatch, 1, -1)
        -- row.Backdrop:SetColorTexture(0.5, 0.5, 0.5, 1)
        row.Backdrop:SetAtlas("QuestTurnin")
        row.Hex = row:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        row.Hex:SetPoint("RIGHT", -4, 0)
        row.Name = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        row.Name:SetPoint("LEFT", row.Swatch, "RIGHT", 6, 0)
        row.Name:SetPoint("RIGHT", row.Hex, "LEFT", -6, 0)
        row.Name:SetJustifyH("LEFT")
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip_SetTitle(GameTooltip, self.colorInfo.baseTag)
            GameTooltip:AddDoubleLine("rgba", ("%f, %f, %f, %f"):format(self.colorInfo.color:GetRGBA()))
            GameTooltip:AddDoubleLine("hex", self.colorInfo.color:GenerateHexColor())
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", GameTooltip_Hide)
    end
    row.colorInfo = colorInfo
    row.Swatch:SetVertexColor(colorInfo.color:GetRGBA())
    row.Name:SetText(colorInfo.baseTag)
    row.Name:SetTextColor(colorInfo.color:GetRGB())
    row.Hex:SetText(colorInfo.color:GenerateHexColor())
end

local function CreateColorFrame()
    frame = CreateFrame("Frame", myname .. "Colors", UIParent, "ButtonFrameTemplate")
    frame:SetSize(420, 480)
    frame:SetPoint("CENTER")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetTitle("UI Colors")
    ButtonFrameTemplate_HidePortrait(frame)
    ButtonFrameTemplate_HideButtonBar(frame)
    table.insert(UISpecialFrames, frame:GetName())

    frame.ScrollBox = CreateFrame("Frame", nil, frame, "WowScrollBoxList")
    frame.ScrollBox:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 4, -4)
    frame.ScrollBox:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -22, 4)

    frame.ScrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
    frame.ScrollBar:SetPoint("TOPLEFT", frame.ScrollBox, "TOPRIGHT", 6, 0)
    frame.ScrollBar:SetPoint("BOTTOMLEFT", frame.ScrollBox, "BOTTOMRIGHT", 6, 0)

    local view = CreateScrollBoxListLinearView()
    view:SetElementExtent(ROW_HEIGHT)
    view:SetElementInitializer("Frame", InitRow)
    ScrollUtil.InitScrollBoxListWithScrollBar(frame.ScrollBox, frame.ScrollBar, view)

    local search = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    search:SetHeight(22)
    search:SetWidth(frame:GetWidth() - 40)
    search:SetPoint("TOP", 0, -24)
    search:SetScript("OnTextChanged", function(self)
        -- the template's own handler drives its placeholder text and clear button
        SearchBoxTemplate_OnTextChanged(self)
        -- the template's clear button sets the text itself, and that must
        -- reset the list as deleting it does
        ns:ShowUIColors(self:GetText())
    end)
    search:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        ns:ShowUIColors(nil)
    end)
    frame.Search = search

    return frame
end

function ns:ShowUIColors(filter)
    if not frame then
        CreateColorFrame()
    end

    if filter == "" then filter = nil end

    local colors = {}
    for _, dbColor in ipairs(C_UIColor.GetColors()) do
        if not filter or dbColor.baseTag:lower():match(filter) then
            table.insert(colors, dbColor)
        end
    end
    table.sort(colors, function(a, b) return a.baseTag < b.baseTag end)

    frame:SetTitleFormatted("UI Colors (%d)", #colors)
    frame.ScrollBox:SetDataProvider(CreateDataProvider(colors))

    frame:Show()
end

SLASH_MYADDONWHATDOESSTUFFCOLORS1 = "/mawd_colors"
function SlashCmdList.MYADDONWHATDOESSTUFFCOLORS(arg)
    ns:ShowUIColors(arg ~= "" and arg:lower() or nil)
end
