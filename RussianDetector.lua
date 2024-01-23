local addonName, ns = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local checkMembers = ns.CheckGroupMembers:new()
local SettingsProvider = ns.SettingsProvider:new()
local eventHandler = ns.EventHandler:new()

local function PrintMessage(message)
  print(("|cFFFF7D0A<|r|cFFFFFF00%s|r|cFFFF7D0A>|r %s"):format(addonName, message))
end

local function CreateInterfaceOptions()
  SettingsProvider:Build()

  local namespace = "RussianDetector"
  AceConfig:RegisterOptionsTable(namespace, ns.Options)
  AceConfigDialog:AddToBlizOptions(namespace, namespace)
  addon:RegisterChatCommand("rusdetect", function() AceConfigDialog:Open(namespace) end)
end

local function OnPlayerLogin()
  SettingsProvider:Load()
  CreateInterfaceOptions()

  local enableToxicityWarning, enableLeaveGroup, enableLeaveRaid = SettingsProvider.GetTranslatorsState()

  local translators = {
    { enabled = enableToxicityWarning, func = function() SendToxicityWarning() end },
    { enabled = enableLeaveGroup,      func = function() GroupUtils_LeaveGroup() end },
    { enabled = enableLeaveRaid,       func = function() GroupUtils_LeaveRaid() end },
  }

  function ProcessTranslatorActions(translators)
    local leaveGroupEnabled, leaveRaidEnabled = false, false

    for _, translator in pairs(translators) do
      if translator and translator.enabled then
        translator.func()
        if translator.enabled == enableLeaveGroup then
          leaveGroupEnabled = true
        elseif translator.enabled == enableLeaveRaid then
          leaveRaidEnabled = true
        end
      end
    end

    return leaveGroupEnabled, leaveRaidEnabled
  end

  function ProcessRussianPlayers(playerNames)
    local playerList = table.concat(playerNames, "\n")
    PrintMessage("Players with Cyrillic names detected:\n" .. playerList)

    local leaveGroupEnabled, leaveRaidEnabled = ProcessTranslatorActions(translators)

    if leaveGroupEnabled or leaveRaidEnabled then
      WarnRussianPlayersDetected(playerList)
    end
  end
end

local function initializeAddon()
  if initialized then
    return
  end

  StaticPopupDialogs["ADDON_TRANSLATOR_RESET_SETTINGS"] = {
    text = "Ви впевнені, що хочете скинути всі налаштування до стандартних значень?",
    button1 = "Продовжити",
    button2 = "Скасувати",
    OnAccept = function() SettingsProvider:Reset() end,
    OnShow = function() PlaySound(SOUNDKIT.RAID_WARNING) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }

  function addon:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", checkMembers.CheckGroupMembers)
    PrintMessage("Addon activated.")
  end
end

local function OnAddOnLoaded(_, name)
  if name == addonName then
    initializeAddon()
    if not IsLoggedIn() then
      eventHandler:Register(OnPlayerLogin, "PLAYER_LOGIN")
    else
      OnPlayerLogin()
    end
  end
end

eventHandler:Register(OnAddOnLoaded, "ADDON_LOADED")
