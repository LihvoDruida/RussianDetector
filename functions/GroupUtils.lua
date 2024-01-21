-- Функція для виходу з групи або рейду та видалення гравців з російськими іменами
function GroupUtils_LeaveGroup()
    if not (IsInGroup() or IsInRaid()) then
        return -- Виходимо, якщо не в групі або рейді
    end

    local isLeaderOrAssistant = UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")

    if IsInGroup() and not isLeaderOrAssistant then
        C_PartyInfo.LeaveParty() -- Виходимо групи
    end
end

function GroupUtils_LeaveRaid()
    if not (IsInGroup() or IsInRaid()) then
        return -- Виходимо, якщо не в групі або рейді
    end

    local isLeaderOrAssistant = UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")

    if IsInRaid() and not isLeaderOrAssistant then
        C_PartyInfo.LeaveParty() -- Виходимо з рейду або групи
    end
end

-- Функція для видалення гравців з іменами, що містять російські символи
function RemovePlayersWithRussianCharacters(playerList)
    if not (IsInGroup() or IsInRaid()) then
        return -- Виходимо, якщо не в групі або рейді
    end

    local toRemove = {} -- Створюємо пустий список для гравців, яких потрібно видалити

    for index, playerName in ipairs(playerList) do
        if ContainsRussianCharacters(playerName) then
            table.insert(toRemove, index) -- Додаємо індекси гравців з російськими символами до списку для видалення
        end
    end

    -- Переверніть список для видалення, щоб видаляти гравців з кінця
    table.sort(toRemove, function(a, b) return a > b end)

    for _, index in ipairs(toRemove) do
        table.remove(playerList, index) -- Видаляємо гравців з російськими іменами
    end
end
