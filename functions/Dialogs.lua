local Dialog = LibStub("LibDialog-1.0")

-- Реєстрація діалогу для повідомлення про гравця з російським ім'ям
Dialog:Register("Broker_RussianPlayerDetected_Warn", {
    text = " ",
    icon = [[Interface\DialogFrame\UI-DIALOG-ICON-ALERTOTHER]],
    buttons = {
        {
            text = "Ok",
        },
    },
    on_show = function(self, playerList)
        self.text:SetFormattedText(
            "Players with Russian names have been detected:\n%s.", playerList)
    end,
    hide_on_escape = true,
    show_while_dead = false,
})

-- Функція для виведення повідомлення про гравців з російськими іменами у діалозі "Broker_RussianPlayerDetected_Warn"
function WarnRussianPlayersDetected(playerList)
    Dialog:Spawn("Broker_RussianPlayerDetected_Warn", playerList)
end
