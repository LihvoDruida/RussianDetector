function SendToxicityWarning()
    local message =
    "Due to concerns about toxic behavior and the risk of a Mythic+ key wipe, I prefer not to group with Russian-speaking players at the moment. Thank you for understanding."

    if IsInGroup() or IsInRaid() then
        SendChatMessage(message, IsInRaid() and "RAID" or "PARTY")
    else
        return -- Виходимо, якщо не в групі або рейді
    end
end
