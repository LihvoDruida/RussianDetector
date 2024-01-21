local addon = select(2, ...)
local addonName, ns = ...;

local checkMembers = class("CheckGroupMembers");


local russianPlayerNames = {}

local function LogMessage(message)
    print("|cFFFF7D0A<|r|cFFFFFF00" .. addonName .. "|r|cFFFF7D0A>|r " .. message)
end

function checkMembers:CheckGroupMembers()
    if not IsInGroup() and not IsInRaid() then
        return
    end

    wipe(russianPlayerNames)
    local numMembers = GetNumGroupMembers()

    if IsInRaid() then
        MAX_GROUP_SIZE = MAX_RAID_MEMBERS
    elseif IsInGroup() then
        MAX_GROUP_SIZE = MAX_PARTY_MEMBERS
    else
        MAX_GROUP_SIZE = 1
    end

    if numMembers then
        for i = 1, numMembers do
            local name, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
            if name then
                if ContainsRussianCharacters(name) then
                    if not tContains(russianPlayerNames, name) then
                        table.insert(russianPlayerNames, name)
                    end
                end
            end
        end

        if #russianPlayerNames > 0 then
            ProcessRussianPlayers(russianPlayerNames)
        else
            LogMessage("Players with Cyrillic names not found in the group.")
        end
    else
        LogMessage("Unable to determine the number of group members.")
    end
end

function IsCyrillic(char)
    local utf8Byte1 = char:byte(1)

    if utf8Byte1 >= 0xD0 and utf8Byte1 <= 0xDF then
        return true
    elseif utf8Byte1 == 0xD1 then
        local utf8Byte2 = char:byte(2)
        return (utf8Byte2 >= 0x80 and utf8Byte2 <= 0x8F)
    end

    return false
end

function ContainsRussianCharacters(text)
    for char in text:gmatch(".") do
        if IsCyrillic(char) then
            return true
        end
    end

    return false
end

ns.CheckGroupMembers = checkMembers
