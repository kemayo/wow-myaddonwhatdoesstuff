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
