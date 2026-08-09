local myname, ns = ...

SLASH_MYADDONWHATDOESSTUFFMERCHANTDUMP1 = "/mawd_merchant"
function SlashCmdList.MYADDONWHATDOESSTUFFMERCHANTDUMP(arg)
    local out = {insert=table.insert}
    out:insert(("-- %s"):format(UnitName("npc")))
    for i=1, GetMerchantNumItems() do
       local itemID = GetMerchantItemID(i)
       local itemName = GetItemInfo(itemID)
       out:insert(("%s, -- %s"):format(itemID, itemName))
    end
    ns:ShowTextToCopy(unpack(out))
end
