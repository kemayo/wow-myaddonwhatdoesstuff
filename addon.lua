local myname, ns = ...

local debugf = tekDebug and tekDebug:GetFrame("Kemayo")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

-- events
local f = CreateFrame("frame")
f:SetScript("OnEvent", function(self, event, ...) if ns[event] then return ns[event](ns, event, ...) end end)
function ns:RegisterEvent(...) for i=1,select("#", ...) do f:RegisterEvent((select(i, ...))) end end
function ns:UnregisterEvent(...) for i=1,select("#", ...) do f:UnregisterEvent((select(i, ...))) end end

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
