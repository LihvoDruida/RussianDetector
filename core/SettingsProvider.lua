local addon = select(2, ...)
local addonName, ns = ...;

local SettingsProvider = class("SettingsProvider");
ns.SettingsProvider = SettingsProvider

local defaultOptions = {
    -- Addons actual
    enableToxicityWarning = true,
    enableLeaveGroup = true,
    enableLeaveRaid = false,
}

function SettingsProvider:Load()
    RussianDetector_Options = RussianDetector_Options or {}

    -- Assign default values for options not present in AddonUkrainizer_Options
    for key, defaultValue in pairs(defaultOptions) do
        if RussianDetector_Options[key] == nil then
            RussianDetector_Options[key] = defaultValue
        end
    end
end

function SettingsProvider:Build()
    local function addVerticalMargin(order)
        return {
            type = "description",
            name = "",
            fontSize = "medium",
            order = order,
            width = 3.6
        }
    end
    local function addHeader(name, order)
        return {
            type = "header",
            name = name,
            order = order,
        }
    end


    local function createIncrementor()
        local x = 0
        return function()
            x = x + 1
            return x
        end
    end

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
    if string.match(version, "-[%w%d][%w%d][%w%d][%w%d][%w%d][%w%d][%w%d][%w%d]$") then
        version = "[alpha] " .. version
    end

    local contributorsOrder = createIncrementor()

    local addons = {
        { "Messages Warning", "enableToxicityWarning", "Enable or disable sending toxicity warning messages to the chat." },
        { "Leave Group",      "enableLeaveGroup",      "Enable or disable leaving the group when Russian players are detected." },
        { "Leave Raid",       "enableLeaveRaid",       "Enable or disable leaving the raid when Russian players are detected." },
    }

    local contributors = {
        { "Автор", "Лігво Друїда (molaf)\n\n", "Proofreaders" },
    }

    local mediaAddons = {
        { "DBM Ukrainian", "https://legacy.curseforge.com/wow/addons/dbm-voice-pack-ukrainian-female", "dbmvp" },
        { "DBM Countdown Ukrainian",
            "https://legacy.curseforge.com/wow/addons/deadly-boss-mods-dbm-ukrainian-countdown-pack", "dbmcp" },
    }
    local mediaSocial = {
        { "Лігво Друїда", "https://www.youtube.com/channel/UCWex56K6Xev50zIF7hVCyMQ", "youtube1" },
    }

    ns.Options = {
        type = "group",
        name = addonName,
        args = {
            General = {
                order = 1,
                type = "group",
                name = "Налаштування",
                childGroups = "tab",
                args = {
                    logo = {
                        order = 1,
                        type = "description",
                        name = " ",
                        image = addon.LOGO_LOCATION,
                        imageWidth = 256,
                        imageHeight = 64,
                        width = 1.6
                    },
                    version = {
                        order = 1.2,
                        type = "description",
                        name = function() return "|cFF87CEFAv" .. version .. "|r" end,
                        width = 0.9
                    },
                    Commands = {
                        order = 2,
                        type = "group",
                        name = " ",
                        inline = true,
                        args = {
                            SettingsWarning = {
                                type = "description",
                                name =
                                [[|cffff2020Attention!|r
Changes in settings will take effect only after restarting the interface or executing the /reload command.
Please note that without this step, the new settings will not come into effect.]]
                                ,
                                fontSize = "small",
                                order = 1,
                                width = "full"
                            },
                            ResetInterface = {
                                order = 3,
                                name = "Reload",
                                type = "execute",
                                func = function() ReloadUI() end,
                            },
                            ResetFonts = {
                                order = 4,
                                name = "Default",
                                desc =
                                [[This button resets all settings to the default values set by the add-on developers.

After pressing it, all your current settings will be lost, and the default values will be applied.]],
                                type = "execute",
                                func = function()
                                    StaticPopup_Show("ADDON_TRANSLATOR_RESET_SETTINGS");
                                end,
                            },
                        }
                    },
                    responseOptions = {
                        order = 4,
                        type = "group",
                        name = "Settings",
                        inline = true,
                        args = {},
                    },
                }
            },
            Contributors = {
                order = 2,
                type = "group",
                name = "Причетні",
                args = {
                    DedicationText = {
                        order = contributorsOrder(),
                        type = "description",
                        name = [[
Шановані пані та панове,

Дякую вам щирим серцем за використання цієї модифікації!
Закликаю вас грати українською мовою та переглядати український контент!Нижче ви знайдете посилання на необхідні ресурси.

Українізуємо World of Warcraft разом!
]],
                        fontSize = "small"
                    },
                    SPC00 = {
                        type = "description",
                        name = " ",
                        order = contributorsOrder(),
                    },
                    SPC01 = {
                        type = "description",
                        name = " ",
                        order = contributorsOrder(),
                    },
                    contributorsHeader = {
                        order = contributorsOrder(),
                        type = "group",
                        name = "Причетні",
                        inline = true,
                        args = {},
                    },
                    mediaHeader = {
                        order = contributorsOrder(),
                        type = "group",
                        name = "Ресурси та Посилання",
                        inline = true,
                        args = {},
                    },
                }
            }
        }
    }

    local argsOption = ns.Options.args.General.args.responseOptions.args
    local orderOption = 1
    local argsContributors = ns.Options.args.Contributors.args.contributorsHeader.args
    local orderContributors = 1
    local argsMedia = ns.Options.args.Contributors.args.mediaHeader.args
    local orderMedia = 1

    for _, addonData in ipairs(addons) do
        local addonName, optionKey, addonDesc = unpack(addonData)
        argsOption[optionKey] = {
            order = orderOption,
            name = addonName,
            desc = addonDesc,
            type = "toggle",
            get = function(_) return RussianDetector_Options[optionKey] end,
            set = function(_, value) RussianDetector_Options[optionKey] = value end,
        }
        orderOption = orderOption + 1
    end

    for _, contributorData in ipairs(contributors) do
        local desc, contributorName, optionKey = unpack(contributorData)
        argsContributors[optionKey] = {
            type = "input",
            name = desc,
            get = function() return contributorName end,
            order = orderContributors,
            disabled = true,
            dialogControl = "SFX-Info",
        }
        orderContributors = orderContributors + 1
    end

    for _, mediaAddonsData in ipairs(mediaAddons) do
        local name, url, optionKey = unpack(mediaAddonsData)
        argsMedia[optionKey] = {
            type = "input",
            name = name,
            get = function() return url end,
            order = orderMedia,
            disabled = false,
            dialogControl = "SFX-Info-URL",
        }
        orderMedia = orderMedia + 1
    end

    argsMedia.VerticalMargin1 = addVerticalMargin(orderMedia)
    orderMedia = orderMedia + 1
    argsMedia.Header1 = addHeader("Медіа ресурси", orderMedia)
    orderMedia = orderMedia + 1

    for _, mediaSocialData in ipairs(mediaSocial) do
        local name, url, optionKey = unpack(mediaSocialData)
        argsMedia[optionKey] = {
            type = "input",
            name = name,
            get = function() return url end,
            order = orderMedia,
            disabled = false,
            dialogControl = "SFX-Info-URL",
        }
        orderMedia = orderMedia + 1
    end
end

function SettingsProvider:Reset()
    RussianDetector_Options = self.GetDefaultOptions()
    ReloadUI()
end

function SettingsProvider.GetDefaultOptions() return defaultOptions end

function SettingsProvider.GetTranslatorsState()
    return RussianDetector_Options.enableToxicityWarning, RussianDetector_Options.enableLeaveGroup
end
