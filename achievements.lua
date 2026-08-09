local myname, ns = ...

SLASH_MYADDONWHATDOESSTUFFACHIEVEMENTDUMP1 = "/mawd_achievement"
function SlashCmdList.MYADDONWHATDOESSTUFFACHIEVEMENTDUMP(arg)
    if arg == "" then return print("I need an achievementid") end
    local achievement = tonumber(arg)
    local _, achievementName = GetAchievementInfo(achievement)
    if not achievementName then
        return print("Invalid achievementid: "..arg)
    end
    local out = {insert=table.insert}
    out:insert(("-- %s"):format(achievementName))
    -- out:insert("{")
    for i=1, GetAchievementNumCriteria(achievement) do
       local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(achievement, i)
       -- print(criteriaString, criteriaID, assetID, flags)
       out:insert(("[] = {criteria=%d, quest=%d}, -- %s"):format(criteriaID, assetID, criteriaString))
    end
    -- out:insert("}")

    ns:ShowTextToCopy(unpack(out))
end
